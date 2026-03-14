import SwiftUI

struct PostCard: View {
    let feedPost: FeedPost
    let onReaction: (ReactionType) -> Void
    let onFollow: () -> Void

    @State private var isFollowLoading = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            PostHeader(feedPost: feedPost, onFollow: {
                isFollowLoading = true
                onFollow()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    isFollowLoading = false
                }
            }, isFollowLoading: isFollowLoading)
            .padding(.horizontal, AppSpacing.cardPaddingH)
            .padding(.top, AppSpacing.cardPaddingV)

            // Media
            if let imageUrl = feedPost.imageUrl, let url = URL(string: imageUrl) {
                PostMedia(url: url)
                    .padding(.top, AppSpacing.sm)
            }

            // Body
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // Goal badge
                if let goal = feedPost.linkedGoal {
                    PostGoalBadge(goal: goal, isCompleted: feedPost.goalMarkedComplete)
                }

                // Caption
                if let caption = feedPost.caption, !caption.isEmpty {
                    PostCaption(text: caption)
                }

                // Reactions
                ReactionBar(
                    reactions: feedPost.reactions,
                    onReaction: onReaction
                )

                // Timestamp
                Text(feedPost.createdAt.relativeDisplay)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textMuted)
            }
            .padding(.horizontal, AppSpacing.cardPaddingH)
            .padding(.vertical, AppSpacing.cardPaddingV)
        }
        .cardStyle()
    }
}
