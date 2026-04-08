import Foundation

struct SettingsStore {
    private let store: CodableStore<AppSettings>

    init(userDefaults: UserDefaults = .standard) {
        self.store = CodableStore(key: "appSettings", userDefaults: userDefaults)
    }

    func load() -> AppSettings {
        store.load(fallback: .default)
    }

    func save(_ settings: AppSettings) {
        store.save(settings)
    }

    func clear() {
        store.clear()
    }
}
