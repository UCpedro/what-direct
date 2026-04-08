import Foundation

enum PhoneNumberFormatter {
    static func clean(_ input: String) -> String {
        input.filter(\.isNumber)
    }
}
