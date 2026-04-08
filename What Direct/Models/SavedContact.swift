import Foundation

struct SavedContact: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var fullNumber: String
    var note: String
    var category: ContactCategory
    var isFavorite: Bool
    var updatedAt: Date
}
