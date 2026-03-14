import SwiftUI

struct UsernameStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                OnboardingStepHeader(
                    step: "01 / 03",
                    title: "Choose your username",
                    subtitle: "This is how the community will know you."
                )

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("USERNAME")
                        .font(AppTypography.labelSmall)
                        .foregroundStyle(AppColors.textMuted)
                        .tracking(0.5)

                    HStack {
                        Text("@")
                            .font(AppTypography.bodyLarge)
                            .foregroundStyle(AppColors.textSecondary)
                        TextField("yourhandle", text: $vm.username)
                            .font(AppTypography.bodyLarge)
                            .foregroundStyle(AppColors.textPrimary)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .onChange(of: vm.username) { _, _ in
                                Task { await viewModel.validateUsername() }
                            }
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.bgInput)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                            .strokeBorder(borderColor, lineWidth: 1)
                    )

                    // Status message
                    HStack(spacing: 6) {
                        if viewModel.isCheckingUsername {
                            ProgressView().scaleEffect(0.7)
                            Text("Checking...")
                                .font(AppTypography.captionMedium)
                                .foregroundStyle(AppColors.textMuted)
                        } else if let error = viewModel.usernameError {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(AppColors.error)
                            Text(error)
                                .font(AppTypography.captionMedium)
                                .foregroundStyle(AppColors.error)
                        } else if viewModel.usernameAvailable == true {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(AppColors.success)
                            Text("Available")
                                .font(AppTypography.captionMedium)
                                .foregroundStyle(AppColors.success)
                        } else {
                            Text("At least 3 characters. Letters, numbers, underscores.")
                                .font(AppTypography.captionMedium)
                                .foregroundStyle(AppColors.textMuted)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: viewModel.usernameAvailable)
                }

                Spacer(minLength: AppSpacing.xxxl)

                Button {
                    viewModel.next()
                } label: {
                    Text("Continue")
                        .primaryButton()
                }
                .disabled(!viewModel.canProceedFromUsername)
                .opacity(viewModel.canProceedFromUsername ? 1 : 0.4)
            }
            .padding(AppSpacing.screenPadding)
        }
    }

    private var borderColor: Color {
        if let available = viewModel.usernameAvailable {
            return available ? AppColors.success.opacity(0.5) : AppColors.error.opacity(0.5)
        }
        return AppColors.border
    }
}
