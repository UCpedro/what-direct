import Foundation
import SwiftUI

struct HistorySectionModel: Identifiable {
    let id: String
    let title: String
    let entries: [RecentEntry]
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var phoneInput = ""
    @Published var selectedCountry: Country
    @Published var selectedTemplateID: UUID?
    @Published var recentEntries: [RecentEntry]
    @Published var savedContacts: [SavedContact]
    @Published var templates: [MessageTemplate]
    @Published var settings: AppSettings
    @Published var clipboardSuggestion: String?
    @Published var alertMessage: String?
    @Published var lastCopiedMessage: String?
    @Published private(set) var payload: WhatsAppPayload
    @Published private(set) var selectedTemplate: MessageTemplate?
    @Published private(set) var preferredCountries: [Country] = []
    @Published private(set) var favoriteTemplates: [MessageTemplate] = []
    @Published private(set) var favoriteContacts: [SavedContact] = []
    @Published private(set) var favoriteHistoryEntries: [RecentEntry] = []
    @Published private(set) var historySections: [HistorySectionModel] = []

    let countries: [Country]

    private let recentHistoryStore: RecentHistoryStore
    private let templateStore: TemplateStore
    private let contactsStore: SavedContactsStore
    private let settingsStore: SettingsStore
    private let clipboardManager: ClipboardManager
    private let launcher: ConversationLauncher

    init(
        countries: [Country] = Country.defaults,
        recentHistoryStore: RecentHistoryStore = RecentHistoryStore(),
        templateStore: TemplateStore = TemplateStore(),
        contactsStore: SavedContactsStore = SavedContactsStore(),
        settingsStore: SettingsStore = SettingsStore(),
        clipboardManager: ClipboardManager = ClipboardManager(),
        launcher: ConversationLauncher = ConversationLauncher()
    ) {
        let loadedSettings = settingsStore.load()
        let loadedRecents = recentHistoryStore.load()
        let loadedContacts = contactsStore.load()
        let loadedTemplates = templateStore.load()

        self.countries = countries
        self.recentHistoryStore = recentHistoryStore
        self.templateStore = templateStore
        self.contactsStore = contactsStore
        self.settingsStore = settingsStore
        self.clipboardManager = clipboardManager
        self.launcher = launcher
        self.settings = loadedSettings
        self.recentEntries = loadedRecents
        self.savedContacts = loadedContacts
        self.templates = loadedTemplates

        let initialCountry: Country
        if let configuredCountry = countries.first(where: { $0.code == loadedSettings.preferredCountryCode }) {
            initialCountry = configuredCountry
        } else if let regionCountry = CountryDetector.deviceRegionCountry(from: countries) {
            initialCountry = regionCountry
        } else {
            initialCountry = .fallback
        }
        self.selectedCountry = initialCountry

        self.payload = PhoneNumberFormatter.payload(
            for: "",
            selectedCountry: initialCountry,
            countries: countries
        )
        self.clipboardSuggestion = loadedSettings.clipboardSuggestionsEnabled ? clipboardManager.suggestedNumber() : nil
        refreshDerivedState()
    }

    var selectedTemplateBody: String? {
        selectedTemplate?.body
    }

    func onLaunch() {
        refreshClipboardSuggestion()
    }

    func updatePhoneInput(_ newValue: String) {
        let cleanedValue = PhoneNumberFormatter.clean(newValue)
        if phoneInput != cleanedValue {
            phoneInput = cleanedValue
        }
        refreshPayload()

        if let detectedCountry = payload.detectedCountry,
           detectedCountry.id != selectedCountry.id {
            selectedCountry = detectedCountry
            refreshPayload()
        }
    }

    func selectCountry(_ country: Country) {
        selectedCountry = country
        settings.preferredCountryCode = country.code
        saveSettings()
        refreshPayload()
        refreshPreferredCountries()
    }

    func toggleCountryFavorite(_ country: Country) {
        if settings.favoriteCountryCodes.contains(country.isoCode) {
            settings.favoriteCountryCodes.removeAll { $0 == country.isoCode }
        } else {
            settings.favoriteCountryCodes.insert(country.isoCode, at: 0)
        }
        saveSettings()
        refreshPreferredCountries()
    }

