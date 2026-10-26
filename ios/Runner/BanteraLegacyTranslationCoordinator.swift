import Flutter
import SwiftUI
import Translation
import UIKit

/// Translation coordinator using Apple's Translation framework (`TranslationSession`).
/// Used for all iOS 18+ devices. The system manages language model downloads automatically.
@available(iOS 18.0, *)
enum BanteraLegacyTranslationCoordinator {

  struct CueInput {
    let id: String
    let text: String

    init?(dictionary: [String: Any]) {
      let id = dictionary["id"] as? String ?? ""
      let text = dictionary["text"] as? String ?? ""
      guard
        !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      else {
        return nil
      }
      self.id = id
      self.text = text
    }
  }

  struct CueOutput {
    let id: String
    let translatedText: String

    var dictionary: [String: Any] {
      ["id": id, "translatedText": translatedText]
    }
  }

  // Accessed on the main actor. Only requests carrying an ID can be cancelled;
  // independent subtitle/chat translation sessions are unaffected.
  @MainActor private static var pending: [String: LegacyDismissBox] = [:]

  static func cancel(requestId: String, completion: @escaping () -> Void) {
    DispatchQueue.main.async {
      guard let box = pending[requestId] else { completion(); return }
      box.finish(.failure(CancellationError()), afterDismiss: completion)
    }
  }

  // MARK: - Translation

  /// Translates cues using Apple's Translation framework (iOS 18+).
  /// Embeds an invisible SwiftUI host to obtain a `TranslationSession` via
  /// `.translationTask(configuration:)`, then translates each cue individually.
  static func translate(
    cues: [CueInput],
    sourceLocaleIdentifier: String,
    targetLocaleIdentifier: String,
    prepareOnly: Bool = false,
    requestId: String? = nil,
    completion: @escaping (Result<[CueOutput], Error>) -> Void
  ) {
    let normalizedSource = normalizeIdentifier(sourceLocaleIdentifier)
    let normalizedTarget = normalizeIdentifier(targetLocaleIdentifier)
    let sourceLanguage = Locale.Language(identifier: normalizedSource)
    let targetLanguage = Locale.Language(identifier: normalizedTarget)

    DispatchQueue.main.async {
      let box = LegacyDismissBox()
      box.onFinish = { outcome in
        if let requestId, pending[requestId] === box {
          pending.removeValue(forKey: requestId)
        }
        completion(outcome)
      }
      if let requestId { pending[requestId] = box }
      Task { @MainActor in
        guard !box.finished else { return }
        let status = await LanguageAvailability().status(from: sourceLanguage, to: targetLanguage)
        guard !box.finished else { return }
        guard status == .installed || status == .supported else {
          box.finish(.failure(BanteraTranslationError.unsupportedLanguagePair(
            source: normalizedSource, target: normalizedTarget)))
          return
        }
        if prepareOnly && status == .installed {
          box.finish(.success([]))
          return
        }
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene =
          scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
        guard
          let scene,
          let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else {
          box.finish(
            .failure(
              BanteraTranslationError.translationFailed(
                "Could not open translation. Try again."
              )
            )
          )
          return
        }

        let presenter = topViewController(from: root)
        let rootView = LegacyTranslationView(
          source: sourceLanguage,
          target: targetLanguage,
          cues: cues,
          prepareOnly: prepareOnly,
          onComplete: { result in
            box.finish(result)
          }
        )
        let host = UIHostingController(rootView: rootView)
        box.controller = host
        // A full-screen presented host blocks taps on the Flutter page while
        // models download. Embed a non-interactive child so language selection
        // remains available without interrupting unrelated modal flows.
        presenter.addChild(host)
        host.view.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        host.view.backgroundColor = .clear
        host.view.isUserInteractionEnabled = false
        presenter.view.addSubview(host.view)
        host.didMove(toParent: presenter)
      }
    }
  }

  // MARK: - Language lists

  /// Existing profile picker catalog, not a pair availability or installation check.
  /// Translation flows must query `supportedLocalesPayload` before using a pair.
  static func allLocalesPayload() -> [[String: Any]] {
    let displayLocale = Locale.current
    return cloudSupportedLanguageIdentifiers
      .map { id -> [String: Any] in
        let name = displayLocale.localizedString(forIdentifier: id) ?? id
        return ["identifier": id, "displayName": name, "isInstalled": true]
      }
      .sorted {
        let l = ($0["displayName"] as? String) ?? ""
        let r = ($1["displayName"] as? String) ?? ""
        return l.localizedCaseInsensitiveCompare(r) == .orderedAscending
      }
  }

