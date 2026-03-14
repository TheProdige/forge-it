import Foundation
import SwiftUI

@MainActor
@Observable
final class ProgressViewModel {
    private let goalService = GoalService.shared
    private let authService = AuthService.shared

    // MARK: - State
    var goals: [Goal] = []
    var stats: UserStats? = nil
    var dailySummary: DailyProgressSummary = DailyProgressSummary()
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var error: String? = nil

    // Add goal sheet
    var showAddGoalSheet: Bool = false
    var newGoalTitle: String = ""
    var newGoalDescription: String = ""
    var isAddingGoal: Bool = false
    var addGoalError: String? = nil

    // Edit goal sheet
    var editingGoal: Goal? = nil
    var showEditGoalSheet: Bool = false

    var pendingGoals: [Goal] { goals.filter { !$0.isCompleted } }
    var completedGoals: [Goal] { goals.filter { $0.isCompleted } }
    var currentStreak: Int { stats?.currentStreak ?? 0 }

    // MARK: - Load
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        await fetchAll()
        isLoading = false
    }

    func refresh() async {
        isRefreshing = true
        await fetchAll()
        isRefreshing = false
    }

    private func fetchAll() async {
        guard let userId = authService.currentUser?.id else { return }
        async let goalsTask = goalService.fetchGoals(userId: userId)
        async let statsTask = goalService.fetchUserStats(userId: userId)
        async let summaryTask = goalService.fetchDailyProgress(userId: userId)

        do {
            let (g, s, d) = try await (goalsTask, statsTask, summaryTask)
            goals = g
            stats = s
            dailySummary = d
        } catch {
            self.error = "Couldn't load your progress."
        }
    }

    // MARK: - Toggle goal completion
    func toggleGoal(_ goal: Goal) async {
        guard let userId = authService.currentUser?.id else { return }

        // Optimistic update
        if let idx = goals.firstIndex(where: { $0.id == goal.id }) {
            var updated = goals[idx]
            if updated.isCompleted {
                updated.status = .pending
                updated.completedAt = nil
            } else {
                updated.status = .completed
                updated.completedAt = Date()
            }
            goals[idx] = updated
        }

        do {
            if goal.isCompleted {
                try await goalService.uncompleteGoal(id: goal.id, userId: userId)
            } else {
                try await goalService.completeGoal(id: goal.id, userId: userId)
            }
            await refresh()
        } catch {
            // Rollback
            await refresh()
        }
    }

    // MARK: - Add goal
    func addGoal() async {
        guard !newGoalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            addGoalError = "Goal title can't be empty."
            return
        }
        guard let userId = authService.currentUser?.id else { return }

        isAddingGoal = true
        addGoalError = nil

        let request = CreateGoalRequest(
            userId: userId,
            title: newGoalTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: newGoalDescription.isEmpty ? nil : newGoalDescription,
            targetDate: Date.todayDate
        )

        do {
            let goal = try await goalService.createGoal(request)
            goals.insert(goal, at: 0)
            showAddGoalSheet = false
            newGoalTitle = ""
            newGoalDescription = ""
        } catch {
            addGoalError = error.localizedDescription
        }

        isAddingGoal = false
    }

    // MARK: - Delete goal
    func deleteGoal(_ goal: Goal) async {
        goals.removeAll { $0.id == goal.id }
        do {
            try await goalService.deleteGoal(id: goal.id)
        } catch {
            await refresh()
        }
    }
}
