import Foundation

struct UserStats: Codable, Identifiable {
    let userId: UUID
    var currentStreak: Int
    var longestStreak: Int
    var totalGoalsCompleted: Int
    var totalPosts: Int
    var updatedAt: Date

    var id: UUID { userId }

    var streakLabel: String {
        currentStreak == 1 ? "1 day streak" : "\(currentStreak) day streak"
    }

    var motivationalPhrase: String {
        switch currentStreak {
        case 0: return "Start your streak today."
        case 1...3: return "Building the habit. Keep going."
        case 4...7: return "First week. Momentum is building."
        case 8...14: return "Two weeks of discipline. Respect."
        case 15...30: return "This is becoming your identity."
        case 31...60: return "Elite consistency. Keep it alive."
        default: return "Legendary. Don't stop now."
        }
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case totalGoalsCompleted = "total_goals_completed"
        case totalPosts = "total_posts"
        case updatedAt = "updated_at"
    }
}

struct DailyProgressSummary {
    var totalGoals: Int
    var completedGoals: Int
    var progressPct: Int
    var checkedInToday: Bool
    var postId: UUID?

    var progressFraction: Double {
        totalGoals == 0 ? 0 : Double(completedGoals) / Double(totalGoals)
    }

    init(totalGoals: Int = 0, completedGoals: Int = 0, progressPct: Int = 0, checkedInToday: Bool = false, postId: UUID? = nil) {
        self.totalGoals = totalGoals
        self.completedGoals = completedGoals
        self.progressPct = progressPct
        self.checkedInToday = checkedInToday
        self.postId = postId
    }
}
