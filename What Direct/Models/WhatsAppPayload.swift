import Foundation

struct WhatsAppPayload: Hashable {
    let fullNumber: String
    let url: URL
    let cleanNumber: String
}
