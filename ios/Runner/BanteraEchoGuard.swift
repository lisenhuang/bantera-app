import Foundation

/// A conservative residual-echo guard after Apple's native echo cancellation. It is
/// not a replacement for AEC. After bounded startup protection (at most 2500 ms), only
/// a strongly verified, delayed/filtered copy of actual speaker output is silenced;
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
  // Full-band corroboration prevents a low-band echo match from erasing an
  // independent high-frequency consonant in the original 16 kHz microphone.
  private var fullRender = [Double](repeating: 0, count: 8016)
  private var fullRenderIndex = 0, fullRenderCount = 0, fullRenderTotal = 0
  private var fullRenderPhase = 0.0, fullRenderSum = 0.0
  private var fullRenderSamples = 0
  private let startupProtectionSamples: Int
  private var startupProtectionRemaining = -1
  private var quietRenderSamples = 0
  private let idleRearmSamples = 8000 // 2 seconds at the 4 kHz reference rate.
  private var generation = 0
  private var startupSuppressedFrames = 0
  private var matchedEchoFrames = 0
  var diagnostics: String {
    lock.lock(); defer { lock.unlock() }
    return "startupGuardFrames=\(startupSuppressedFrames) residualEchoFrames=\(matchedEchoFrames)"
  }
  // The following fields are confined to the caller's serial capture queue.
  private var captureGeneration = -1
  private var captured = [Double]()
  private var captureSum = 0.0
  private var captureSamples = 0

  init(startupProtectionMilliseconds: Int = 500) {
    // This short guard is a startup tradeoff, not a claim that AEC has converged.
    // Never extend it into a whole-reply mute or restart it for continuous playback.
    // After idle the physical iPhone test found a new settling transient.
    // The capture clock includes the acoustic/processing return path; rendering
    // ahead must not expire protection before the matching microphone arrives.
    startupProtectionSamples = min(2500, max(0, startupProtectionMilliseconds)) * 16
  }

  /// Safe in the render callback: preallocated storage, bounded work, no
  /// allocations, dispatches, converters or correlation on the audio thread.
  func appendRender(_ samples: UnsafeBufferPointer<Int16>, sampleRate: Double) {
    guard sampleRate >= rate, sampleRate.isFinite else { return }
    lock.lock()
    defer { lock.unlock() }
    for sample in samples {
      if sampleRate >= 16000 {
        fullRenderSum += Double(sample)
        fullRenderSamples += 1
        fullRenderPhase += 16000
        if fullRenderPhase >= sampleRate {
          fullRender[fullRenderIndex] = fullRenderSum / Double(fullRenderSamples)
          fullRenderIndex = (fullRenderIndex + 1) % fullRender.count
          fullRenderCount = min(fullRenderCount + 1, fullRender.count)
          fullRenderTotal += 1
          fullRenderPhase -= sampleRate
          fullRenderSum = 0; fullRenderSamples = 0
        }
      }
      renderSum += Double(sample)
      renderSamples += 1
      renderPhase += rate
      if renderPhase >= sampleRate {
        let value = renderSum / Double(renderSamples)
        render[renderIndex] = value
        renderIndex = (renderIndex + 1) % render.count
        renderCount = min(renderCount + 1, render.count)
        if abs(value) > 32 {
          if startupProtectionRemaining < 0 || quietRenderSamples >= idleRearmSamples {
            startupProtectionRemaining = startupProtectionSamples
          }
          quietRenderSamples = 0
        } else {
          quietRenderSamples = min(idleRearmSamples, quietRenderSamples + 1)
        }
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
    fullRenderIndex = 0; fullRenderCount = 0; fullRenderTotal = 0
    fullRenderPhase = 0; fullRenderSum = 0; fullRenderSamples = 0
    startupProtectionRemaining = -1
    quietRenderSamples = 0
    generation += 1
    startupSuppressedFrames = 0; matchedEchoFrames = 0
    lock.unlock()
  }

  /// Call only on a serial, non-realtime capture queue. Input is processed mono
  /// 16 kHz signed little-endian PCM after hardware AEC or VoiceProcessingIO.
  func processCapture(_ pcm16k: Data, speaker: Bool) -> Data {
    guard !pcm16k.isEmpty, pcm16k.count % 2 == 0 else { return pcm16k }
    var reference = [Double](), fullReference = [Double]()
    if speaker { reference.reserveCapacity(2000); fullReference.reserveCapacity(8016) }
    lock.lock()
    let currentGeneration = generation
    let startupFrames = speaker ? min(max(0, startupProtectionRemaining), pcm16k.count / 2) : 0
    if startupFrames > 0 {
      startupProtectionRemaining -= startupFrames
      startupSuppressedFrames += startupFrames
    }
    if speaker {
      let first = (renderIndex - renderCount + render.count) % render.count
      for offset in 0..<renderCount { reference.append(render[(first + offset) % render.count]) }
      let fullFirst = (fullRenderIndex - fullRenderCount + fullRender.count) % fullRender.count
      for offset in 0..<fullRenderCount { fullReference.append(fullRender[(fullFirst + offset) % fullRender.count]) }
    }
    let fullReferenceOffset = fullRenderCount - renderCount * 4 - fullRenderTotal % 4
    lock.unlock()
    if captureGeneration != currentGeneration || !speaker {
      captured.removeAll(keepingCapacity: true)
      captureSum = 0; captureSamples = 0
      captureGeneration = currentGeneration
    }
    guard speaker else { return pcm16k }
    var current = [Double](), fullCurrent = [Double]()
    fullCurrent.reserveCapacity(pcm16k.count / 2)
    let capturePrefixSamples = captureSamples
    current.reserveCapacity(pcm16k.count / 8 + 1)
    pcm16k.withUnsafeBytes { bytes in
      for offset in stride(from: 0, to: bytes.count, by: 2) {
        let value = Double(Int16(littleEndian: bytes.loadUnaligned(fromByteOffset: offset, as: Int16.self)))
        fullCurrent.append(value)
        captureSum += value
        captureSamples += 1
        if captureSamples == 4 {
          current.append(captureSum / 4)
          captureSamples = 0; captureSum = 0
        }
      }
    }
    captured.append(contentsOf: current)
    if captured.count > windowSize { captured.removeFirst(captured.count - windowSize) }
    if startupFrames > 0 {
      var filtered = pcm16k
      filtered.resetBytes(in: 0..<(startupFrames * 2))
      return filtered
    }
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
    let tail = windowSize - current.count
    if bestScore >= 0.985, abs(bestGain) <= 1.2 {
      var residualEnergy = 0.0, currentEnergy = 0.0
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
      if residualRms <= min(24, max(4, signalRms * 0.035)),
        fullBandMatches(fullReference, microphone: fullCurrent,
          start: fullReferenceOffset + (bestStart + tail) * 4 + capturePrefixSamples,
          weights: [bestGain], means: [bestMean], targetMean: microphoneMean) {
        return suppressMatched(pcm16k)
      }
    }
    // Real speaker/microphone paths colour the signal. A short, bounded FIR
    // can verify that case without weakening the scalar match above. Fit only
    // the earlier samples, never the current chunk: otherwise fitting could
    // explain away the very first syllable of an interrupting person.
    if bestScore >= 0.55,
      let filter = matchingEchoFilter(reference, start: bestStart, heldOut: current.count),
      fullBandMatches(fullReference, microphone: fullCurrent,
        start: fullReferenceOffset + (bestStart + tail) * 4 + capturePrefixSamples,
        weights: filter.weights, means: filter.means, targetMean: filter.targetMean) {
      return suppressMatched(pcm16k)
    }
    return pcm16k
  }

  private func suppressMatched(_ input: Data) -> Data {
    lock.lock(); matchedEchoFrames += input.count / 2; lock.unlock()
    return Data(count: input.count)
  }

  private func matchingEchoFilter(_ reference: [Double], start: Int, heldOut: Int)
    -> (weights: [Double], means: [Double], targetMean: Double)? {
    let taps = 12 // 3 ms at 4 kHz; no unbounded adaptive filter on the audio thread.
    let training = windowSize - heldOut
    guard heldOut >= 16, training >= 160, start >= taps - 1 else { return nil }
    var means = [Double](repeating: 0, count: taps)
    let targetMean = captured.prefix(training).reduce(0, +) / Double(training)
    for row in 0..<training {
      for tap in 0..<taps { means[tap] += reference[start + row - tap] / Double(training) }
    }
    var matrix = [Double](repeating: 0, count: taps * taps)
    var rhs = [Double](repeating: 0, count: taps)
    var features = [Double](repeating: 0, count: taps)
    for row in 0..<training {
      let target = (captured[row] - targetMean) / 32768
      for tap in 0..<taps { features[tap] = (reference[start + row - tap] - means[tap]) / 32768 }
      for a in 0..<taps {
        rhs[a] += features[a] * target
        for b in 0...a { matrix[a * taps + b] += features[a] * features[b] }
      }
    }
    let ridge = max(1e-10, (0..<taps).map { matrix[$0 * taps + $0] }.max()! * 1e-6)
    for a in 0..<taps {
      matrix[a * taps + a] += ridge
      for b in 0..<a { matrix[b * taps + a] = matrix[a * taps + b] }
    }
    guard let weights = Self.solve(matrix, rhs),
      weights.allSatisfy({ $0.isFinite && abs($0) <= 1.2 }),
      weights.reduce(0, { $0 + abs($1) }) <= 2 else { return nil }
    func residualIsSmall(_ range: Range<Int>, maximum: Double, fraction: Double) -> Bool {
      var residual = 0.0, energy = 0.0
      for row in range {
        let actual = captured[row] - targetMean
        var prediction = 0.0
        for tap in 0..<taps { prediction += weights[tap] * (reference[start + row - tap] - means[tap]) }
        residual += (actual - prediction) * (actual - prediction)
        energy += actual * actual
      }
      let rms = sqrt(energy / Double(range.count))
      return sqrt(residual / Double(range.count)) <= min(maximum, max(4, rms * fraction))
    }
    guard residualIsSmall(0..<training, maximum: 24, fraction: 0.035),
      residualIsSmall(training..<windowSize, maximum: 18, fraction: 0.025) else { return nil }
    return (weights, means, targetMean)
  }

  // Do not refit on the current microphone chunk. Check the already-fitted
  // echo prediction at full bandwidth, including frequencies lost by the
  // 4:1 analysis average. Missing/unmatched reference always leaves speech intact.
  private func fullBandMatches(_ reference: [Double], microphone: [Double], start: Int,
    weights: [Double], means: [Double], targetMean: Double) -> Bool {
    guard !microphone.isEmpty, !reference.isEmpty else { return false }
    let energy = microphone.reduce(0) { $0 + ($1 - targetMean) * ($1 - targetMean) }
    let rms = sqrt(energy / Double(microphone.count))
    let allowed = min(18, max(4, rms * 0.025))
    // Low-band alignment has four possible 16 kHz phases. Existing coefficients
    // are fixed: trying bounded offsets cannot fit away an independent syllable.
    for phase in -3...3 {
      let first = start + phase
      guard first - (weights.count - 1) * 4 >= 0,
        first + microphone.count <= reference.count else { continue }
      var residual = 0.0
      for row in microphone.indices {
        var predicted = 0.0
        for tap in weights.indices { predicted += weights[tap] * (reference[first + row - tap * 4] - means[tap]) }
        let difference = microphone[row] - targetMean - predicted
        residual += difference * difference
      }
      if sqrt(residual / Double(microphone.count)) <= allowed { return true }
    }
    return false
  }

  /// Pivoted elimination of one tiny, ridge-regularised system per capture.
  private static func solve(_ input: [Double], _ target: [Double]) -> [Double]? {
    let n = target.count
    var matrix = input, result = target
    for column in 0..<n {
      var pivot = column
      for row in column..<n where abs(matrix[row * n + column]) > abs(matrix[pivot * n + column]) { pivot = row }
      guard abs(matrix[pivot * n + column]) > 1e-12 else { return nil }
      if pivot != column {
        for j in column..<n { matrix.swapAt(column * n + j, pivot * n + j) }
        result.swapAt(column, pivot)
      }
      for row in (column + 1)..<n {
        let factor = matrix[row * n + column] / matrix[column * n + column]
        for j in column..<n { matrix[row * n + j] -= factor * matrix[column * n + j] }
        result[row] -= factor * result[column]
      }
    }
    for row in stride(from: n - 1, through: 0, by: -1) {
      for column in (row + 1)..<n { result[row] -= matrix[row * n + column] * result[column] }
      result[row] /= matrix[row * n + row]
    }
    return result

  }
}
