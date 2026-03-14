import Foundation

enum GoalStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "in_progress"
    case completed = "completed"
}

struct Goal: Codable, Identifiable, Equatable {
    let id: UUID
    let userId: UUID
    var title: String
    var description: String?
    var status: GoalStatus
    var targetDate: Date?
    var completedAt: Date?
    let createdAt: Date
    var updatedAt: Date

    var isCompleted: Bool { status == .completed }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case description
        case status
        case targetDate = "target_date"
        case completedAt = "completed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CreateGoalRequest: Encodable {
    let userId: UUID
    let title: String
    let description: String?
    let targetDate: Date?
    let status: String = "pending"

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case title
        case description
        case targetDate = "target_date"
        case status
    }
}
