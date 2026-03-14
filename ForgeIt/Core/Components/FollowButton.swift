import SwiftUI

struct FollowButton: View {
    let isFollowing: Bool
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .tint(isFollowing ? AppColors.textSecondary : AppColors.textInverse)
                    .frame(width: 70, height: 30)
            } else {
                Text(isFollowing ? "Following" : "Follow")
                    .font(AppTypography.buttonSmall)
                    .foregroundStyle(isFollowing ? AppColors.textSecondary : AppColors.textInverse)
                    .frame(width: 84, height: 32)
            }
        }
        .background(isFollowing ? AppColors.bgElevated : AppColors.accent)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusSM))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusSM)
                .strokeBorder(isFollowing ? AppColors.border : Color.clear, lineWidth: 1)
        )
        .disabled(isLoading)
    }
}
