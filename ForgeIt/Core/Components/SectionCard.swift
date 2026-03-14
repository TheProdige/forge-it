import SwiftUI

struct SectionCard<Content: View>: View {
    var title: String? = nil
    var titleAction: (() -> Void)? = nil
    var titleActionLabel: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title {
                HStack {
                    Text(title)
                        .font(AppTypography.label)
                        .foregroundStyle(AppColors.textMuted)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    Spacer()

                    if let actionLabel = titleActionLabel, let action = titleAction {
                        Button(actionLabel, action: action)
                            .font(AppTypography.captionMedium)
                            .foregroundStyle(AppColors.accent)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)
            }

            content
        }
        .cardStyle()
    }
}
