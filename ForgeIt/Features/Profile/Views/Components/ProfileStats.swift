import SwiftUI

struct ProfileStats: View {
    let stats: UserStats

    var body: some View {
        HStack(spacing: 0) {
            StatPill(
                value: "\(stats.currentStreak)",
                label: "Day streak",
                accentColor: stats.currentStreak > 0 ? AppColors.streakFire : AppColors.textSecondary
            )
            .frame(maxWidth: .infinity)

            divider

            StatPill(
                value: "\(stats.totalGoalsCompleted)",
                label: "Goals done",
                accentColor: AppColors.success
            )
            .frame(maxWidth: .infinity)

            divider

            StatPill(
                value: "\(stats.totalPosts)",
                label: "Posts",
                accentColor: AppColors.textPrimary
            )
            .frame(maxWidth: .infinity)

            divider

            StatPill(
                value: "\(stats.longestStreak)",
                label: "Best streak",
                accentColor: AppColors.accent
            )
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, AppSpacing.md)
        .cardStyle()
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColors.borderSubtle)
            .frame(width: 1, height: 36)
    }
}
