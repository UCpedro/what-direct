import Foundation

enum PhoneNumberFormatter {
    static func clean(_ input: String) -> String {
        input.filter(\.isNumber)
    }

    static func probableClipboardNumber(from input: String?) -> String? {
        guard let input else { return nil }
        let cleaned = clean(input)
        guard cleaned.count >= 6, cleaned.count <= 15 else { return nil }
        return cleaned
    }

    static func display(_ fullNumber: String) -> String {
        "+\(clean(fullNumber))"
    }
}
