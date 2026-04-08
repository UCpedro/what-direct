import Foundation

struct RecentEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let fullNumber: String
    let date: Date
    var note: String
    var isFavorite: Bool
}
