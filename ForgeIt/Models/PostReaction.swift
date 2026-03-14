import Foundation

enum ReactionType: String, Codable, Hashable {
    case grind = "grind"
    case respect = "respect"

    var emoji: String {
        switch self {
        case .grind: return "🔥"
        case .respect: return "💪"
        }
    }

    var label: String {
        switch self {
        case .grind: return "Grind"
        case .respect: return "Respect"
        }
    }
}

struct PostReaction: Codable, Identifiable {
    let id: UUID
    let postId: UUID
    let userId: UUID
    let reactionType: ReactionType
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case reactionType = "reaction_type"
        case createdAt = "created_at"
    }
}

struct ReactionCounts: Equatable {
    var grind: Int
    var respect: Int
    var myReactions: Set<ReactionType>

    var hasGrind: Bool { myReactions.contains(.grind) }
    var hasRespect: Bool { myReactions.contains(.respect) }
}
