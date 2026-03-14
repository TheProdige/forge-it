import SwiftUI

enum AppTab: Int, CaseIterable {
    case friends = 0
    case explore = 1
    case capture = 2
    case progress = 3
    case profile = 4

    var title: String {
        switch self {
        case .friends: return "Friends"
        case .explore: return "Explore"
        case .capture: return "Grind"
        case .progress: return "Progress"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .friends: return "person.2"
        case .explore: return "safari"
        case .capture: return "plus"
        case .progress: return "chart.bar"
        case .profile: return "person.circle"
        }
    }

    var selectedIcon: String {
        switch self {
        case .friends: return "person.2.fill"
        case .explore: return "safari.fill"
        case .capture: return "plus"
        case .progress: return "chart.bar.fill"
        case .profile: return "person.circle.fill"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .friends
    @State private var previousTab: AppTab = .friends

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case .friends:
                    FriendsView()
                case .explore:
                    ExploreView()
                case .capture:
                    CaptureView()
                case .progress:
                    ForgeItProgressView()
                case .profile:
                    MyProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom bottom tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        ZStack {
            // Background bar
            UnevenRoundedRectangle(
                topLeadingRadius: 20,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 20
            )
            .fill(AppColors.bgSecondary)
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 20
                )
                .strokeBorder(AppColors.borderSubtle, lineWidth: 0.5)
            )
            .frame(height: 83)
            .frame(maxWidth: .infinity)

            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.rawValue) { tab in
                    if tab == .capture {
                        // Center capture button
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = tab
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(selectedTab == .capture ? AppColors.accent : AppColors.accent.opacity(0.9))
                                    .frame(width: 52, height: 52)
                                    .shadow(color: AppColors.accent.opacity(0.3), radius: 12, x: 0, y: 4)
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(AppColors.textInverse)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .offset(y: -10)
                    } else {
                        // Regular tabs
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = tab
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                                    .font(.system(size: 20))
                                    .foregroundStyle(selectedTab == tab ? AppColors.accent : AppColors.textMuted)
                                    .animation(.spring(response: 0.25), value: selectedTab)
                                Text(tab.title)
                                    .font(AppTypography.labelSmall)
                                    .foregroundStyle(selectedTab == tab ? AppColors.accent : AppColors.textMuted)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, AppSpacing.sm)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.bottom, AppSpacing.safeAreaBottom)
            .frame(height: 83)
        }
        .frame(height: 83)
    }
}