  /// Query actual source/target pair support and model installation on this device.
  static func supportedLocalesPayload(excluding sourceIdentifier: String) async -> [[String: Any]] {
    let source = Locale.Language(identifier: normalizeIdentifier(sourceIdentifier))
    let availability = LanguageAvailability()
    let languages = await availability.supportedLanguages
    let displayLocale = Locale.current
    var payload: [[String: Any]] = []
    for target in languages {
      let status = await availability.status(from: source, to: target)
      guard status == .installed || status == .supported else { continue }
      let id = target.minimalIdentifier
      payload.append([
        "identifier": id,
        "displayName": displayLocale.localizedString(forIdentifier: id) ?? id,
        "isInstalled": status == .installed,
      ])
    }
    return payload.sorted {
      ($0["displayName"] as? String ?? "").localizedCaseInsensitiveCompare(
        $1["displayName"] as? String ?? "") == .orderedAscending
    }
  }

  // MARK: - Helpers

  private static func topViewController(from root: UIViewController) -> UIViewController {
    if let presented = root.presentedViewController {
      return topViewController(from: presented)
    }
    return root
  }

  static func normalizeIdentifier(_ identifier: String) -> String {
    let normalized = identifier
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "_", with: "-")
    if ["zh-hk", "zh-hant-hk"].contains(normalized.lowercased()) { return "yue-HK" }
    return normalized
  }

  /// Existing profile-language catalog. Pair pickers use device availability above.
  private static let cloudSupportedLanguageIdentifiers: [String] = [
    "ar", "zh", "nl", "en", "fr", "de", "id", "it", "ja", "ko",
    "pl", "pt", "ru", "es", "th", "tr", "uk", "vi",
  ]
}

// MARK: - Private helpers

@available(iOS 18.0, *)
final class LegacyDismissBox {
  weak var controller: UIViewController?
  var onFinish: ((Result<[BanteraLegacyTranslationCoordinator.CueOutput], Error>) -> Void)?
  private(set) var finished = false
  private var dismissed = false
  private var dismissalWaiters: [() -> Void] = []

  func finish(
    _ result: Result<[BanteraLegacyTranslationCoordinator.CueOutput], Error>,
    afterDismiss: @escaping () -> Void = {}
  ) {
    if dismissed { afterDismiss(); return }
    dismissalWaiters.append(afterDismiss)
    guard !finished else { return }
    finished = true
    let notify = onFinish
    onFinish = nil
    let complete = {
      self.dismissed = true
      notify?(result)
      let waiters = self.dismissalWaiters
      self.dismissalWaiters.removeAll()
      waiters.forEach { $0() }
    }
    guard let controller else { complete(); return }
    // Removing the host cancels its SwiftUI translation task. The system may
    // keep a shared language-model download running independently.
    if controller.parent != nil {
      controller.willMove(toParent: nil)
      controller.view.removeFromSuperview()
      controller.removeFromParent()
      complete()
    } else {
      controller.dismiss(animated: false, completion: complete)
    }
  }
}

@available(iOS 18.0, *)
private struct LegacyTranslationView: View {
  let source: Locale.Language
  let target: Locale.Language
  let cues: [BanteraLegacyTranslationCoordinator.CueInput]
  let prepareOnly: Bool
  let onComplete: (Result<[BanteraLegacyTranslationCoordinator.CueOutput], Error>) -> Void

  @State private var configuration: TranslationSession.Configuration?

  var body: some View {
    Color.clear
      .frame(width: 1, height: 1)
      .translationTask(configuration) { session in
        do {
          if prepareOnly {
            try await session.prepareTranslation()
            await MainActor.run { onComplete(.success([])) }
            return
          }
          let requests = cues.map {
            TranslationSession.Request(sourceText: $0.text, clientIdentifier: $0.id)
          }
          var results: [BanteraLegacyTranslationCoordinator.CueOutput] = []
          for try await response in session.translate(batch: requests) {
            guard let id = response.clientIdentifier else { continue }
            results.append(
              BanteraLegacyTranslationCoordinator.CueOutput(
                id: id,
                translatedText: Self.cleanText(response.targetText)
              )
            )
          }
          await MainActor.run {
            onComplete(.success(results))
          }
        } catch {
          let banteraError: BanteraTranslationError
          if TranslationError.unsupportedSourceLanguage ~= error
              || TranslationError.unsupportedTargetLanguage ~= error
              || TranslationError.unsupportedLanguagePairing ~= error {
            banteraError = .unsupportedLanguagePair(
              source: source.minimalIdentifier, target: target.minimalIdentifier)
          } else if #available(iOS 26.0, *), TranslationError.notInstalled ~= error {
            banteraError = .translationAssetsNotInstalled(
              source: source.minimalIdentifier, target: target.minimalIdentifier)
          } else {
            // Cancellation or a translation failure must not reopen a download sheet.
            banteraError = .translationFailed("Translation could not be completed. Please try again.")
          }
          await MainActor.run {
            onComplete(.failure(banteraError))
          }
        }
      }
      .onAppear {
        configuration = TranslationSession.Configuration(source: source, target: target)
      }
  }

  private static func cleanText(_ text: String) -> String {
    text
      .replacingOccurrences(of: "\r\n", with: "\n")
      .replacingOccurrences(of: "\r", with: "\n")
      .split(separator: "\n")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
      .joined(separator: "\n")
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
