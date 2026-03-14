import SwiftUI

struct RootView: View {
    @State private var authVM = AuthViewModel()
    @State private var authService = AuthService.shared
    @State private var isCheckingSession = true

    var body: some View {
        Group {
            if isCheckingSession {
                splashView
            } else if !authVM.isAuthenticated {
                AuthRootView()
                    .environment(authVM)
                    .transition(.opacity)
            } else if AuthService.shared.needsOnboarding {
                OnboardingFlow {
                    // Onboarding complete — reload session
                    Task { await AuthService.shared.refreshSession() }
                }
                .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authVM.isAuthenticated)
        .task {
            await AuthService.shared.refreshSession()
            isCheckingSession = false
        }
    }

    private var splashView: some View {
        ZStack {
            AppColors.bgPrimary.ignoresSafeArea()
            VStack(spacing: AppSpacing.md) {
                Text("🔥")
                    .font(.system(size: 64))
                Text("Forge It")
                    .font(AppTypography.heading)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Show what you're building today.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}
