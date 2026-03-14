import SwiftUI

struct OnboardingFlow: View {
    @State private var viewModel = OnboardingViewModel()
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            AppColors.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                ProgressBar(value: viewModel.progress)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.sm)
                    .animation(.spring(duration: 0.4), value: viewModel.step)

                // Step content
                Group {
                    switch viewModel.step {
                    case .username:
                        UsernameStepView()
                    case .category:
                        CategoryStepView()
                    case .bio:
                        BioStepView()
                    case .done:
                        DoneStepView(onComplete: onComplete)
                    }
                }
                .environment(viewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.step)
            }
        }
        .onChange(of: viewModel.isComplete) { _, complete in
            if complete { onComplete() }
        }
    }
}

struct ProgressBar: View {
    let value: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: AppSpacing.radiusFull)
                    .fill(AppColors.bgElevated)
                    .frame(height: 3)
                RoundedRectangle(cornerRadius: AppSpacing.radiusFull)
                    .fill(AppColors.accent)
                    .frame(width: geo.size.width * value, height: 3)
            }
        }
        .frame(height: 3)
    }
}
