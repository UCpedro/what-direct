import Foundation

enum WhatsAppURLBuilder {
    static func url(from fullNumber: String, message: String? = nil) -> URL? {
        let cleaned = PhoneNumberFormatter.clean(fullNumber)
        guard !cleaned.isEmpty else { return nil }

        var components = URLComponents(string: "https://wa.me/\(cleaned)")
        if let message, !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            components?.queryItems = [
                URLQueryItem(name: "text", value: message)
            ]
        }

        return components?.url
    }
}
