import Foundation
import UIKit

enum ConversationLaunchResult: Equatable {
    case success
    case appUnavailable(String)
    case invalidNumber(String)
}

struct ConversationLauncher {
    func canOpen(_ app: ConversationApp) -> Bool {
        guard let url = probeURL(for: app) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    func launch(app: ConversationApp, payload: WhatsAppPayload, message: String?) -> ConversationLaunchResult {
        guard payload.validationState == .valid else {
            return .invalidNumber(payload.validationMessage)
        }

        guard let url = url(for: app, payload: payload, message: message) else {
            return .invalidNumber("No fue posible construir el enlace para \(app.title).")
        }

        if app == .whatsappBusiness || app == .whatsapp || app == .telegram {
            guard canOpen(app) else {
                return .appUnavailable("\(app.title) no parece estar instalada en este iPhone.")
            }
        }

        UIApplication.shared.open(url)
        return .success
    }

    func shareableLink(for payload: WhatsAppPayload, message: String?) -> URL? {
        WhatsAppURLBuilder.url(from: payload.fullNumber, message: message)
    }

    private func url(for app: ConversationApp, payload: WhatsAppPayload, message: String?) -> URL? {
        let number = payload.cleanNumber
        let encodedMessage = message?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        switch app {
        case .whatsapp:
            guard !number.isEmpty else { return nil }
            var components = URLComponents()
            components.scheme = "whatsapp"
            components.host = "send"
            components.queryItems = [
                URLQueryItem(name: "phone", value: number),
                URLQueryItem(name: "text", value: message)
            ]
            return components.url
        case .whatsappBusiness:
            guard !number.isEmpty else { return nil }
            var components = URLComponents()
            components.scheme = "whatsapp-business"
            components.host = "send"
            components.queryItems = [
                URLQueryItem(name: "phone", value: number),
                URLQueryItem(name: "text", value: message)
            ]
            return components.url
        case .sms:
            guard !number.isEmpty else { return nil }
            let body = encodedMessage.isEmpty ? "" : "&body=\(encodedMessage)"
            return URL(string: "sms:\(number)\(body)")
        case .telegram:
            guard !number.isEmpty else { return nil }
            let textQuery = encodedMessage.isEmpty ? "" : "&text=\(encodedMessage)"
            return URL(string: "tg://resolve?phone=\(number)\(textQuery)")
        }
    }

    private func probeURL(for app: ConversationApp) -> URL? {
        switch app {
        case .whatsapp:
            return URL(string: "whatsapp://")
        case .whatsappBusiness:
            return URL(string: "whatsapp-business://")
        case .sms:
            return URL(string: "sms:")
        case .telegram:
            return URL(string: "tg://")
        }
    }
}
