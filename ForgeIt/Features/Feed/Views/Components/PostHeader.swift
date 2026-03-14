import SwiftUI

struct PostHeader: View {
    let feedPost: FeedPost
    let onFollow: () -> Void
    var isFollowLoading: Bool = false
    var showFollowButton: Bool = true

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            UserAvatar(profile: feedPost.profile, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppSpacing.xs) {
                    Text(feedPost.profile?.displayName ?? "Unknown")
                        .font(AppTypography.bodySemibold)
                        .foregroundStyle(AppColors.textPrimary)

                    if let category = feedPost.profile?.entrepreneurCategory {
                        Text(category.emoji)
                            .font(.system(size: 12))
                    }
                }

                HStack(spacing: AppSpacing.xs) {
                    Text("@\(feedPost.profile?.username ?? "")")
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(AppColors.textMuted)

                    Text("·")
                        .foregroundStyle(AppColors.textMuted)

                    Text(feedPost.createdAt.todayLabel)
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(AppColors.textMuted)
                }
            }

            Spacer()

            if showFollowButton && feedPost.profile != nil {
                FollowButton(
                    isFollowing: feedPost.isFollowing,
                    isLoading: isFollowLoading,
                    action: onFollow
                )
            }
        }
    }
}
