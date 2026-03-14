import SwiftUI

struct DoneStepView: View {
    let onComplete: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            VStack(spacing: AppSpacing.md) {
                Text("🔥")
                    .font(.system(size: 72))
                    .scaleEffect(appeared ? 1 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: appeared)

                VStack(spacing: AppSpacing.sm) {
                    Text("You're in.")
                        .font(AppTypography.heading)
                        .foregroundStyle(AppColors.textPrimary)

                    Text("Now show the world what you're building.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)
            }

            Spacer()

            Button {
                onComplete()
            } label: {
                Text("Start your grind")
                    .primaryButton()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.4), value: appeared)

            Spacer().frame(height: AppSpacing.xl)
        }
        .onAppear { appeared = true }
    }
}
