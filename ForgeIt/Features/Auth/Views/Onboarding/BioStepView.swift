import SwiftUI

struct BioStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                OnboardingStepHeader(
                    step: "03 / 03",
                    title: "Tell your story",
                    subtitle: "Optional — but a good bio gets you more followers."
                )

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("BIO")
                        .font(AppTypography.labelSmall)
                        .foregroundStyle(AppColors.textMuted)
                        .tracking(0.5)

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                            .fill(AppColors.bgInput)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                                    .strokeBorder(AppColors.border, lineWidth: 1)
                            )
                        TextEditor(text: $vm.bio)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                            .scrollContentBackground(.hidden)
                            .padding(AppSpacing.sm)
                            .frame(minHeight: 100, maxHeight: 120)
                        if vm.bio.isEmpty {
                            Text("Building ShipFast since day 1. Obsessed with product & growth.")
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textMuted)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.top, AppSpacing.md)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(minHeight: 100)

                    Text("\(vm.bio.count) / 160")
                        .font(AppTypography.caption)
                        .foregroundStyle(vm.bio.count > 160 ? AppColors.error : AppColors.textMuted)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                Spacer(minLength: AppSpacing.xxxl)

                VStack(spacing: AppSpacing.sm) {
                    Button {
                        viewModel.next()
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView().tint(AppColors.textInverse)
                            } else {
                                Text(vm.bio.isEmpty ? "Skip for now" : "Finish setup")
                            }
                        }
                        .primaryButton()
                    }
                    .disabled(viewModel.isLoading || vm.bio.count > 160)
                }
            }
            .padding(AppSpacing.screenPadding)
        }
    }
}
