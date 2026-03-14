import SwiftUI

struct DailyProgressCard: View {
    let summary: DailyProgressSummary
    @State private var animated = false

    var body: some View {
        SectionCard(title: "Today") {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppColors.bgPrimary)
                            .frame(height: 8)
                        Capsule()
                            .fill(progressGradient)
                            .frame(width: animated ? geo.size.width * summary.progressFraction : 0, height: 8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animated)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, AppSpacing.md)

                HStack {
                    Text("\(summary.completedGoals) of \(summary.totalGoals) goals done")
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                    Text("\(summary.progressPct)%")
                        .font(AppTypography.captionBold)
                        .foregroundStyle(summary.progressPct == 100 ? AppColors.success : AppColors.accent)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.cardPaddingV)
            }
            .padding(.top, AppSpacing.sm)
        }
        .onAppear { animated = true }
    }

    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [AppColors.accent, AppColors.accent.opacity(0.7)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
