import Foundation

struct WhatsAppPayload: Hashable {
    let rawInput: String
    let cleanedInput: String
    let fullNumber: String
    let displayNumber: String
    let selectedCountry: Country
    let detectedCountry: Country?
    let validationState: PhoneValidationState
    let validationMessage: String
    let waURL: URL?

    var cleanNumber: String {
        PhoneNumberFormatter.clean(fullNumber)
    }

    var canOpenConversation: Bool {
        validationState == .valid && waURL != nil
    }
}
