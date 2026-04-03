import AVFoundation
import Flutter
import Speech
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var videoProcessingBridge: BanteraVideoProcessingBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    videoProcessingBridge = BanteraVideoProcessingBridge(
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
  }
}

private final class BanteraVideoProcessingBridge {
  private let channel: FlutterMethodChannel

  init(binaryMessenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "bantera/video_processing",
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler(handle)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getSupportedTranscriptionLocales":
      handleGetSupportedTranscriptionLocales(result: result)
    case "prepareVideoForUpload":
      handlePrepareVideoForUpload(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleGetSupportedTranscriptionLocales(result: @escaping FlutterResult) {
    guard #available(iOS 26.0, *) else {
      result(BanteraVideoProcessingError.unsupportedIosVersion.flutterError)
      return
    }

    Task {
      let payload = await BanteraVideoPreparationService.supportedLocalePayload()
      DispatchQueue.main.async {
        result(payload)
      }
    }
  }

  private func handlePrepareVideoForUpload(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard #available(iOS 26.0, *) else {
      result(BanteraVideoProcessingError.unsupportedIosVersion.flutterError)
      return
    }

    guard
      let args = call.arguments as? [String: Any],
      let inputPath = args["inputPath"] as? String,
      let localeIdentifier = args["localeIdentifier"] as? String,
      !inputPath.isEmpty,
      !localeIdentifier.isEmpty
    else {
      result(BanteraVideoProcessingError.invalidArguments.flutterError)
      return
    }

    Task {
      do {
        let response = try await BanteraVideoPreparationService().prepareVideoForUpload(
          inputURL: URL(fileURLWithPath: inputPath),
          localeIdentifier: localeIdentifier
        )
        DispatchQueue.main.async {
          result(response)
        }
      } catch let error as BanteraVideoProcessingError {
        DispatchQueue.main.async {
          result(error.flutterError)
        }
      } catch {
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "video_processing_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      }
    }
  }
}

private enum BanteraVideoProcessingError: LocalizedError {
  case unsupportedIosVersion
  case invalidArguments
  case speechUnavailable
  case unsupportedLocale(String)
  case noAudioTrack
  case transcriptionFailed(String)
  case exportFailed(String)
  case fileAccessFailed(String)

  var errorDescription: String? {
    switch self {
    case .unsupportedIosVersion:
      return "Video transcription requires iOS 26 or later."
    case .invalidArguments:
      return "The selected video could not be prepared."
    case .speechUnavailable:
      return "Speech transcription is not available on this iPhone."
    case let .unsupportedLocale(identifier):
      return "The selected language (\(identifier)) is not available for transcription."
    case .noAudioTrack:
      return "The selected video does not contain an audio track."
    case let .transcriptionFailed(message):
      return message
    case let .exportFailed(message):
      return message
    case let .fileAccessFailed(message):
      return message
    }
  }

  var code: String {
    switch self {
    case .unsupportedIosVersion:
      return "unsupported_ios_version"
    case .invalidArguments:
      return "invalid_arguments"
    case .speechUnavailable:
      return "speech_unavailable"
    case .unsupportedLocale:
      return "unsupported_locale"
    case .noAudioTrack:
      return "no_audio_track"
    case .transcriptionFailed:
      return "transcription_failed"
    case .exportFailed:
      return "export_failed"
    case .fileAccessFailed:
      return "file_access_failed"
    }
  }

