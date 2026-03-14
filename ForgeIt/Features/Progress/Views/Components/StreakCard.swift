import SwiftUI

struct StreakCard: View {
    let stats: UserStats?
    let streak: Int

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Streak visual
            ZStack {
                Circle()
                    .fill(AppColors.streakGlow)
                    .frame(width: 64, height: 64)
                Text(streak == 0 ? "💤" : "🔥")
                    .font(.system(size: 32))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(stats?.streakLabel ?? "No streak yet")
                    .font(AppTypography.title2)
                    .foregroundStyle(streak > 0 ? AppColors.streakFire : AppColors.textSecondary)

                Text(stats?.motivationalPhrase ?? "Start your streak today.")
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)

                if let longest = stats?.longestStreak, longest > 0 {
                    Text("Best: \(longest) days")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textMuted)
                }
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .elevatedCardStyle()
    }
}