    func refreshClipboardSuggestion() {
        clipboardSuggestion = settings.clipboardSuggestionsEnabled ? clipboardManager.suggestedNumber() : nil
    }

    func useClipboardSuggestion() {
        guard let clipboardSuggestion else { return }
        updatePhoneInput(clipboardSuggestion)
        Haptics.light()
    }

    func useScannedNumber(_ number: String) {
        updatePhoneInput(number)
        Haptics.success()
    }

    func selectTemplate(_ template: MessageTemplate?) {
        selectedTemplateID = template?.id
        refreshSelectedTemplate()
    }

    func openPreferredApp() {
        open(using: settings.defaultApp)
    }

    func open(using app: ConversationApp) {
        let result = launcher.launch(app: app, payload: payload, message: selectedTemplateBody)

        switch result {
        case .success:
            persistRecent(app: app)
            Haptics.success()
        case .appUnavailable(let message), .invalidNumber(let message):
            alertMessage = message
            Haptics.warning()
        }
    }

    func canOpen(_ app: ConversationApp) -> Bool {
        switch app {
        case .whatsapp, .whatsappBusiness, .telegram:
            return launcher.canOpen(app)
        case .sms:
            return true
        }
    }

    func copyGeneratedLink() {
        guard let url = launcher.shareableLink(for: payload, message: selectedTemplateBody) else {
            alertMessage = "No pudimos generar el link todavía."
            return
        }

        clipboardManager.copy(url.absoluteString)
        lastCopiedMessage = "Link copiado"
        Haptics.success()
    }

    func copyCleanNumber() {
        guard payload.validationState != .invalid else {
            alertMessage = payload.validationMessage
            return
        }

        clipboardManager.copy(payload.cleanNumber)
        lastCopiedMessage = "Número copiado"
        Haptics.success()
    }

    func clearCopiedFeedback() {
        lastCopiedMessage = nil
    }

    func saveCurrentNumberAsContact(name: String, note: String, category: ContactCategory, isFavorite: Bool) {
        guard payload.validationState != .invalid else {
            alertMessage = payload.validationMessage
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            alertMessage = "Ingresa un nombre para guardar este contacto temporal."
            return
        }
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedNumber = payload.cleanNumber

        if let existingIndex = savedContacts.firstIndex(where: { $0.fullNumber == normalizedNumber }) {
            savedContacts[existingIndex].name = trimmedName
            savedContacts[existingIndex].note = trimmedNote
            savedContacts[existingIndex].category = category
            savedContacts[existingIndex].isFavorite = isFavorite
            savedContacts[existingIndex].updatedAt = .now
        } else {
            savedContacts.insert(
                SavedContact(
                    id: UUID(),
                    name: trimmedName,
                    fullNumber: normalizedNumber,
                    note: trimmedNote,
                    category: category,
                    isFavorite: isFavorite,
                    updatedAt: .now
                ),
                at: 0
            )
        }

        syncRecentsForSavedContacts()
        saveContacts()
        refreshFavoriteContacts()
        Haptics.success()
    }

    func updateContact(_ contact: SavedContact) {
        guard let index = savedContacts.firstIndex(where: { $0.id == contact.id }) else { return }
        savedContacts[index] = contact
        savedContacts[index].updatedAt = .now
        syncRecentsForSavedContacts()
        saveContacts()
        refreshFavoriteContacts()
    }

    func deleteContacts(at offsets: IndexSet, filteredContacts: [SavedContact]) {
        let ids = offsets.map { filteredContacts[$0].id }
        savedContacts.removeAll { ids.contains($0.id) }
        syncRecentsForSavedContacts()
        saveContacts()
        refreshFavoriteContacts()
    }

    func deleteContact(_ contact: SavedContact) {
        savedContacts.removeAll { $0.id == contact.id }
        syncRecentsForSavedContacts()
        saveContacts()
        refreshFavoriteContacts()
    }

    func toggleFavorite(for contact: SavedContact) {
        guard let index = savedContacts.firstIndex(where: { $0.id == contact.id }) else { return }
        savedContacts[index].isFavorite.toggle()
        savedContacts[index].updatedAt = .now
        syncRecentsForSavedContacts()
        saveContacts()
        refreshFavoriteContacts()
    }

