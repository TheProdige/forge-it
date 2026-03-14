import SwiftUI

struct ProfileHeader: View {
    let profile: Profile?
    let stats: UserStats?
    let followingCount: Int
    let followerCount: Int
    let isOwnProfile: Bool
    let isFollowing: Bool
    let isFollowLoading: Bool
    let onFollow: () -> Void
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Avatar + follow/edit
            HStack(alignment: .top) {
                UserAvatar(profile: profile, size: 80, showBorder: true)

                Spacer()

                if isOwnProfile {
                    Button("Edit profile", action: onEdit)
                        .font(AppTypography.buttonSmall)
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, AppSpacing.md)
                        .frame(height: 34)
                        .background(AppColors.bgElevated)
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusSM))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.radiusSM)
                                .strokeBorder(AppColors.border, lineWidth: 1)
                        )
                } else {
                    FollowButton(isFollowing: isFollowing, isLoading: isFollowLoading, action: onFollow)
                }
            }

            // Name & username
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: AppSpacing.xs) {
                    Text(profile?.displayName ?? "")
                        .font(AppTypography.title2)
                        .foregroundStyle(AppColors.textPrimary)

                    if let category = profile?.entrepreneurCategory {
                        Text(category.emoji)
                            .font(.system(size: 18))
                    }
                }

                Text("@\(profile?.username ?? "")")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textMuted)

                if let bio = profile?.bio, !bio.isEmpty {
                    Text(bio)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.top, 2)
                        .lineLimit(3)
                }

                HStack(spacing: AppSpacing.sm) {
                    if let category = profile?.entrepreneurCategory {
                        InlineStatPill(icon: category.emoji, value: category.displayName, color: AppColors.textSecondary)
                    }
                    if let country = profile?.country, !country.isEmpty {
                        InlineStatPill(icon: "📍", value: country, color: AppColors.textSecondary)
                    }
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Follow counts
            HStack(spacing: AppSpacing.xl) {
                VStack(spacing: 2) {
                    Text("\(followingCount)")
                        .font(AppTypography.title3)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Following")
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(AppColors.textMuted)
                }
                VStack(spacing: 2) {
                    Text("\(followerCount)")
                        .font(AppTypography.title3)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Followers")
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(AppColors.textMuted)
                }
                Spacer()
            }
        }
    }
}
