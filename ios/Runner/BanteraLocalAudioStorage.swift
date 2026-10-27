import AVFoundation
import Flutter

/// File-only codecs. Never activates, configures or interrupts AVAudioSession.
final class BanteraLocalAudioStorage {
  static func register(_ messenger: FlutterBinaryMessenger) {
    let queue = DispatchQueue(label: "bantera.local-audio-storage", qos: .utility)
    FlutterMethodChannel(name: "bantera/local_audio_storage", binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        guard let args = call.arguments as? [String: String],
              let input = args["input"] else {
          result(FlutterError(code: "invalid_audio", message: "Missing audio.", details: nil)); return
        }
        let worker = call.method == "decodeVoice" ? DispatchQueue.global(qos: .userInitiated) : queue
        worker.async {
          do {
            let value: Any
            switch call.method {
            case "compress":
              guard let output = args["output"] else { throw CodecError.invalid }
              try LocalAudioCodec.compress(URL(fileURLWithPath: input), to: URL(fileURLWithPath: output))
              value = true
            case "decodeVoice":
              value = FlutterStandardTypedData(bytes: try LocalAudioCodec.voicePcm(URL(fileURLWithPath: input)))
            default:
              DispatchQueue.main.async { result(FlutterMethodNotImplemented) }; return
            }
            DispatchQueue.main.async { result(value) }
          } catch {
            DispatchQueue.main.async { result(FlutterError(code: "audio_conversion_failed", message: "Could not convert audio.", details: nil)) }
          }
        }
      }
  }
}

private enum CodecError: Error { case invalid }

// Kept independent of Flutter/audio sessions so the real codec can be tested.
enum LocalAudioCodec {
  static func compress(_ source: URL, to destination: URL) throws {
    let input = try AVAudioFile(forReading: source)
    let format = input.processingFormat
    guard input.fileFormat.streamDescription.pointee.mFormatID == kAudioFormatLinearPCM,
          input.length > 0, (1...2).contains(format.channelCount) else { throw CodecError.invalid }
    let duration = Double(input.length) / format.sampleRate
    // Use the standard AAC sample rate, also for 16/24 kHz Live PCM inputs.
    // AssetReader performs resampling without an AVAudioEngine/audio session.
    let asset = AVURLAsset(url: source)
    guard let track = asset.tracks(withMediaType: .audio).first else { throw CodecError.invalid }
    let reader = try AVAssetReader(asset: asset)
    let decoded = AVAssetReaderTrackOutput(track: track, outputSettings: [
      AVFormatIDKey: kAudioFormatLinearPCM, AVSampleRateKey: 44100,
      AVNumberOfChannelsKey: format.channelCount, AVLinearPCMBitDepthKey: 16,
      AVLinearPCMIsFloatKey: false, AVLinearPCMIsBigEndianKey: false,
      AVLinearPCMIsNonInterleaved: false,
    ])
    reader.add(decoded)
    let writer = try AVAssetWriter(outputURL: destination, fileType: .m4a)
    let encoded = AVAssetWriterInput(mediaType: .audio, outputSettings: [
      AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 44100,
      AVNumberOfChannelsKey: format.channelCount,
      AVEncoderBitRateKey: 64000 * Int(format.channelCount),
    ])
    writer.add(encoded)
    guard writer.startWriting(), reader.startReading() else { throw CodecError.invalid }
    defer {
      if reader.status == .reading { reader.cancelReading() }
      if writer.status == .writing { writer.cancelWriting() }
    }
    writer.startSession(atSourceTime: .zero)
    let deadline = Date().addingTimeInterval(120)
    while reader.status == .reading {
      guard Date() < deadline, writer.status == .writing else { throw CodecError.invalid }
      if !encoded.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.002); continue }
      guard let sample = decoded.copyNextSampleBuffer() else { break }
      guard encoded.append(sample) else { throw writer.error ?? CodecError.invalid }
    }
    guard reader.status == .completed else { throw reader.error ?? CodecError.invalid }
    encoded.markAsFinished()
    let finished = DispatchSemaphore(value: 0)
    writer.finishWriting { finished.signal() }
    guard finished.wait(timeout: .now() + 30) == .success,
          writer.status == .completed else { throw writer.error ?? CodecError.invalid }
    let check = try AVAudioFile(forReading: destination)
    guard check.fileFormat.streamDescription.pointee.mFormatID == kAudioFormatMPEG4AAC,
          check.processingFormat.channelCount == format.channelCount,
          abs(Double(check.length) / check.processingFormat.sampleRate - duration) <= max(0.15, duration * 0.01),
          let buffer = AVAudioPCMBuffer(pcmFormat: check.processingFormat, frameCapacity: 8192)
    else { throw CodecError.invalid }
    var frames: AVAudioFramePosition = 0
    while check.framePosition < check.length {
      try check.read(into: buffer)
      guard buffer.frameLength > 0 else { throw CodecError.invalid }
      frames += AVAudioFramePosition(buffer.frameLength)
    }
    guard frames > 0 else { throw CodecError.invalid }
  }

  static func voicePcm(_ source: URL) throws -> Data {
    let asset = AVURLAsset(url: source)
    guard let track = asset.tracks(withMediaType: .audio).first else { throw CodecError.invalid }
    let reader = try AVAssetReader(asset: asset)
    let output = AVAssetReaderTrackOutput(track: track, outputSettings: [
      AVFormatIDKey: kAudioFormatLinearPCM, AVSampleRateKey: 16000,
      AVNumberOfChannelsKey: 1, AVLinearPCMBitDepthKey: 16,
      AVLinearPCMIsFloatKey: false, AVLinearPCMIsBigEndianKey: false,
      AVLinearPCMIsNonInterleaved: false,
    ])
    reader.add(output)
    guard reader.startReading() else { throw CodecError.invalid }
    var data = Data()
    while let sample = output.copyNextSampleBuffer() {
      guard let block = CMSampleBufferGetDataBuffer(sample) else { throw CodecError.invalid }
      let size = CMBlockBufferGetDataLength(block)
      // Voice recordings are short. Reject unreasonable retry files, not OOM.
      guard data.count + size <= 64 * 1024 * 1024 else { reader.cancelReading(); throw CodecError.invalid }
      var bytes = [UInt8](repeating: 0, count: size)
      guard CMBlockBufferCopyDataBytes(block, atOffset: 0, dataLength: size, destination: &bytes) == noErr else { throw CodecError.invalid }
      data.append(contentsOf: bytes)
    }
    guard reader.status == .completed, !data.isEmpty else { throw CodecError.invalid }
    return data
  }
}