  var flutterError: FlutterError {
    FlutterError(code: code, message: errorDescription, details: nil)
  }
}

@available(iOS 26.0, *)
private final class BanteraVideoPreparationService {
  func prepareVideoForUpload(
    inputURL: URL,
    localeIdentifier: String
  ) async throws -> [String: Any] {
    let inputAsset = AVAsset(url: inputURL)
    let locale = try await resolveLocale(identifier: localeIdentifier)
    let transcript = try await transcribe(asset: inputAsset, locale: locale)
    let preparedOutput = try await exportUploadVideo(from: inputURL, asset: inputAsset)
    let metadata = try videoMetadata(for: AVAsset(url: preparedOutput.url), url: preparedOutput.url)

    return [
      "outputPath": preparedOutput.url.path,
      "fileName": preparedOutput.url.lastPathComponent,
      "transcriptText": transcript.text,
      "transcriptLanguage": transcript.localeIdentifier,
      "transcriptLanguageCode": transcript.languageCode,
      "transcriptCues": transcript.cues.map(\.dictionary),
      "durationMs": metadata.durationMs,
      "fileSizeBytes": metadata.fileSizeBytes,
      "videoWidth": metadata.width as Any,
      "videoHeight": metadata.height as Any,
      "contentType": metadata.contentType,
      "shouldDeleteAfterUse": preparedOutput.shouldDeleteAfterUse,
    ]
  }

  static func supportedLocalePayload() async -> [[String: Any]] {
    let supported = await SpeechTranscriber.supportedLocales.sorted {
      localizedName(for: $0) < localizedName(for: $1)
    }
    let installed = await SpeechTranscriber.installedLocales
    let installedIds = Set(installed.map { $0.identifier(.bcp47) })

    return supported.map { locale in
      [
        "identifier": locale.identifier(.bcp47),
        "displayName": Self.localizedName(for: locale),
        "isInstalled": installedIds.contains(locale.identifier(.bcp47)),
      ]
    }
  }

  private struct PreparedOutput {
    let url: URL
    let shouldDeleteAfterUse: Bool
  }

  private struct VideoMetadata {
    let durationMs: Int
    let width: Int?
    let height: Int?
    let fileSizeBytes: Int
    let contentType: String
  }

  private struct TranscriptCuePayload {
    var index: Int
    var startMs: Int
    var endMs: Int
    let text: String

    var dictionary: [String: Any] {
      [
        "index": index,
        "startMs": startMs,
        "endMs": endMs,
        "text": text,
      ]
    }
  }

  private struct PreparedTranscript {
    let text: String
    let localeIdentifier: String
    let languageCode: String
    let cues: [TranscriptCuePayload]
  }

  private func resolveLocale(identifier: String) async throws -> Locale {
    let supported = await SpeechTranscriber.supportedLocales
    if let exact = supported.first(where: {
      $0.identifier(.bcp47).caseInsensitiveCompare(identifier) == .orderedSame
        || $0.identifier.caseInsensitiveCompare(identifier) == .orderedSame
    }) {
      return exact
    }

    let requestedLanguage = identifier
      .replacingOccurrences(of: "_", with: "-")
      .split(separator: "-")
      .first?
      .lowercased()

    if let requestedLanguage,
       let fallback = supported.first(where: {
         $0.language.languageCode?.identifier.lowercased() == requestedLanguage
       }) {
      return fallback
    }

    throw BanteraVideoProcessingError.unsupportedLocale(identifier)
  }

  private func transcribe(asset: AVAsset, locale: Locale) async throws -> PreparedTranscript {
    guard SpeechTranscriber.isAvailable else {
      throw BanteraVideoProcessingError.speechUnavailable
    }

    let transcriber = SpeechTranscriber(
      locale: locale,
      transcriptionOptions: [],
      reportingOptions: [],
      attributeOptions: [.audioTimeRange]
    )

    let installed = await SpeechTranscriber.installedLocales
    let installedIds = Set(installed.map { $0.identifier(.bcp47) })
    if !installedIds.contains(locale.identifier(.bcp47)) {
      if let installRequest = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
        try await installRequest.downloadAndInstall()
      }
    }

    let rawAudioURL = try await extractAudioAsLinearPcmFile(from: asset)
    defer { try? FileManager.default.removeItem(at: rawAudioURL) }

    let rawAudioFile: AVAudioFile
    do {
      rawAudioFile = try AVAudioFile(forReading: rawAudioURL)
    } catch {
      throw BanteraVideoProcessingError.fileAccessFailed(
        "The extracted audio could not be opened for transcription."
      )
    }

