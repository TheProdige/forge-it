import SwiftUI

struct TodayCheckinCard: View {
    let summary: DailyProgressSummary

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(summary.checkedInToday ? AppColors.success.opacity(0.15) : AppColors.bgElevated)
                    .frame(width: 48, height: 48)
                Image(systemName: summary.checkedInToday ? "checkmark.circle.fill" : "circle.dashed")
                    .font(.system(size: 22))
                    .foregroundStyle(summary.checkedInToday ? AppColors.success : AppColors.textMuted)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Today's grind check")
                    .font(AppTypography.bodySemibold)
                    .foregroundStyle(AppColors.textPrimary)
                Text(summary.checkedInToday
                    ? "Done. You showed up today."
                    : "You haven't posted yet today.")
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(summary.checkedInToday ? AppColors.success : AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .cardStyle()
    }
}
