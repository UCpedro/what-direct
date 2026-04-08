import Foundation

struct TemplateStore {
    private let store: CodableStore<[MessageTemplate]>

    init(userDefaults: UserDefaults = .standard) {
        self.store = CodableStore(key: "messageTemplates", userDefaults: userDefaults)
    }

    func load() -> [MessageTemplate] {
        let templates = store.load(fallback: MessageTemplate.starterTemplates)
        return templates.isEmpty ? MessageTemplate.starterTemplates : templates
    }

    func save(_ templates: [MessageTemplate]) {
        store.save(templates)
    }

    func clear() {
        store.clear()
    }
}
