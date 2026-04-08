import Foundation

struct SavedContactsStore {
    private let store: CodableStore<[SavedContact]>

    init(userDefaults: UserDefaults = .standard) {
        self.store = CodableStore(key: "savedContacts", userDefaults: userDefaults)
    }

    func load() -> [SavedContact] {
        store.load(fallback: [
            SavedContact(
                id: UUID(),
                name: "Gasfiter",
                fullNumber: "56911112222",
                note: "Urgencias del edificio",
                category: .supplier,
                isFavorite: true,
                updatedAt: .now
            ),
            SavedContact(
                id: UUID(),
                name: "Cliente Juan",
                fullNumber: "56933334444",
                note: "Cotización pendiente",
                category: .client,
                isFavorite: false,
                updatedAt: .now
            )
        ])
    }

    func save(_ contacts: [SavedContact]) {
        store.save(contacts)
    }

    func clear() {
        store.clear()
    }
}
