import Foundation

enum ConversationApp: String, Codable, CaseIterable, Identifiable {
    case whatsapp
    case whatsappBusiness
    case sms
    case telegram

    var id: String { rawValue }

    var title: String {
        switch self {
        case .whatsapp:
            return "WhatsApp"
        case .whatsappBusiness:
            return "WhatsApp Business"
        case .sms:
            return "SMS"
        case .telegram:
            return "Telegram"
        }
    }

    var systemImage: String {
        switch self {
        case .whatsapp:
            return "message.fill"
        case .whatsappBusiness:
            return "briefcase.fill"
        case .sms:
            return "message.badge"
        case .telegram:
            return "paperplane.fill"
        }
    }
}

enum ContactCategory: String, Codable, CaseIterable, Identifiable {
    case client
    case supplier
    case personal
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .client:
            return "Cliente"
        case .supplier:
            return "Proveedor"
        case .personal:
            return "Personal"
        case .other:
            return "Otro"
        }
    }
}

enum PhoneValidationState: String, Codable {
    case valid
    case incomplete
    case invalid
}

struct AppSettings: Codable, Hashable {
    var preferredCountryCode: String
    var defaultApp: ConversationApp
    var clipboardSuggestionsEnabled: Bool
    var quickModeEnabled: Bool
    var productivityModeEnabled: Bool
    var favoriteCountryCodes: [String]
    var showSMSShortcut: Bool
    var showTelegramShortcut: Bool

    static let `default` = AppSettings(
        preferredCountryCode: Country.fallback.code,
        defaultApp: .whatsapp,
        clipboardSuggestionsEnabled: true,
        quickModeEnabled: false,
        productivityModeEnabled: false,
        favoriteCountryCodes: [Country.fallback.isoCode],
        showSMSShortcut: true,
        showTelegramShortcut: true
    )
}
