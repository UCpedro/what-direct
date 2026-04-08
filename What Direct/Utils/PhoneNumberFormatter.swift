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
        let digits = clean(fullNumber)
        guard !digits.isEmpty else { return "" }

        var chunks: [String] = []
        var currentIndex = digits.startIndex

        while currentIndex < digits.endIndex {
            let nextIndex = digits.index(currentIndex, offsetBy: 3, limitedBy: digits.endIndex) ?? digits.endIndex
            chunks.append(String(digits[currentIndex..<nextIndex]))
            currentIndex = nextIndex
        }

        return "+" + chunks.joined(separator: " ")
    }

    static func payload(
        for input: String,
        selectedCountry: Country,
        countries: [Country]
    ) -> WhatsAppPayload {
        let cleanedInput = clean(input)
        let containsInvalidCharacters = input.contains { character in
            !character.isNumber && !character.isWhitespace && character != "+" && character != "-" && character != "(" && character != ")"
        }

        let detectedCountry = CountryDetector.detectCountry(from: cleanedInput, countries: countries)
        let effectiveCountry = detectedCountry ?? selectedCountry
        let countryDigits = clean(effectiveCountry.code)

        let fullNumber: String
        if cleanedInput.hasPrefix(countryDigits) {
            fullNumber = cleanedInput
        } else {
            fullNumber = countryDigits + cleanedInput
        }

        let validationState: PhoneValidationState
        let validationMessage: String

        if cleanedInput.isEmpty {
            validationState = .invalid
            validationMessage = "Ingresa un número para continuar."
        } else if containsInvalidCharacters {
            validationState = .invalid
            validationMessage = "El número tenía caracteres no válidos. Revisa el texto pegado."
        } else if cleanedInput.count < 6 {
            validationState = .incomplete
            validationMessage = "El número parece incompleto todavía."
        } else if clean(fullNumber).count > 15 {
            validationState = .invalid
            validationMessage = "El número es demasiado largo para un formato internacional válido."
        } else {
            validationState = .valid
            validationMessage = detectedCountry == nil
                ? "Usaremos \(selectedCountry.flag) \(selectedCountry.code) como prefijo."
                : "Detectamos \(effectiveCountry.flag) \(effectiveCountry.name) automáticamente."
        }

        return WhatsAppPayload(
            rawInput: input,
            cleanedInput: cleanedInput,
            fullNumber: fullNumber,
            displayNumber: display(fullNumber),
            selectedCountry: effectiveCountry,
            detectedCountry: detectedCountry,
            validationState: validationState,
            validationMessage: validationMessage,
            waURL: WhatsAppURLBuilder.url(from: fullNumber)
        )
    }
}
