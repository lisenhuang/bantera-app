import Foundation

/// A conservative residual-echo guard after Apple's VoiceProcessingIO. It is
/// not a replacement for AEC. After at most 200 ms of startup protection, only
/// a nearly identical, delayed copy of actual speaker output is silenced;
/// independent speech and double-talk pass through.
final class BanteraEchoGuard {
  private let lock = NSLock()
  private let rate = 4000.0
  private let windowSize = 320 // 80 ms, bounded correlation work.
  private let maximumDelay = 1400 // 350 ms including hardware/queue latency.
  private var render = [Double](repeating: 0, count: 2000)
  private var renderIndex = 0
  private var renderCount = 0
  private var renderPhase = 0.0
  private var renderSum = 0.0
  private var renderSamples = 0
  private let startupProtectionSamples: Int
  private var startupProtectionRemaining = -1
  private var generation = 0
  // The following fields are confined to the caller's serial capture queue.
  private var captureGeneration = -1
  private var captured = [Double]()
  private var captureSum = 0.0
  private var captureSamples = 0

  init(startupProtectionMilliseconds: Int = 200) {
    // This short guard is a startup tradeoff, not a claim that AEC has converged.
    // Never extend it into a whole-reply mute or restart it for every response.
    startupProtectionSamples = min(200, max(0, startupProtectionMilliseconds)) * 4
  }

  /// Safe in the render callback: preallocated storage, bounded work, no
  /// allocations, dispatches, converters or correlation on the audio thread.
  func appendRender(_ samples: UnsafeBufferPointer<Int16>, sampleRate: Double) {
    guard sampleRate >= rate, sampleRate.isFinite else { return }
    lock.lock()
    defer { lock.unlock() }
    for sample in samples {
      renderSum += Double(sample)
      renderSamples += 1
      renderPhase += rate
      if renderPhase >= sampleRate {
        let value = renderSum / Double(renderSamples)
        render[renderIndex] = value
        renderIndex = (renderIndex + 1) % render.count
        renderCount = min(renderCount + 1, render.count)
        if startupProtectionRemaining < 0 && abs(value) > 32 {
          startupProtectionRemaining = startupProtectionSamples
        }
        if startupProtectionRemaining > 0 { startupProtectionRemaining -= 1 }
        renderPhase -= sampleRate
        renderSum = 0
        renderSamples = 0
      }
    }
  }

  /// Call on route/format discontinuities. Queued captures discard old history
  /// through the generation counter without racing the render thread.
  func reset() {
    lock.lock()
    renderIndex = 0; renderCount = 0
    renderPhase = 0; renderSum = 0; renderSamples = 0
    startupProtectionRemaining = -1
    generation += 1
    lock.unlock()
  }

  /// Call only on a serial, non-realtime capture queue. Input is processed mono
  /// 16 kHz signed little-endian PCM from VoiceProcessingIO.
  func processCapture(_ pcm16k: Data, speaker: Bool) -> Data {
    guard !pcm16k.isEmpty, pcm16k.count % 2 == 0 else { return pcm16k }
    var reference = [Double]()
    if speaker { reference.reserveCapacity(2000) }
    lock.lock()
    let currentGeneration = generation
    let protectStartup = startupProtectionRemaining > 0
    if speaker {
      let first = (renderIndex - renderCount + render.count) % render.count
      for offset in 0..<renderCount { reference.append(render[(first + offset) % render.count]) }
    }
    lock.unlock()
    if captureGeneration != currentGeneration || !speaker {
      captured.removeAll(keepingCapacity: true)
      captureSum = 0; captureSamples = 0
      captureGeneration = currentGeneration
    }
    guard speaker else { return pcm16k }
    var current = [Double]()
    current.reserveCapacity(pcm16k.count / 8 + 1)
    pcm16k.withUnsafeBytes { bytes in
      for offset in stride(from: 0, to: bytes.count, by: 2) {
        captureSum += Double(Int16(littleEndian: bytes.loadUnaligned(fromByteOffset: offset, as: Int16.self)))
        captureSamples += 1
        if captureSamples == 4 {
          current.append(captureSum / 4)
          captureSamples = 0; captureSum = 0
        }
      }
    }
    captured.append(contentsOf: current)
    if captured.count > windowSize { captured.removeFirst(captured.count - windowSize) }
    if protectStartup { return Data(count: pcm16k.count) }
    // Never discard a long chunk based only on its ending or classify startup
    // without enough evidence. Native readiness handles initial route settling.
    guard captured.count == windowSize, !current.isEmpty,
      current.count <= windowSize, reference.count >= windowSize else { return pcm16k }
    let microphoneMean = captured.reduce(0, +) / Double(windowSize)
    let microphoneEnergy = captured.reduce(0) { $0 + ($1 - microphoneMean) * ($1 - microphoneMean) }
    guard microphoneEnergy > Double(windowSize) * 16 else { return pcm16k }
    let limit = min(maximumDelay, reference.count - windowSize)
    var bestScore = 0.0
    var bestStart = 0
    var bestGain = 0.0
    var bestMean = 0.0
    // Rolling sums keep the per-delay work to one fixed-size dot product.
    var sum = 0.0, energy = 0.0
    let oldest = reference.count - windowSize - limit
    for sample in reference[oldest..<(oldest + windowSize)] { sum += sample; energy += sample * sample }
    for start in oldest...(reference.count - windowSize) {
      if start > oldest {
        let removed = reference[start - 1], added = reference[start + windowSize - 1]
        sum += added - removed; energy += added * added - removed * removed
      }
      let centeredEnergy = max(0, energy - sum * sum / Double(windowSize))
      guard centeredEnergy > Double(windowSize) * 64 else { continue }
      var dot = 0.0
      for index in 0..<windowSize { dot += captured[index] * reference[start + index] }
      dot -= microphoneMean * sum
      let score = dot * dot / (microphoneEnergy * centeredEnergy)
      if score > bestScore {
        bestScore = score; bestStart = start
        bestGain = dot / centeredEnergy
        bestMean = sum / Double(windowSize)
      }
    }
    // Energy and a very high match threshold preserve even quiet double-talk.
    // A correlation match on an older part of the window cannot erase a new
    // syllable: independently check the current chunk's unexplained residual.
    guard bestScore >= 0.985, abs(bestGain) <= 1.2 else { return pcm16k }
    var residualEnergy = 0.0, currentEnergy = 0.0
    let tail = windowSize - current.count
    for index in current.indices {
      let microphone = captured[tail + index] - microphoneMean
      let prediction = bestGain * (reference[bestStart + tail + index] - bestMean)
      let residual = microphone - prediction
      residualEnergy += residual * residual
      currentEnergy += microphone * microphone
    }
    let count = Double(current.count)
    let residualRms = sqrt(residualEnergy / count)
    let signalRms = sqrt(currentEnergy / count)
    guard residualRms <= min(24, max(4, signalRms * 0.035)) else { return pcm16k }
    return Data(count: pcm16k.count)
  }
}
