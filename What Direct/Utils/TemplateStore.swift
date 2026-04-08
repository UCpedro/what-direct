import Foundation

struct TemplateStore {
    private let userDefaults: UserDefaults
    private let storageKey = "messageTemplates"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> [MessageTemplate] {
        guard let data = userDefaults.data(forKey: storageKey),
              let templates = try? JSONDecoder().decode([MessageTemplate].self, from: data),
              !templates.isEmpty else {
            return [
                MessageTemplate(id: UUID(), title: "Hola", body: "Hola, te escribo por WhatsApp."),
                MessageTemplate(id: UUID(), title: "Consulta", body: "Hola, quisiera hacerte una consulta."),
                MessageTemplate(id: UUID(), title: "Marketplace", body: "Hola, te escribo por el aviso de Marketplace.")
            ]
        }

        return templates
    }

    func save(_ templates: [MessageTemplate]) {
        guard let data = try? JSONEncoder().encode(templates) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
