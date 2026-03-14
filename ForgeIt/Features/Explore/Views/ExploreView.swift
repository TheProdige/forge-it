import SwiftUI

struct ExploreView: View {
    @State private var viewModel = ExploreViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.bgPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search + filters
                    searchHeader

                    // Content
                    if viewModel.isLoading && viewModel.posts.isEmpty {
                        skeletonList
                    } else if viewModel.isEmpty {
                        emptyState
                    } else {
                        exploreList
                    }
                }
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.bgPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task { await viewModel.load() }
    }

    // MARK: - Search header
    private var searchHeader: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColors.textMuted)
                    .font(.system(size: 15))
                TextField("Search builders...", text: .init(
                    get: { viewModel.searchQuery },
                    set: { viewModel.searchQuery = $0 }
                ))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onSubmit { viewModel.search() }

                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.searchQuery = ""
                        viewModel.search()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppColors.textMuted)
                    }
                }
            }
            .padding(AppSpacing.sm + 2)
            .background(AppColors.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                    .strokeBorder(AppColors.border, lineWidth: 0.5)
            )
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.sm)

            // Category chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.xs) {
                    ForEach(viewModel.categories, id: \.id) { cat in
                        CategoryChip(
                            label: cat.label,
                            emoji: cat.emoji,
                            isSelected: viewModel.selectedCategory == cat.id
                        ) {
                            viewModel.selectCategory(cat.id)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, AppSpacing.xs)
            }

            Divider()
                .overlay(AppColors.borderSubtle)
        }
    }

    // MARK: - List
    private var exploreList: some View {
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
                    ProgressView().tint(AppColors.textMuted).padding()
                }

                Color.clear.frame(height: AppSpacing.bottomNavHeight)
            }
            .padding(.top, AppSpacing.sm)
        }
        .refreshable { await viewModel.refresh() }
    }

    private var skeletonList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(0..<5, id: \.self) { _ in
                    PostCardSkeleton()
                        .padding(.horizontal, AppSpacing.screenPadding)
                }
            }
            .padding(.top, AppSpacing.sm)
        }
        .allowsHitTesting(false)
    }

    private var emptyState: some View {
        EmptyState(
            icon: "🔍",
            title: "No posts found",
            message: viewModel.searchQuery.isEmpty
                ? "Be the first to post in this category."
                : "No results for \"\(viewModel.searchQuery)\".",
            ctaTitle: viewModel.searchQuery.isEmpty ? nil : "Clear search",
            ctaAction: {
                viewModel.searchQuery = ""
                viewModel.search()
            }
        )
    }
}

struct CategoryChip: View {
    let label: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji).font(.system(size: 13))
                Text(label).font(AppTypography.buttonSmall)
                    .foregroundStyle(isSelected ? AppColors.textInverse : AppColors.textSecondary)
            }
            .padding(.horizontal, AppSpacing.sm + 2)
            .padding(.vertical, 7)
            .background(isSelected ? AppColors.accent : AppColors.bgCard)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(isSelected ? Color.clear : AppColors.border, lineWidth: 0.5)
            )
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)
    }
}