    func openContact(_ contact: SavedContact, app: ConversationApp? = nil) {
        updatePhoneInput(contact.fullNumber)
        open(using: app ?? settings.defaultApp)
    }

    func addTemplate(title: String, body: String) {
        let sanitizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitizedTitle.isEmpty, !sanitizedBody.isEmpty else {
            alertMessage = "Completa título y mensaje antes de guardar la plantilla."
            return
        }

        if templates.contains(where: {
            $0.title.caseInsensitiveCompare(sanitizedTitle) == .orderedSame
            && $0.body.caseInsensitiveCompare(sanitizedBody) == .orderedSame
        }) {
            alertMessage = "Ya existe una plantilla igual guardada."
            return
        }

        templates.insert(
            MessageTemplate(id: UUID(), title: sanitizedTitle, body: sanitizedBody, isFavorite: false),
            at: 0
        )
        saveTemplates()
        refreshTemplateState()
    }

    func updateTemplate(_ template: MessageTemplate) {
        guard let index = templates.firstIndex(where: { $0.id == template.id }) else { return }
        templates[index] = template
        saveTemplates()
        refreshTemplateState()
    }

    func deleteTemplates(at offsets: IndexSet, filteredTemplates: [MessageTemplate]) {
        let ids = offsets.map { filteredTemplates[$0].id }
        templates.removeAll { ids.contains($0.id) }
        if ids.contains(selectedTemplateID ?? UUID()) {
            selectedTemplateID = nil
        }
        saveTemplates()
        refreshTemplateState()
    }

    func toggleFavorite(for template: MessageTemplate) {
        guard let index = templates.firstIndex(where: { $0.id == template.id }) else { return }
        templates[index].isFavorite.toggle()
        saveTemplates()
        refreshTemplateState()
    }

    func openRecent(_ entry: RecentEntry) {
        updatePhoneInput(entry.fullNumber)
        open(using: entry.app)
    }

    func deleteRecent(_ entry: RecentEntry) {
        recentEntries.removeAll { $0.id == entry.id }
        saveRecents()
        refreshRecentState()
    }

    func clearHistory() {
        recentEntries.removeAll()
        recentHistoryStore.clear()
        refreshRecentState()
    }

    func toggleFavorite(for recent: RecentEntry) {
        guard let index = recentEntries.firstIndex(where: { $0.id == recent.id }) else { return }
        recentEntries[index].isFavorite.toggle()
        saveRecents()
        refreshRecentState()
    }

    func updateRecentNote(_ note: String, for recent: RecentEntry) {
        guard let index = recentEntries.firstIndex(where: { $0.id == recent.id }) else { return }
        recentEntries[index].note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        saveRecents()
        refreshRecentState()
    }

    func updateSettings(_ block: (inout AppSettings) -> Void) {
        block(&settings)
        saveSettings()

        if let country = countries.first(where: { $0.code == settings.preferredCountryCode }) {
            selectedCountry = country
        }

        refreshClipboardSuggestion()
        refreshDerivedState()
    }

    func wipeAllData() {
        recentEntries.removeAll()
        savedContacts.removeAll()
        templates = MessageTemplate.starterTemplates
        settings = .default

        recentHistoryStore.clear()
        contactsStore.clear()
        templateStore.clear()
        settingsStore.clear()

        selectedCountry = CountryDetector.deviceRegionCountry(from: countries) ?? .fallback
        selectedTemplateID = nil
        clipboardSuggestion = settings.clipboardSuggestionsEnabled ? clipboardManager.suggestedNumber() : nil
        refreshDerivedState()
    }

    func aliasForNumber(_ fullNumber: String) -> String {
        if let contact = savedContacts.first(where: { $0.fullNumber == PhoneNumberFormatter.clean(fullNumber) }) {
            return contact.name
        }

        if let entry = recentEntries.first(where: { $0.fullNumber == PhoneNumberFormatter.clean(fullNumber) }),
           !entry.alias.isEmpty {
            return entry.alias
        }

        return ""
    }