    let requiredFormat = await SpeechAnalyzer.bestAvailableAudioFormat(
      compatibleWith: [transcriber],
      considering: nil
    )

    let audioURL: URL
    if let requiredFormat,
       !isEquivalentFormat(rawAudioFile.processingFormat, requiredFormat) {
      do {
        audioURL = try await convertAudioFile(from: rawAudioURL, to: requiredFormat)
      } catch {
        audioURL = rawAudioURL
      }
    } else {
      audioURL = rawAudioURL
    }

    if audioURL != rawAudioURL {
      defer { try? FileManager.default.removeItem(at: audioURL) }
    }

    let audioFile = try openTranscriptionAudioFile(
      primaryURL: audioURL,
      fallbackURL: rawAudioURL
    )

    let analyzer = SpeechAnalyzer(modules: [transcriber])
    try await analyzer.start(inputAudioFile: audioFile, finishAfterFile: true)

    var cues: [TranscriptCuePayload] = []
    var processingError: Error?

    do {
      for try await result in transcriber.results {
        let cleaned = Self.cleanTranscriptSegment(String(result.text.characters))
        guard !cleaned.isEmpty else {
          continue
        }

        let timeRange = result.range
        guard timeRange.start.seconds.isFinite, timeRange.end.seconds.isFinite else {
          continue
        }

        let startMs = max(0, Int((timeRange.start.seconds * 1000).rounded()))
        var endMs = max(startMs + 1, Int((timeRange.end.seconds * 1000).rounded()))
        if endMs <= startMs {
          endMs = startMs + 1
        }

        if let lastIndex = cues.indices.last,
           cues[lastIndex].text == cleaned {
          cues[lastIndex].endMs = max(cues[lastIndex].endMs, endMs)
          continue
        }

        cues.append(
          TranscriptCuePayload(
            index: cues.count,
            startMs: startMs,
            endMs: endMs,
            text: cleaned
          )
        )
      }
    } catch {
      processingError = error
    }

    let normalizedCues = Self.normalizeTranscriptCues(cues)
    let transcript = normalizedCues
      .map(\.text)
      .joined(separator: "\n")
      .trimmingCharacters(in: .whitespacesAndNewlines)

    guard !transcript.isEmpty, !normalizedCues.isEmpty else {
      if let processingError {
        throw BanteraVideoProcessingError.transcriptionFailed(
          processingError.localizedDescription
        )
      }

      throw BanteraVideoProcessingError.transcriptionFailed(
        "No transcript could be generated. Check that the video audio matches the chosen language."
      )
    }

    return PreparedTranscript(
      text: transcript,
      localeIdentifier: locale.identifier(.bcp47),
      languageCode: Self.languageCode(for: locale),
      cues: normalizedCues
    )
  }

  private func extractAudioAsLinearPcmFile(from asset: AVAsset) async throws -> URL {
    guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
      throw BanteraVideoProcessingError.noAudioTrack
    }

    let outputURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("bantera_audio_\(UUID().uuidString)")
      .appendingPathExtension("caf")

    let reader: AVAssetReader
    do {
      reader = try AVAssetReader(asset: asset)
    } catch {
      throw BanteraVideoProcessingError.exportFailed(
        "Bantera could not read the selected video audio."
      )
    }

    let outputSettings: [String: Any] = [
      AVFormatIDKey: kAudioFormatLinearPCM,
      AVSampleRateKey: 16_000.0,
      AVNumberOfChannelsKey: 1,
      AVLinearPCMBitDepthKey: 16,
      AVLinearPCMIsFloatKey: false,
      AVLinearPCMIsBigEndianKey: false,
      AVLinearPCMIsNonInterleaved: false,
    ]

    let trackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
    trackOutput.alwaysCopiesSampleData = false

