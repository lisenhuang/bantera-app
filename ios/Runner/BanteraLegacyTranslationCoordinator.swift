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

  // MARK: - Translation

  /// Translates cues using Apple's Translation framework (iOS 18+).
  /// Presents an invisible SwiftUI host to obtain a `TranslationSession` via
  /// `.translationTask(configuration:)`, then translates each cue individually.
  static func translate(
    cues: [CueInput],
    sourceLocaleIdentifier: String,
    targetLocaleIdentifier: String,
    completion: @escaping (Result<[CueOutput], Error>) -> Void
  ) {
    let normalizedSource = normalizeIdentifier(sourceLocaleIdentifier)
    let normalizedTarget = normalizeIdentifier(targetLocaleIdentifier)
    let sourceLanguage = Locale.Language(identifier: normalizedSource)
    let targetLanguage = Locale.Language(identifier: normalizedTarget)

    Task { @MainActor in
      let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
      let scene =
        scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
      guard
        let scene,
        let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
      else {
        completion(
          .failure(
            BanteraTranslationError.translationFailed(
              "Could not open translation. Try again."
            )
          )
        )
        return
      }

      let presenter = topViewController(from: root)
      let box = LegacyDismissBox()
      let rootView = LegacyTranslationView(
        source: sourceLanguage,
        target: targetLanguage,
        cues: cues,
        onComplete: { result in
          box.dismiss()
          completion(result)
        }
      )
      let host = UIHostingController(rootView: rootView)
      box.controller = host
      host.modalPresentationStyle = .overFullScreen
      host.view.backgroundColor = .clear
      presenter.present(host, animated: false)
    }
  }

  // MARK: - Language list (hardcoded — Translation framework has no public API to enumerate supported languages)

  /// Returns all supported translation locales as a Flutter-ready payload.
  /// All languages are marked `isInstalled: true` since the Translation framework manages downloads automatically.
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

  /// Returns supported target locales excluding the source language.
  static func supportedLocalesPayload(excluding sourceIdentifier: String) -> [[String: Any]] {
    let normalizedSource = normalizeIdentifier(sourceIdentifier)
    let sourceLang = normalizedSource.components(separatedBy: "-").first ?? normalizedSource
    let displayLocale = Locale.current

    return cloudSupportedLanguageIdentifiers
      .filter { id in
        let langPart = id.components(separatedBy: "-").first ?? id
        return langPart != sourceLang
      }
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

  // MARK: - Helpers

  private static func topViewController(from root: UIViewController) -> UIViewController {
    if let presented = root.presentedViewController {
      return topViewController(from: presented)
    }
    return root
  }

  static func normalizeIdentifier(_ identifier: String) -> String {
    identifier
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "_", with: "-")
  }

  /// Languages supported by Apple's Translation framework.
  /// Apple does not expose a public API to enumerate these, so the list is hardcoded.
  private static let cloudSupportedLanguageIdentifiers: [String] = [
    "ar", "zh", "nl", "en", "fr", "de", "id", "it", "ja", "ko",
    "pl", "pt", "ru", "es", "th", "tr", "uk", "vi",
  ]
}

// MARK: - Private helpers

@available(iOS 18.0, *)
private final class LegacyDismissBox {
  weak var controller: UIViewController?

  func dismiss() {
    controller?.dismiss(animated: true)
  }
}

@available(iOS 18.0, *)
private struct LegacyTranslationView: View {
  let source: Locale.Language
  let target: Locale.Language
  let cues: [BanteraLegacyTranslationCoordinator.CueInput]
  let onComplete: (Result<[BanteraLegacyTranslationCoordinator.CueOutput], Error>) -> Void

  @State private var configuration: TranslationSession.Configuration?

  var body: some View {
    Color.clear
      .frame(width: 1, height: 1)
      .translationTask(configuration) { session in
        do {
          var results: [BanteraLegacyTranslationCoordinator.CueOutput] = []
          for cue in cues {
            let response = try await session.translate(cue.text)
            results.append(
              BanteraLegacyTranslationCoordinator.CueOutput(
                id: cue.id,
                translatedText: Self.cleanText(response.targetText)
              )
            )
          }
          await MainActor.run {
            onComplete(.success(results))
          }
        } catch {
          let banteraError: BanteraTranslationError
          let nsError = error as NSError
          // Apple's Translation framework uses a "Translation"-prefixed error domain when
          // language models are not downloaded or the user cancels the download prompt.
          // Remapping to translationAssetsNotInstalled lets Flutter re-trigger the sheet.
          if nsError.domain.hasPrefix("Translation") {
            banteraError = .translationAssetsNotInstalled(
              source: source.minimalIdentifier,
              target: target.minimalIdentifier
            )
          } else {
            banteraError = .translationFailed(error.localizedDescription)
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
