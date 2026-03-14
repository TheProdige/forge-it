import Foundation

struct Post: Codable, Identifiable, Equatable {
    let id: UUID
    let userId: UUID
    var imageUrl: String?
    var caption: String?
    var linkedGoalId: UUID?
    var goalMarkedComplete: Bool
    var postedForDate: Date
    let createdAt: Date
    var updatedAt: Date

    // Joined via Supabase select
    var profile: Profile?
    var linkedGoal: Goal?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case imageUrl = "image_url"
        case caption
        case linkedGoalId = "linked_goal_id"
        case goalMarkedComplete = "goal_marked_complete"
        case postedForDate = "posted_for_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case profile = "profiles"
        case linkedGoal = "goals"
    }
}

struct CreatePostRequest: Encodable {
    let userId: UUID
    let imageUrl: String?
    let caption: String?
    let linkedGoalId: UUID?
    let goalMarkedComplete: Bool
    let postedForDate: Date

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case imageUrl = "image_url"
        case caption
        case linkedGoalId = "linked_goal_id"
        case goalMarkedComplete = "goal_marked_complete"
        case postedForDate = "posted_for_date"
    }
}
