import SwiftUI

struct UserPostsList: View {
    let posts: [Post]

    var body: some View {
        LazyVStack(spacing: AppSpacing.sm) {
            ForEach(posts) { post in
                UserPostRow(post: post)
                    .padding(.horizontal, AppSpacing.screenPadding)
            }
        }
    }
}

struct UserPostRow: View {
    let post: Post

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // Thumbnail
            if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        AppColors.bgElevated
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusSM))
            } else {
                ZStack {
                    AppColors.bgElevated
                    Image(systemName: "text.bubble")
                        .foregroundStyle(AppColors.textMuted)
                        .font(.system(size: 18))
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusSM))
            }

            VStack(alignment: .leading, spacing: 5) {
                if let caption = post.caption, !caption.isEmpty {
                    Text(caption)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                }

                if let goal = post.linkedGoal {
                    PostGoalBadge(goal: goal, isCompleted: post.goalMarkedComplete)
                }

                Text(post.createdAt.relativeDisplay)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textMuted)
            }

            Spacer()
        }
        .padding(AppSpacing.sm)
        .cardStyle()
    }
}
