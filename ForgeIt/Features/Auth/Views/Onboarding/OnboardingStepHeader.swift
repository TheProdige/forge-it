import SwiftUI

struct OnboardingStepHeader: View {
    let step: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(step)
                .font(AppTypography.labelSmall)
                .foregroundStyle(AppColors.accent)
                .tracking(0.8)
                .textCase(.uppercase)

            Text(title)
                .font(AppTypography.title1)
                .foregroundStyle(AppColors.textPrimary)

            Text(subtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
