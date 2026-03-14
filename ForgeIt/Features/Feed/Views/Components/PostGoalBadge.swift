import SwiftUI

struct PostGoalBadge: View {
    let goal: Goal
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "target")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isCompleted ? AppColors.success : AppColors.accent)

            Text(isCompleted ? "Completed: \(goal.title)" : "Working on: \(goal.title)")
                .font(AppTypography.captionBold)
                .foregroundStyle(isCompleted ? AppColors.success : AppColors.accent)
                .lineLimit(1)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 5)
        .background(isCompleted ? AppColors.success.opacity(0.1) : AppColors.accentMuted)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusFull))
    }
}
