import Combine
import Foundation
import UIKit

final class HomeViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var selectedCountry: Country = .fallback
    @Published var errorMessage: String?
    @Published var recentEntries: [RecentEntry] = []
    @Published var clipboardSuggestion: String?
    @Published var templates: [MessageTemplate] = []
    @Published var selectedTemplateID: UUID?

    let countries: [Country]
    private let minimumPhoneLength = 6
    private let recentHistoryStore: RecentHistoryStore
    private let clipboardManager: ClipboardManager
    private let templateStore: TemplateStore

    init(
        countries: [Country] = Country.defaults,
        recentHistoryStore: RecentHistoryStore = RecentHistoryStore(),
        clipboardManager: ClipboardManager = ClipboardManager(),
        templateStore: TemplateStore = TemplateStore()
    ) {
        self.countries = countries
        self.recentHistoryStore = recentHistoryStore
        self.clipboardManager = clipboardManager
        self.templateStore = templateStore
        self.recentEntries = recentHistoryStore.load()
        self.clipboardSuggestion = clipboardManager.suggestedNumber()
        self.templates = templateStore.load()
    }

    var favoriteEntries: [RecentEntry] {
        recentEntries.filter(\.isFavorite)
    }

    var selectedTemplate: MessageTemplate? {
        templates.first(where: { $0.id == selectedTemplateID })
    }

    var payloadPreview: WhatsAppPayload? {
        previewPayload()
    }

    func syncPhoneNumber(_ input: String) {
        let cleaned = PhoneNumberFormatter.clean(input)
        if phoneNumber != cleaned {
            phoneNumber = cleaned
        }

        if let detectedCountry = CountryDetector.detectCountry(from: cleaned, countries: countries) {
            selectedCountry = detectedCountry
        }
    }

    func selectCountry(using code: String) {
        selectedCountry = countries.first(where: { $0.code == code }) ?? .fallback
    }

    func refreshClipboardSuggestion() {
        clipboardSuggestion = clipboardManager.suggestedNumber()
    }

    func useClipboardSuggestion() {
        guard let clipboardValue = clipboardSuggestion else { return }
        phoneNumber = clipboardValue
        syncPhoneNumber(clipboardValue)
        errorMessage = nil
        Haptics.light()
    }

    func openWhatsApp() {
        let cleanedNumber = PhoneNumberFormatter.clean(phoneNumber)
        if phoneNumber != cleanedNumber {
            phoneNumber = cleanedNumber
        }

        guard let payload = buildPayload(from: cleanedNumber, showErrors: true) else { return }
        saveRecent(payload.fullNumber)
        errorMessage = nil
        Haptics.success()
        UIApplication.shared.open(payload.url)
    }

    func openRecent(_ entry: RecentEntry) {
        guard let url = WhatsAppURLBuilder.url(from: entry.fullNumber, message: selectedTemplate?.body) else { return }
        saveRecent(entry.fullNumber)
        Haptics.light()
        UIApplication.shared.open(url)
    }

    func deleteRecentEntries(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            recentEntries.remove(at: index)
        }
        recentHistoryStore.save(recentEntries)
    }

    func toggleFavorite(for entry: RecentEntry) {
        guard let index = recentEntries.firstIndex(where: { $0.id == entry.id }) else { return }
        recentEntries[index].isFavorite.toggle()
        recentHistoryStore.save(recentEntries)
        Haptics.light()
    }

    func updateNote(for entry: RecentEntry, note: String) {
        guard let index = recentEntries.firstIndex(where: { $0.id == entry.id }) else { return }
        recentEntries[index].note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        recentHistoryStore.save(recentEntries)
    }

    func selectTemplate(_ template: MessageTemplate?) {
        selectedTemplateID = template?.id
        Haptics.light()
    }

    func addTemplate(title: String, body: String) {
        let sanitizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitizedTitle.isEmpty, !sanitizedBody.isEmpty else { return }

        templates.insert(
            MessageTemplate(id: UUID(), title: sanitizedTitle, body: sanitizedBody),
            at: 0
        )
        templateStore.save(templates)
    }

    func updateTemplate(id: UUID, title: String, body: String) {
        guard let index = templates.firstIndex(where: { $0.id == id }) else { return }
        templates[index].title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        templates[index].body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        templateStore.save(templates)
    }

    func deleteTemplate(at offsets: IndexSet) {
        let removedIDs = offsets.compactMap { templates.indices.contains($0) ? templates[$0].id : nil }
        for index in offsets.sorted(by: >) {
            templates.remove(at: index)
        }
        if removedIDs.contains(selectedTemplateID ?? UUID()) {
            selectedTemplateID = nil
        }
        templateStore.save(templates)
    }

    func copyGeneratedLink() {
        guard let link = payloadPreview?.url.absoluteString else { return }
        clipboardManager.copy(link)
        Haptics.success()
    }

    func copyCleanNumber() {
        guard let number = payloadPreview?.cleanNumber else { return }
        clipboardManager.copy(number)
        Haptics.success()
    }

    private func previewPayload() -> WhatsAppPayload? {
        let cleanedNumber = PhoneNumberFormatter.clean(phoneNumber)
        guard validate(number: cleanedNumber, showErrors: false) else { return nil }
        return buildPayload(from: cleanedNumber, showErrors: false)
    }

    private func buildPayload(from cleanedNumber: String, showErrors: Bool) -> WhatsAppPayload? {
        guard validate(number: cleanedNumber, showErrors: showErrors) else { return nil }

        let fullNumber = resolvedFullNumber(for: cleanedNumber)
        guard let url = WhatsAppURLBuilder.url(from: fullNumber, message: selectedTemplate?.body) else {
            if showErrors {
                errorMessage = "No fue posible generar el enlace de WhatsApp."
                Haptics.warning()
            }
            return nil
        }

        return WhatsAppPayload(
            fullNumber: fullNumber,
            url: url,
            cleanNumber: PhoneNumberFormatter.clean(fullNumber)
        )
    }

    private func validate(number: String, showErrors: Bool) -> Bool {
        guard !number.isEmpty else {
            if showErrors {
                errorMessage = "Ingresa un número telefónico."
                Haptics.warning()
            }
            return false
        }

        guard number.count >= minimumPhoneLength else {
            if showErrors {
                errorMessage = "El número debe tener al menos \(minimumPhoneLength) dígitos."
                Haptics.warning()
            }
            return false
        }

        if showErrors {
            errorMessage = nil
        }
        return true
    }

    private func resolvedFullNumber(for number: String) -> String {
        if CountryDetector.detectCountry(from: number, countries: countries) != nil {
            return number
        }

        let countryCode = PhoneNumberFormatter.clean(selectedCountry.code)
        return countryCode + number
    }

    private func saveRecent(_ fullNumber: String) {
        if let existingIndex = recentEntries.firstIndex(where: { $0.fullNumber == fullNumber }) {
            let existing = recentEntries.remove(at: existingIndex)
            recentEntries.insert(
                RecentEntry(
                    id: existing.id,
                    fullNumber: fullNumber,
                    date: Date(),
                    note: existing.note,
                    isFavorite: existing.isFavorite
                ),
                at: 0
            )
        } else {
            recentEntries.insert(
                RecentEntry(
                    id: UUID(),
                    fullNumber: fullNumber,
                    date: Date(),
                    note: "",
                    isFavorite: false
                ),
                at: 0
            )
        }

        recentEntries = Array(recentEntries.prefix(20))
        recentHistoryStore.save(recentEntries)
    }
}
