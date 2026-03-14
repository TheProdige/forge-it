import SwiftUI

struct GoalsList: View {
    @Bindable var viewModel: ProgressViewModel

    var body: some View {
        SectionCard(
            title: "Goals",
            titleActionLabel: "+ Add",
            titleAction: { viewModel.showAddGoalSheet = true }
        ) {
            VStack(spacing: 0) {
                if viewModel.goals.isEmpty {
                    emptyGoals
                } else {
                    // Pending goals first
                    ForEach(viewModel.pendingGoals) { goal in
                        GoalItem(goal: goal) {
                            Task { await viewModel.toggleGoal(goal) }
                        } onDelete: {
                            Task { await viewModel.deleteGoal(goal) }
                        }
                        Divider().overlay(AppColors.borderSubtle).padding(.leading, 52)
                    }

                    // Completed goals
                    ForEach(viewModel.completedGoals) { goal in
                        GoalItem(goal: goal) {
                            Task { await viewModel.toggleGoal(goal) }
                        } onDelete: {
                            Task { await viewModel.deleteGoal(goal) }
                        }
                        if goal.id != viewModel.completedGoals.last?.id {
                            Divider().overlay(AppColors.borderSubtle).padding(.leading, 52)
                        }
                    }
                }
            }
            .padding(.bottom, AppSpacing.xs)
        }
    }

    private var emptyGoals: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("No goals yet")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
            Button("Add your first goal") {
                viewModel.showAddGoalSheet = true
            }
            .font(AppTypography.captionBold)
            .foregroundStyle(AppColors.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
    }
}
