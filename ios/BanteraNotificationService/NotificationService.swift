import UserNotifications
import Intents
import UIKit
import ImageIO

/// Personalizes message alerts only. VoIP/CallKit payloads never enter this path.
final class NotificationService: UNNotificationServiceExtension {
    private let lock = NSLock()
    private var handler: ((UNNotificationContent) -> Void)?
    private var original: UNNotificationContent?
    private var task: URLSessionDataTask?

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        lock.lock()
        handler = contentHandler
        original = request.content
        lock.unlock()
        let info = request.content.userInfo
        guard let senderID = info["senderId"] as? String, UUID(uuidString: senderID) != nil,
              let name = info["senderName"] as? String, !name.isEmpty,
              let threadID = info["threadId"] as? String,
              let raw = info["senderAvatarUrl"] as? String,
              let url = URL(string: raw), url.scheme == "https", url.host == "api.bantera.app",
              url.path == "/api/users/\(senderID)/avatar" else {
            finish(request.content)
            return
        }
        var download = URLRequest(url: url)
        download.timeoutInterval = 5
        task = URLSession.shared.dataTask(with: download) { [weak self] data, response, _ in
            guard let self else { return }
            guard let http = response as? HTTPURLResponse, http.statusCode == 200,
                  http.url?.host == "api.bantera.app",
                  let data, data.count <= 5 * 1024 * 1024,
                  let source = CGImageSourceCreateWithData(data as CFData, nil),
                  let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceThumbnailMaxPixelSize: 256,
                    kCGImageSourceCreateThumbnailWithTransform: true
                  ] as CFDictionary),
                  let png = UIImage(cgImage: thumbnail).pngData() else {
                self.finish(request.content)
                return
            }
            let image = INImage(imageData: png)
            let sender = INPerson(personHandle: INPersonHandle(value: senderID, type: .unknown),
                                  nameComponents: nil, displayName: name, image: image,
                                  contactIdentifier: nil, customIdentifier: senderID)
            let group = info["threadType"] as? String == "group"
            let intent = INSendMessageIntent(recipients: nil, outgoingMessageType: info["messageKind"] as? String == "image" ? .outgoingMessageText : .outgoingMessageAudio,
                content: request.content.body,
                speakableGroupName: group ? INSpeakableString(spokenPhrase: request.content.title) : nil,
                conversationIdentifier: threadID, serviceName: nil, sender: sender, attachments: nil)
            intent.setImage(image, forParameterNamed: \.sender)
            let interaction = INInteraction(intent: intent, response: nil)
            interaction.direction = .incoming
            interaction.donate { _ in
                let updated = (try? request.content.updating(from: intent)) ?? request.content
                self.finish(updated)
            }
        }
        task?.resume()
    }

    override func serviceExtensionTimeWillExpire() {
        task?.cancel()
        if let original { finish(original) }
    }

    private func finish(_ content: UNNotificationContent) {
        lock.lock()
        let completion = handler
        handler = nil
        lock.unlock()
        completion?(content)
    }
}
