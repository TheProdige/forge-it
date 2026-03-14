import SwiftUI

struct EmptyState: View {
    let icon: String
    let title: String
    let message: String
    var ctaTitle: String? = nil
    var ctaAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()

            Text(icon)
                .font(.system(size: 48))
                .padding(.bottom, AppSpacing.xs)

            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppTypography.title3)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

            if let ctaTitle, let ctaAction {
                Button(action: ctaAction) {
                    Text(ctaTitle)
                        .primaryButton()
                }
                .padding(.horizontal, AppSpacing.xxl)
                .padding(.top, AppSpacing.sm)
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.xl)
    }
}
