import Foundation

struct DailyCheckin: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let checkinDate: Date
    var postId: UUID?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case checkinDate = "checkin_date"
        case postId = "post_id"
        case createdAt = "created_at"
    }
}
