import Foundation

struct CodableStore<Value: Codable> {
    private let userDefaults: UserDefaults
    private let key: String

    init(key: String, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.userDefaults = userDefaults
    }

    func load(fallback: @autoclosure () -> Value) -> Value {
        guard let data = userDefaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(Value.self, from: data) else {
            return fallback()
        }

        return decoded
    }

    func save(_ value: Value) {
        guard let encoded = try? JSONEncoder().encode(value) else { return }
        if userDefaults.data(forKey: key) != encoded {
            userDefaults.set(encoded, forKey: key)
        }
    }

    func clear() {
        userDefaults.removeObject(forKey: key)
    }
}
