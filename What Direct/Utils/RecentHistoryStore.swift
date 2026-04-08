import Foundation

struct RecentHistoryStore {
    private let userDefaults: UserDefaults
    private let storageKey = "recentEntries"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> [RecentEntry] {
        guard let data = userDefaults.data(forKey: storageKey),
              let entries = try? JSONDecoder().decode([RecentEntry].self, from: data) else {
            return []
        }

        return entries
    }

    func save(_ entries: [RecentEntry]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
