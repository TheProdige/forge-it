import SwiftUI

struct StatPill: View {
    let value: String
    let label: String
    var accentColor: Color = AppColors.textPrimary

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(AppTypography.title3)
                .foregroundStyle(accentColor)
            Text(label)
                .font(AppTypography.captionMedium)
                .foregroundStyle(AppColors.textMuted)
        }
    }
}

struct InlineStatPill: View {
    let icon: String
    let value: String
    var color: Color = AppColors.textSecondary

    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 12))
            Text(value)
                .font(AppTypography.captionBold)
                .foregroundStyle(color)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 5)
        .background(AppColors.bgElevated)
        .clipShape(Capsule())
    }
}
