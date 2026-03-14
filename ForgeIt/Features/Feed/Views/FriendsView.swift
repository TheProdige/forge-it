import SwiftUI

struct FriendsView: View {
    @State private var viewModel = FeedViewModel()
    @State private var navigateToExplore = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.bgPrimary.ignoresSafeArea()

                if viewModel.isLoading && viewModel.posts.isEmpty {
                    skeletonView
                } else if viewModel.isEmpty {
                    emptyState
                } else {
                    feedContent
                }
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.bgPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task { await viewModel.load() }
    }

    // MARK: - Feed content
    private var feedContent: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(viewModel.posts) { feedPost in
                    PostCard(
                        feedPost: feedPost,
                        onReaction: { type in
                            Task { await viewModel.toggleReaction(postId: feedPost.id, type: type) }
                        },
                        onFollow: {
                            Task { await viewModel.toggleFollow(userId: feedPost.userId) }
                        }
                    )
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .onAppear {
                        if feedPost.id == viewModel.posts.last?.id {
                            Task { await viewModel.loadMore() }
                        }
                    }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .tint(AppColors.textMuted)
                        .padding()
                }

                // Bottom padding for tab bar
                Color.clear.frame(height: AppSpacing.bottomNavHeight)
            }
            .padding(.top, AppSpacing.sm)
        }
        .refreshable { await viewModel.refresh() }
    }

    // MARK: - Skeleton
    private var skeletonView: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(0..<4, id: \.self) { _ in
                    PostCardSkeleton()
                        .padding(.horizontal, AppSpacing.screenPadding)
                }
            }
            .padding(.top, AppSpacing.sm)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Empty state
    private var emptyState: some View {
        EmptyState(
            icon: "👥",
            title: "Your feed is empty",
            message: "Follow entrepreneurs to see their daily grind here.",
            ctaTitle: "Discover builders",
            ctaAction: { navigateToExplore = true }
        )
    }
}
