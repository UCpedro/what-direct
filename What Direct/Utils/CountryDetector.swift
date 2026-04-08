import Foundation

enum CountryDetector {
    static func detectCountry(from input: String, countries: [Country]) -> Country? {
        let cleaned = PhoneNumberFormatter.clean(input)
        guard !cleaned.isEmpty else { return nil }

        return countries
            .sorted { PhoneNumberFormatter.clean($0.code).count > PhoneNumberFormatter.clean($1.code).count }
            .first { cleaned.hasPrefix(PhoneNumberFormatter.clean($0.code)) }
    }

    static func deviceRegionCountry(from countries: [Country]) -> Country? {
        guard let region = Locale.current.region?.identifier else { return nil }
        return countries.first(where: { $0.isoCode == region })
    }
}
