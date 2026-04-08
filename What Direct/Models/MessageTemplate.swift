import Foundation

struct MessageTemplate: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var body: String
    var isFavorite: Bool
}

extension MessageTemplate {
    static let starterTemplates: [MessageTemplate] = [
        MessageTemplate(id: UUID(), title: "Presentación", body: "Hola, te contacto por…", isFavorite: true),
        MessageTemplate(id: UUID(), title: "Marketplace", body: "Hola, vengo de Marketplace. ¿Sigue disponible?", isFavorite: true),
        MessageTemplate(id: UUID(), title: "Más información", body: "Buenas, quisiera más información.", isFavorite: false),
        MessageTemplate(id: UUID(), title: "Referencia", body: "Hola, vengo de…", isFavorite: false)
    ]
}