    guard reader.canAdd(trackOutput) else {
      throw BanteraVideoProcessingError.exportFailed(
        "Bantera could not configure the video audio for transcription."
      )
    }
    reader.add(trackOutput)

    guard reader.startReading() else {
      throw BanteraVideoProcessingError.exportFailed(
        "Bantera could not start reading the video audio."
      )
    }

    let audioFormat = AVAudioFormat(
      commonFormat: .pcmFormatInt16,
      sampleRate: 16_000,
      channels: 1,
      interleaved: true
    )!

    var totalFrames: Int64 = 0
    do {
      let audioFile = try AVAudioFile(
        forWriting: outputURL,
        settings: audioFormat.settings,
        commonFormat: .pcmFormatInt16,
        interleaved: true
      )

      while let sampleBuffer = trackOutput.copyNextSampleBuffer() {
        guard CMSampleBufferDataIsReady(sampleBuffer) else { continue }

        let numSamples = CMSampleBufferGetNumSamples(sampleBuffer)
        guard numSamples > 0, let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
          continue
        }

        var length = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        let status = CMBlockBufferGetDataPointer(
          blockBuffer,
          atOffset: 0,
          lengthAtOffsetOut: nil,
          totalLengthOut: &length,
          dataPointerOut: &dataPointer
        )

        guard status == kCMBlockBufferNoErr, let pointer = dataPointer else {
          continue
        }

        let frameCount = AVAudioFrameCount(numSamples)
        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else {
          continue
        }

        pcmBuffer.frameLength = frameCount
        if let int16Data = pcmBuffer.int16ChannelData {
          memcpy(int16Data[0], pointer, length)
        }

        do {
          try audioFile.write(from: pcmBuffer)
          totalFrames += Int64(frameCount)
        } catch {
          break
        }
      }
    } catch {
      throw BanteraVideoProcessingError.fileAccessFailed(
        "Bantera could not create a temporary transcription audio file."
      )
    }

    if reader.status == .failed || totalFrames == 0 {
      try? FileManager.default.removeItem(at: outputURL)
      throw BanteraVideoProcessingError.transcriptionFailed(
        "The selected video does not contain usable speech audio."
      )
    }

    return outputURL
  }

  private func convertAudioFile(
    from sourceURL: URL,
    to targetFormat: AVAudioFormat
  ) async throws -> URL {
    let outputURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("bantera_audio_\(UUID().uuidString)")
      .appendingPathExtension("caf")

    let sourceFile: AVAudioFile
    do {
      sourceFile = try AVAudioFile(forReading: sourceURL)
    } catch {
      throw BanteraVideoProcessingError.fileAccessFailed(
        "Bantera could not open the extracted audio for conversion."
      )
    }

    let sourceFormat = sourceFile.processingFormat
    guard let converter = AVAudioConverter(from: sourceFormat, to: targetFormat) else {
      return sourceURL
    }

    let outputFile: AVAudioFile
    do {
      outputFile = try AVAudioFile(
        forWriting: outputURL,
        settings: targetFormat.settings,
        commonFormat: targetFormat.commonFormat,
        interleaved: targetFormat.isInterleaved
      )
    } catch {
      throw BanteraVideoProcessingError.fileAccessFailed(
        "Bantera could not create a compatible transcription audio file."
      )
    }

    let bufferSize: AVAudioFrameCount = 4096
    var totalFrames: Int64 = 0

    while sourceFile.framePosition < sourceFile.length {
      let remainingFrames = AVAudioFrameCount(sourceFile.length - sourceFile.framePosition)
      let framesToRead = min(bufferSize, remainingFrames)
      guard let sourceBuffer = AVAudioPCMBuffer(
        pcmFormat: sourceFormat,
        frameCapacity: framesToRead
      ) else {
        continue
      }

      do {
        try sourceFile.read(into: sourceBuffer, frameCount: framesToRead)
      } catch {
        break
      }

      let ratio = targetFormat.sampleRate / sourceFormat.sampleRate
      let outputCapacity = AVAudioFrameCount(Double(framesToRead) * ratio * 1.2)
      guard let outputBuffer = AVAudioPCMBuffer(
        pcmFormat: targetFormat,
        frameCapacity: outputCapacity
      ) else {
        continue
      }

      do {
        try converter.convert(to: outputBuffer, from: sourceBuffer)
        if outputBuffer.frameLength > 0 {
          try outputFile.write(from: outputBuffer)
          totalFrames += Int64(outputBuffer.frameLength)
        }
      } catch {
        break
      }
    }

    if totalFrames == 0 {
      try? FileManager.default.removeItem(at: outputURL)
      throw BanteraVideoProcessingError.transcriptionFailed(
        "Bantera could not convert the selected video audio for transcription."
      )
    }

    return outputURL
  }

  private func openTranscriptionAudioFile(
    primaryURL: URL,
    fallbackURL: URL
  ) throws -> AVAudioFile {
    do {
      return try AVAudioFile(forReading: primaryURL)
    } catch {
      guard primaryURL != fallbackURL else {
        throw BanteraVideoProcessingError.fileAccessFailed(
          "The extracted audio could not be opened for transcription."
        )
      }

      do {
        return try AVAudioFile(forReading: fallbackURL)
      } catch {
        throw BanteraVideoProcessingError.fileAccessFailed(
          "The extracted audio could not be opened for transcription."
        )
      }
    }
  }

  private func isEquivalentFormat(
    _ lhs: AVAudioFormat,
    _ rhs: AVAudioFormat
  ) -> Bool {
    lhs.sampleRate == rhs.sampleRate &&
      lhs.channelCount == rhs.channelCount &&
      lhs.commonFormat == rhs.commonFormat &&
      lhs.isInterleaved == rhs.isInterleaved
  }

  private func exportUploadVideo(from inputURL: URL, asset: AVAsset) async throws -> PreparedOutput {
    let originalMetadata = try videoMetadata(for: asset, url: inputURL)
    let maxDimension = max(originalMetadata.width ?? 0, originalMetadata.height ?? 0)
    let presetName = preferredExportPreset(for: asset, maxDimension: maxDimension)

    guard let exporter = AVAssetExportSession(asset: asset, presetName: presetName) else {
      throw BanteraVideoProcessingError.exportFailed(
        "Bantera could not create a video export session for this file."
      )
    }

    exporter.shouldOptimizeForNetworkUse = true
    let outputFileType: AVFileType
    if exporter.supportedFileTypes.contains(.mp4) {
      outputFileType = .mp4
    } else if exporter.supportedFileTypes.contains(.mov) {
      outputFileType = .mov
    } else {
      outputFileType = exporter.supportedFileTypes.first ?? .mp4
    }

    let fileExtension = outputFileType == .mov ? "mov" : "mp4"
    let outputURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("bantera_video_\(UUID().uuidString)")
      .appendingPathExtension(fileExtension)

    exporter.outputURL = outputURL
    exporter.outputFileType = outputFileType

    do {
      try await exporter.exportAsync()
    } catch {
      throw BanteraVideoProcessingError.exportFailed(
        "Bantera could not create an upload-ready copy of this video."
      )
    }

    let optimizedMetadata = try videoMetadata(for: AVAsset(url: outputURL), url: outputURL)
    if maxDimension <= 1280 && optimizedMetadata.fileSizeBytes >= originalMetadata.fileSizeBytes {
      try? FileManager.default.removeItem(at: outputURL)
      return PreparedOutput(url: inputURL, shouldDeleteAfterUse: false)
    }

    return PreparedOutput(url: outputURL, shouldDeleteAfterUse: true)
  }

  private func preferredExportPreset(for asset: AVAsset, maxDimension: Int) -> String {
    let presets = AVAssetExportSession.exportPresets(compatibleWith: asset)

    if maxDimension > 1280, presets.contains(AVAssetExportPreset1280x720) {
      return AVAssetExportPreset1280x720
    }
    if presets.contains(AVAssetExportPresetMediumQuality) {
      return AVAssetExportPresetMediumQuality
    }
    if presets.contains(AVAssetExportPreset1280x720) {
      return AVAssetExportPreset1280x720
    }
    if presets.contains(AVAssetExportPreset640x480) {
      return AVAssetExportPreset640x480
    }
    return AVAssetExportPresetHighestQuality
  }

  private func videoMetadata(for asset: AVAsset, url: URL) throws -> VideoMetadata {
    let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
    let fileSize = resourceValues.fileSize ?? 0
    let durationMs = Int((max(asset.duration.seconds, 0) * 1000).rounded())

    let track = asset.tracks(withMediaType: .video).first
    let transformed = track?.naturalSize.applying(track?.preferredTransform ?? .identity)
    let width = transformed.map { Int(abs($0.width).rounded()) }
    let height = transformed.map { Int(abs($0.height).rounded()) }

    let contentType: String
    switch url.pathExtension.lowercased() {
    case "mov":
      contentType = "video/quicktime"
    case "m4v":
      contentType = "video/x-m4v"
    default:
      contentType = "video/mp4"
    }

    return VideoMetadata(
      durationMs: durationMs,
      width: width,
      height: height,
      fileSizeBytes: fileSize,
      contentType: contentType
    )
  }

  private static func cleanTranscriptSegment(_ text: String) -> String {
    let flattened = text
      .components(separatedBy: .newlines)
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
      .joined(separator: " ")

    let collapsed = flattened.replacingOccurrences(
      of: #"\s+"#,
      with: " ",
      options: .regularExpression
    )

    var cleaned = collapsed.trimmingCharacters(in: .whitespacesAndNewlines)
    while cleaned.hasSuffix(".") || cleaned.hasSuffix("。") {
      cleaned.removeLast()
    }

    return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private static func normalizeTranscriptCues(
    _ cues: [TranscriptCuePayload]
  ) -> [TranscriptCuePayload] {
    guard !cues.isEmpty else {
      return []
    }

    var normalized: [TranscriptCuePayload] = []
    for cue in cues {
      let text = cleanTranscriptSegment(cue.text)
      guard !text.isEmpty else {
        continue
      }

      var startMs = max(0, cue.startMs)
      var endMs = max(startMs + 1, cue.endMs)

      if let last = normalized.last {
        startMs = max(startMs, last.endMs)
        endMs = max(endMs, startMs + 1)
      }

      if let lastIndex = normalized.indices.last,
         normalized[lastIndex].text == text {
        normalized[lastIndex].endMs = max(normalized[lastIndex].endMs, endMs)
        continue
      }

      normalized.append(
        TranscriptCuePayload(
          index: normalized.count,
          startMs: startMs,
          endMs: endMs,
          text: text
        )
      )
    }

    return normalized
  }

  private static func languageCode(for locale: Locale) -> String {
    if let languageCode = locale.language.languageCode?.identifier {
      return languageCode.lowercased()
    }

    return locale.identifier(.bcp47)
      .replacingOccurrences(of: "_", with: "-")
      .split(separator: "-")
      .first?
      .lowercased() ?? "und"
  }

  private static func localizedName(for locale: Locale) -> String {
    Locale.current.localizedString(forIdentifier: locale.identifier) ?? locale.identifier(.bcp47)
  }
}

private extension AVAssetExportSession {
  func exportAsync() async throws {
    try await withCheckedThrowingContinuation { continuation in
      exportAsynchronously {
        switch self.status {
        case .completed:
          continuation.resume()
        case .failed:
          continuation.resume(throwing: self.error ?? NSError(domain: "Bantera", code: -1))
        case .cancelled:
          continuation.resume(throwing: NSError(domain: "Bantera", code: -2))
        default:
          continuation.resume(throwing: NSError(domain: "Bantera", code: -3))
        }
      }
    }
  }
}
