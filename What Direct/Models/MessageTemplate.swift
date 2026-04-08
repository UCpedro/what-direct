import Foundation

struct MessageTemplate: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var body: String
}
