import Foundation

struct RecentHistoryStore {
    private let store: CodableStore<[RecentEntry]>

    init(userDefaults: UserDefaults = .standard) {
        self.store = CodableStore(key: "recentEntries", userDefaults: userDefaults)
    }

    func load() -> [RecentEntry] {
        store.load(fallback: [])
    }

    func save(_ entries: [RecentEntry]) {
        store.save(entries)
    }

    func clear() {
        store.clear()
    }
}
