import Foundation

enum CountryDetector {
    static func detectCountry(from input: String, countries: [Country]) -> Country? {
        let cleaned = PhoneNumberFormatter.clean(input)

        return countries
            .sorted { PhoneNumberFormatter.clean($0.code).count > PhoneNumberFormatter.clean($1.code).count }
            .first { cleaned.hasPrefix(PhoneNumberFormatter.clean($0.code)) }
    }
}
