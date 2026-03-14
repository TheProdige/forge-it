import SwiftUI

struct ProfileView: View {
    let userId: UUID
    @State private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.bgPrimary.ignoresSafeArea()

                if viewModel.isLoading && viewModel.profile == nil {
                    profileSkeleton
                } else {
                    profileContent
                }
            }
            .navigationTitle(viewModel.profile?.username.map { "@\($0)" } ?? "Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.bgPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                if viewModel.isOwnProfile {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showEditProfile = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
            }
        }
        .task { await viewModel.load(userId: userId) }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .presentationBackground(AppColors.bgSecondary)
        }
    }

    private var profileContent: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                // Header
                ProfileHeader(
                    profile: viewModel.profile,
                    stats: viewModel.stats,
                    followingCount: viewModel.followingCount,
                    followerCount: viewModel.followerCount,
                    isOwnProfile: viewModel.isOwnProfile,
                    isFollowing: viewModel.isFollowing,
                    isFollowLoading: viewModel.isFollowLoading,
                    onFollow: { Task { await viewModel.toggleFollow() } },
                    onEdit: { showEditProfile = true }
                )
                .padding(.horizontal, AppSpacing.screenPadding)

                // Stats row
                if let stats = viewModel.stats {
                    ProfileStats(stats: stats)
                        .padding(.horizontal, AppSpacing.screenPadding)
                }

                // Posts
                if viewModel.posts.isEmpty {
                    EmptyState(
                        icon: "📸",
                        title: "No posts yet",
                        message: viewModel.isOwnProfile
                            ? "Post your first grind to start your journey."
                            : "This builder hasn't posted yet.",
                        ctaTitle: nil,
                        ctaAction: nil
                    )
                    .frame(height: 300)
                } else {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("BUILD HISTORY")
                            .font(AppTypography.labelSmall)
                            .foregroundStyle(AppColors.textMuted)
                            .tracking(0.5)
                            .padding(.horizontal, AppSpacing.screenPadding)

                        UserPostsList(posts: viewModel.posts)
                    }
                }

                Color.clear.frame(height: AppSpacing.bottomNavHeight)
            }
            .padding(.top, AppSpacing.md)
        }
        .refreshable { await viewModel.refresh(userId: userId) }
    }

    private var profileSkeleton: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                // Avatar placeholder
                Circle()
                    .fill(AppColors.bgElevated)
                    .frame(width: 80, height: 80)
                    .shimmer()
                    .padding(.top, AppSpacing.md)
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonRect(height: 70, radius: AppSpacing.radiusLG)
                        .padding(.horizontal, AppSpacing.screenPadding)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