    private func persistRecent(app: ConversationApp) {
        let normalizedNumber = payload.cleanNumber
        let alias = aliasForNumber(normalizedNumber)
        let note = savedContacts.first(where: { $0.fullNumber == normalizedNumber })?.note ?? ""

        if let existingIndex = recentEntries.firstIndex(where: { $0.fullNumber == normalizedNumber && $0.app == app }) {
            var existing = recentEntries.remove(at: existingIndex)
            existing.date = .now
            existing.alias = alias
            existing.note = note.isEmpty ? existing.note : note
            recentEntries.insert(existing, at: 0)
        } else {
            recentEntries.insert(
                RecentEntry(
                    id: UUID(),
                    fullNumber: normalizedNumber,
                    date: .now,
                    note: note,
                    isFavorite: false,
                    alias: alias,
                    app: app
                ),
                at: 0
            )
        }

        recentEntries = Array(recentEntries.prefix(30))
        saveRecents()
        refreshRecentState()
    }

    private func saveRecents() {
        recentHistoryStore.save(recentEntries)
    }

    private func saveContacts() {
        contactsStore.save(savedContacts.sorted(by: { $0.updatedAt > $1.updatedAt }))
    }

    private func saveTemplates() {
        templateStore.save(templates)
    }

    private func saveSettings() {
        settingsStore.save(settings)
    }

    private func syncRecentsForSavedContacts() {
        let contactsByNumber = Dictionary(uniqueKeysWithValues: savedContacts.map { ($0.fullNumber, $0) })
        recentEntries = recentEntries.map { entry in
            guard let contact = contactsByNumber[entry.fullNumber] else {
                return entry
            }

            var updatedEntry = entry
            updatedEntry.alias = contact.name
            if !contact.note.isEmpty {
                updatedEntry.note = contact.note
            }
            return updatedEntry
        }
        saveRecents()
        refreshRecentState()
    }

    private func refreshDerivedState() {
        refreshPayload()
        refreshSelectedTemplate()
        refreshPreferredCountries()
        refreshFavoriteTemplates()
        refreshFavoriteContacts()
        refreshRecentState()
    }

    private func refreshPayload() {
        payload = PhoneNumberFormatter.payload(
            for: phoneInput,
            selectedCountry: selectedCountry,
            countries: countries
        )
    }

    private func refreshSelectedTemplate() {
        selectedTemplate = templates.first(where: { $0.id == selectedTemplateID })
    }

    private func refreshPreferredCountries() {
        let favoriteCodes = Set(settings.favoriteCountryCodes)
        let regionCountry = CountryDetector.deviceRegionCountry(from: countries)
        let favorites = countries.filter { favoriteCodes.contains($0.isoCode) }
        let frequent = countries.filter { country in
            country.isoCode == regionCountry?.isoCode || country.code == settings.preferredCountryCode
        }
        preferredCountries = Array(Set(favorites + frequent)).sorted { $0.name < $1.name }
    }

    private func refreshFavoriteTemplates() {
        favoriteTemplates = templates.filter(\.isFavorite)
    }

    private func refreshFavoriteContacts() {
        favoriteContacts = savedContacts
            .filter(\.isFavorite)
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    private func refreshRecentState() {
        favoriteHistoryEntries = recentEntries
            .filter(\.isFavorite)
            .sorted { $0.date > $1.date }
        historySections = buildHistorySections(from: recentEntries)
    }

    private func refreshTemplateState() {
        refreshSelectedTemplate()
        refreshFavoriteTemplates()
    }

    private func buildHistorySections(from entries: [RecentEntry]) -> [HistorySectionModel] {
        let calendar = Calendar.current
        let now = Date()
        let grouped = Dictionary(grouping: entries.sorted(by: { $0.date > $1.date })) { entry -> String in
            if calendar.isDateInToday(entry.date) {
                return "Hoy"
            }

            if let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now), entry.date >= oneWeekAgo {
                return "Esta semana"
            }

            return "Anteriores"
        }

        return ["Hoy", "Esta semana", "Anteriores"].compactMap { title in
            guard let groupedEntries = grouped[title], !groupedEntries.isEmpty else { return nil }
            return HistorySectionModel(id: title, title: title, entries: groupedEntries)
        }
    }
}
