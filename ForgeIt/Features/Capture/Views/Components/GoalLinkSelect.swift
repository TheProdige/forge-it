import SwiftUI

struct GoalLinkSelect: View {
    let goals: [Goal]
    @Binding var selectedId: UUID?
    @Binding var markComplete: Bool
    let hasSelectedGoal: Bool

    @State private var isExpanded = false

    var selectedGoal: Goal? {
        goals.first { $0.id == selectedId }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("LINK TO A GOAL")
                .font(AppTypography.labelSmall)
                .foregroundStyle(AppColors.textMuted)
                .tracking(0.5)

            // Current selection / picker
            Menu {
                Button("None") { selectedId = nil }
                ForEach(goals) { goal in
                    Button(goal.title) { selectedId = goal.id }
                }
            } label: {
                HStack {
                    Image(systemName: "target")
                        .font(.system(size: 14))
                        .foregroundStyle(hasSelectedGoal ? AppColors.accent : AppColors.textMuted)
                    Text(selectedGoal?.title ?? "Link to a goal (optional)")
                        .font(AppTypography.body)
                        .foregroundStyle(hasSelectedGoal ? AppColors.textPrimary : AppColors.textMuted)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textMuted)
                }
                .padding(AppSpacing.md)
                .background(AppColors.bgInput)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                        .strokeBorder(hasSelectedGoal ? AppColors.accent.opacity(0.4) : AppColors.border, lineWidth: 1)
                )
            }

            // Mark complete toggle
            if hasSelectedGoal {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mark as completed")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                        Text("Close this goal when you post")
                            .font(AppTypography.captionMedium)
                            .foregroundStyle(AppColors.textMuted)
                    }
                    Spacer()
                    Toggle("", isOn: $markComplete)
                        .tint(AppColors.accent)
                }
                .padding(AppSpacing.md)
                .background(AppColors.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: hasSelectedGoal)
            }
        }
    }
}
