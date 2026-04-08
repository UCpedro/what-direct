import Foundation

struct RecentHistoryStore {
    private let userDefaults: UserDefaults
    private let storageKey = "recentEntries"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> [RecentEntry] {
        guard let data = userDefaults.data(forKey: storageKey) else { return [] }

        do {
            return try JSONDecoder().decode([RecentEntry].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ entries: [RecentEntry]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
