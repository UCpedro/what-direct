import Combine
import Foundation
import UIKit

final class HomeViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var selectedCountry: Country = .fallback
    @Published var errorMessage: String?
    @Published var recentEntries: [RecentEntry] = []
    @Published var clipboardSuggestion: String?

    let countries: [Country]
    private let minimumPhoneLength = 6
    private let recentHistoryStore: RecentHistoryStore
    private let clipboardManager: ClipboardManager

    init(
        countries: [Country] = Country.defaults,
        recentHistoryStore: RecentHistoryStore = RecentHistoryStore(),
        clipboardManager: ClipboardManager = ClipboardManager()
    ) {
        self.countries = countries
        self.recentHistoryStore = recentHistoryStore
        self.clipboardManager = clipboardManager
        self.recentEntries = recentHistoryStore.load()
        self.clipboardSuggestion = clipboardManager.suggestedNumber()
    }

    var canPasteNumber: Bool {
        clipboardSuggestion != nil
    }

    func syncPhoneNumber(_ input: String) {
        let cleaned = PhoneNumberFormatter.clean(input)
        if phoneNumber != cleaned {
            phoneNumber = cleaned
        }
    }

    func selectCountry(using code: String) {
        selectedCountry = countries.first(where: { $0.code == code }) ?? .fallback
    }

    func refreshClipboardSuggestion() {
        clipboardSuggestion = clipboardManager.suggestedNumber()
    }

    func pasteNumberFromClipboard() {
        guard let clipboardValue = clipboardSuggestion else { return }
        applyPastedNumber(clipboardValue)
        refreshClipboardSuggestion()
    }

    func openWhatsApp() {
        let cleanedNumber = PhoneNumberFormatter.clean(phoneNumber)
        phoneNumber = cleanedNumber

        guard validate(number: cleanedNumber) else { return }

        let fullNumber = fullNumber(for: cleanedNumber)
        guard let url = WhatsAppURLBuilder.url(from: fullNumber) else {
            errorMessage = "No fue posible generar el enlace de WhatsApp."
            return
        }

        saveRecent(fullNumber)
        errorMessage = nil
        UIApplication.shared.open(url)
    }

    func openRecent(_ entry: RecentEntry) {
        guard let url = WhatsAppURLBuilder.url(from: entry.fullNumber) else { return }
        saveRecent(entry.fullNumber)
        errorMessage = nil
        UIApplication.shared.open(url)
    }

    func deleteRecentEntries(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            recentEntries.remove(at: index)
        }
        recentHistoryStore.save(recentEntries)
    }

    private func validate(number: String) -> Bool {
        guard !number.isEmpty else {
            errorMessage = "Ingresa un número telefónico."
            return false
        }

        guard number.count >= minimumPhoneLength else {
            errorMessage = "El número debe tener al menos \(minimumPhoneLength) dígitos."
            return false
        }

        errorMessage = nil
        return true
    }

    private func fullNumber(for number: String) -> String {
        let countryCode = PhoneNumberFormatter.clean(selectedCountry.code)
        return countryCode + number
    }

    private func saveRecent(_ fullNumber: String) {
        let newEntry = RecentEntry(id: UUID(), fullNumber: fullNumber, date: Date())
        recentEntries.removeAll { $0.fullNumber == fullNumber }
        recentEntries.insert(newEntry, at: 0)
        recentEntries = Array(recentEntries.prefix(15))
        recentHistoryStore.save(recentEntries)
    }

    private func applyPastedNumber(_ pastedValue: String) {
        let cleaned = PhoneNumberFormatter.clean(pastedValue)
        guard !cleaned.isEmpty else { return }

        if pastedValue.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("+"),
           let matchedCountry = countries
            .sorted(by: { PhoneNumberFormatter.clean($0.code).count > PhoneNumberFormatter.clean($1.code).count })
            .first(where: { cleaned.hasPrefix(PhoneNumberFormatter.clean($0.code)) }) {
            let countryDigits = PhoneNumberFormatter.clean(matchedCountry.code)
            let localNumber = String(cleaned.dropFirst(countryDigits.count))

            if !localNumber.isEmpty {
                selectedCountry = matchedCountry
                phoneNumber = localNumber
                errorMessage = nil
                return
            }
        }

        phoneNumber = cleaned
        errorMessage = nil
    }
}
