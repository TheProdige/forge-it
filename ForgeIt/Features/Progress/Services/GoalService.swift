import Foundation
import Supabase

@MainActor
final class GoalService {
    static let shared = GoalService()
    private let client = SupabaseManager.shared.client

    private init() {}

    // MARK: - Goals CRUD
    func fetchGoals(userId: UUID) async throws -> [Goal] {
        let goals: [Goal] = try await client
            .from("goals")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        return goals
    }

    func createGoal(_ request: CreateGoalRequest) async throws -> Goal {
        let goal: Goal = try await client
            .from("goals")
            .insert(request)
            .select()
            .single()
            .execute()
            .value
        return goal
    }

    func updateGoal(id: UUID, updates: GoalUpdateRequest) async throws -> Goal {
        let goal: Goal = try await client
            .from("goals")
            .update(updates)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value
        return goal
    }

    func deleteGoal(id: UUID) async throws {
        try await client
            .from("goals")
            .delete()
            .eq("id", value: id)
            .execute()
    }

    func completeGoal(id: UUID, userId: UUID) async throws {
        try await client
            .rpc("complete_goal", params: ["p_goal_id": id.uuidString, "p_user_id": userId.uuidString])
            .execute()
    }

    func uncompleteGoal(id: UUID, userId: UUID) async throws {
        try await client
            .rpc("uncomplete_goal", params: ["p_goal_id": id.uuidString, "p_user_id": userId.uuidString])
            .execute()
    }

    // MARK: - Stats
    func fetchUserStats(userId: UUID) async throws -> UserStats {
        let stats: UserStats = try await client
            .from("user_stats")
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        return stats
    }

    func refreshStreak(userId: UUID) async throws -> Int {
        struct StreakResult: Decodable { let refreshUserStreak: Int }
        // Call the Supabase RPC
        let result: Int = try await client
            .rpc("refresh_user_streak", params: ["p_user_id": userId.uuidString])
            .execute()
            .value
        return result
    }

    func fetchDailyProgress(userId: UUID) async throws -> DailyProgressSummary {
        struct RPCResult: Decodable {
            let totalGoals: Int
            let completedGoals: Int
            let progressPct: Int
            let checkedInToday: Bool
            let postId: UUID?
            enum CodingKeys: String, CodingKey {
                case totalGoals = "total_goals"
                case completedGoals = "completed_goals"
                case progressPct = "progress_pct"
                case checkedInToday = "checked_in_today"
                case postId = "post_id"
            }
        }
        let result: RPCResult = try await client
            .rpc("daily_progress_summary", params: ["p_user_id": userId.uuidString])
            .execute()
            .value
        return DailyProgressSummary(
            totalGoals: result.totalGoals,
            completedGoals: result.completedGoals,
            progressPct: result.progressPct,
            checkedInToday: result.checkedInToday,
            postId: result.postId
        )
    }
}

// MARK: - Supporting types
struct GoalUpdateRequest: Encodable {
    var title: String?
    var description: String?
    var status: String?
    var targetDate: Date?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case status
        case targetDate = "target_date"
    }
}
