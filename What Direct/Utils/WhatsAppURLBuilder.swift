import Foundation

enum WhatsAppURLBuilder {
    static func url(from fullNumber: String) -> URL? {
        let cleaned = PhoneNumberFormatter.clean(fullNumber)
        guard !cleaned.isEmpty else { return nil }
        return URL(string: "https://wa.me/\(cleaned)")
    }
}
