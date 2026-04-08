import Foundation

struct RecentEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var fullNumber: String
    var date: Date
    var note: String
    var isFavorite: Bool
    var alias: String
    var app: ConversationApp
}
