import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .background(AppColors.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLG))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusLG)
                    .strokeBorder(AppColors.borderSubtle, lineWidth: 0.5)
            )
    }

    func elevatedCardStyle() -> some View {
        self
            .background(AppColors.bgElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLG))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusLG)
                    .strokeBorder(AppColors.border, lineWidth: 0.5)
            )
    }

    func screenBackground() -> some View {
        self.background(AppColors.bgPrimary.ignoresSafeArea())
    }

    func primaryButton() -> some View {
        self
            .font(AppTypography.buttonLabel)
            .foregroundStyle(AppColors.textInverse)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(AppColors.accent)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
    }

    func secondaryButton() -> some View {
        self
            .font(AppTypography.buttonLabel)
            .foregroundStyle(AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(AppColors.bgElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                    .strokeBorder(AppColors.border, lineWidth: 1)
            )
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// MARK: - Conditional modifier
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
