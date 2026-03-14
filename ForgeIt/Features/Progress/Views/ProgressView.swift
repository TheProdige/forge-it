import SwiftUI

// NOTE: Named GrindProgressView to avoid collision with SwiftUI.ProgressView.
// Navigation uses ForgeItProgressView (ForgeItProgressView.swift) which
// has the same implementation. This file is kept as a reference.
struct GrindProgressView: View {
    @State private var viewModel = ProgressViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.bgPrimary.ignoresSafeArea()

                if viewModel.isLoading && viewModel.goals.isEmpty {
                    progressSkeleton
                } else {
                    mainContent
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.bgPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task { await viewModel.load() }
        .sheet(isPresented: .init(
            get: { viewModel.showAddGoalSheet },
            set: { viewModel.showAddGoalSheet = $0 }
        )) {
            AddGoalSheet(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationBackground(AppColors.bgSecondary)
                .presentationDragIndicator(.visible)
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                // Streak card
                StreakCard(stats: viewModel.stats, streak: viewModel.currentStreak)
                    .padding(.horizontal, AppSpacing.screenPadding)

                // Today's check-in
                TodayCheckinCard(summary: viewModel.dailySummary)
                    .padding(.horizontal, AppSpacing.screenPadding)

                // Daily progress
                if viewModel.dailySummary.totalGoals > 0 {
                    DailyProgressCard(summary: viewModel.dailySummary)
                        .padding(.horizontal, AppSpacing.screenPadding)
                }

                // Goals list
                GoalsList(viewModel: viewModel)
                    .padding(.horizontal, AppSpacing.screenPadding)

                Color.clear.frame(height: AppSpacing.bottomNavHeight)
            }
            .padding(.top, AppSpacing.md)
        }
        .refreshable { await viewModel.refresh() }
    }

    private var progressSkeleton: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                ForEach(0..<4, id: \.self) { _ in
                    SkeletonRect(height: 80, radius: AppSpacing.radiusLG)
                        .padding(.horizontal, AppSpacing.screenPadding)
                }
            }
            .padding(.top, AppSpacing.md)
        }
        .allowsHitTesting(false)
    }
}
