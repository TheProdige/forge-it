import SwiftUI

struct GoalItem: View {
    let goal: Goal
    let onToggle: () -> Void
    let onDelete: () -> Void

    @State private var isPressed = false

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(goal.isCompleted ? AppColors.success.opacity(0.15) : AppColors.bgPrimary)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .strokeBorder(goal.isCompleted ? AppColors.success : AppColors.border, lineWidth: 1.5)
                        )
                    if goal.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.success)
                    }
                }
            }
            .scaleEffect(isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: goal.isCompleted)

            // Title
            VStack(alignment: .leading, spacing: 2) {
                Text(goal.title)
                    .font(AppTypography.body)
                    .foregroundStyle(goal.isCompleted ? AppColors.textMuted : AppColors.textPrimary)
                    .strikethrough(goal.isCompleted, color: AppColors.textMuted)
                    .lineLimit(2)

                if let completedAt = goal.completedAt, goal.isCompleted {
                    Text("Done \(completedAt.relativeDisplay)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.success.opacity(0.7))
                }
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
