import Flutter
import SwiftUI
import UIKit
@preconcurrency import Translation

/// Shared with `BanteraTranslationBridge` / `BanteraTranslationService` in AppDelegate.swift.
enum BanteraTranslationError: LocalizedError {
  case unsupportedIosVersion
  case invalidArguments
  case unsupportedLanguagePair(source: String, target: String)
  case translationUnavailable
  case translationFailed(String)
  /// On-device language pack not downloaded yet; use `prepareTranslationAssets` (SwiftUI) first.
  case translationAssetsNotInstalled(source: String, target: String)

  var errorDescription: String? {
    switch self {
    case .unsupportedIosVersion:
      return "Cue translation requires iOS 26 or later."
    case .invalidArguments:
      return "The translation request was missing required cue or language data."
    case let .unsupportedLanguagePair(source, target):
      return "iPhone translation is not available from \(source) to \(target) for this practice session."
    case .translationUnavailable:
      return "Translation is not available on this iPhone right now."
    case let .translationFailed(message):
      return message
    case let .translationAssetsNotInstalled(_, target):
      return
        "Download the translation language for \(target) when prompted, then try again."
    }
  }

  var code: String {
    switch self {
    case .unsupportedIosVersion:
      return "unsupported_ios_version"
    case .invalidArguments:
      return "invalid_arguments"
    case .unsupportedLanguagePair:
      return "unsupported_language_pair"
    case .translationUnavailable:
      return "translation_unavailable"
    case .translationFailed:
      return "translation_failed"
    case .translationAssetsNotInstalled:
      return "translation_assets_not_installed"
    }
  }

  var flutterError: FlutterError {
    FlutterError(code: code, message: errorDescription, details: nil)
  }
}

/// Presents a minimal SwiftUI host so `.translationTask` can run; `prepareTranslation()`
/// must run on a session from this task (not a manually created `TranslationSession`) so
/// iOS can show the system language download UI.
@available(iOS 26.0, *)
enum BanteraTranslationPrepareCoordinator {
  static func prepareAssets(
    sourceLocaleIdentifier: String,
    targetLocaleIdentifier: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let normalizedSource = normalizeIdentifier(sourceLocaleIdentifier)
    let normalizedTarget = normalizeIdentifier(targetLocaleIdentifier)
    let sourceLanguage = Locale.Language(identifier: normalizedSource)
    let targetLanguage = Locale.Language(identifier: normalizedTarget)

    Task {
      do {
        let availability = LanguageAvailability()
        let status = await availability.status(from: sourceLanguage, to: targetLanguage)
        switch status {
        case .installed:
          await MainActor.run {
            completion(.success(()))
          }
        case .supported:
          await MainActor.run {
            presentPrepareSheet(
              source: sourceLanguage,
              target: targetLanguage,
              completion: completion
            )
          }
        default:
          throw BanteraTranslationError.unsupportedLanguagePair(
            source: normalizedSource,
            target: normalizedTarget
          )
        }
      } catch {
        await MainActor.run {
          completion(.failure(error))
        }
      }
    }
  }

  @MainActor
  private static func presentPrepareSheet(
    source: Locale.Language,
    target: Locale.Language,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
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
            "Could not open the translation download screen. Try again."
          )
        )
      )
      return
    }

    let presenter = topViewController(from: root)
    let box = PrepareDismissBox()
    let rootView = PrepareTranslationRootView(
      source: source,
      target: target,
      onComplete: { result in
        box.dismiss()
        completion(result)
      }
    )
    let host = UIHostingController(rootView: rootView)
    box.controller = host
    host.modalPresentationStyle = .overFullScreen
    host.view.backgroundColor = UIColor.clear
    presenter.present(host, animated: false)
  }

  private static func topViewController(from root: UIViewController) -> UIViewController {
    if let presented = root.presentedViewController {
      return topViewController(from: presented)
    }
    return root
  }

  private static func normalizeIdentifier(_ identifier: String) -> String {
    identifier
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "_", with: "-")
  }
}

@available(iOS 26.0, *)
private final class PrepareDismissBox {
  weak var controller: UIViewController?

  func dismiss() {
    controller?.dismiss(animated: true)
  }
}

@available(iOS 26.0, *)
private struct PrepareTranslationRootView: View {
  let source: Locale.Language
  let target: Locale.Language
  let onComplete: (Result<Void, Error>) -> Void

  var body: some View {
    Color.clear
      .frame(width: 1, height: 1)
      // iOS 26 uses `translationTask(source:target:)`; the `Configuration`+`Binding` overload
      // no longer matches this call site.
      .translationTask(source: source, target: target) { session in
        Task {
          do {
            try await session.prepareTranslation()
            await MainActor.run {
              onComplete(.success(()))
            }
          } catch {
            await MainActor.run {
              onComplete(.failure(error))
            }
          }
        }
      }
  }
}
