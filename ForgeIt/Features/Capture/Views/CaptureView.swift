import SwiftUI
import PhotosUI

struct CaptureView: View {
    @State private var viewModel = CaptureViewModel()
    @FocusState private var captionFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.bgPrimary.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Image picker
                        ImageUploader(
                            selectedImage: viewModel.selectedImage,
                            selectedItem: .init(
                                get: { viewModel.selectedPhotoItem },
                                set: { item in
                                    viewModel.selectedPhotoItem = item
                                    Task { await viewModel.handlePhotoSelection(item) }
                                }
                            )
                        )

                        // Caption
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("WHAT DID YOU WORK ON?")
                                .font(AppTypography.labelSmall)
                                .foregroundStyle(AppColors.textMuted)
                                .tracking(0.5)

                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                                    .fill(AppColors.bgInput)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                                            .strokeBorder(captionFocused ? AppColors.borderFocus : AppColors.border, lineWidth: 1)
                                    )
                                    .frame(minHeight: 100)

                                TextEditor(text: .init(
                                    get: { viewModel.caption },
                                    set: { viewModel.caption = String($0.prefix(500)) }
                                ))
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textPrimary)
                                .scrollContentBackground(.hidden)
                                .padding(AppSpacing.sm)
                                .frame(minHeight: 100)
                                .focused($captionFocused)

                                if viewModel.caption.isEmpty && !captionFocused {
                                    Text("Shipped the MVP, fixed a bug, landed a client…")
                                        .font(AppTypography.body)
                                        .foregroundStyle(AppColors.textMuted)
                                        .padding(AppSpacing.md)
                                        .allowsHitTesting(false)
                                }
                            }

                            HStack {
                                Spacer()
                                Text("\(viewModel.captionCharCount) / 500")
                                    .font(AppTypography.caption)
                                    .foregroundStyle(viewModel.captionTooLong ? AppColors.error : AppColors.textMuted)
                            }
                        }

                        // Goal link
                        if !viewModel.goals.isEmpty {
                            GoalLinkSelect(
                                goals: viewModel.goals,
                                selectedId: .init(
                                    get: { viewModel.selectedGoalId },
                                    set: { viewModel.selectedGoalId = $0 }
                                ),
                                markComplete: .init(
                                    get: { viewModel.markGoalComplete },
                                    set: { viewModel.markGoalComplete = $0 }
                                ),
                                hasSelectedGoal: viewModel.selectedGoalId != nil
                            )
                        }

                        // Error
                        if case .error(let message) = viewModel.state {
                            Text(message)
                                .font(AppTypography.bodySmall)
                                .foregroundStyle(AppColors.error)
                                .padding(.horizontal, AppSpacing.md)
                        }

                        // Submit
                        Button {
                            hideKeyboard()
                            Task { await viewModel.submit() }
                        } label: {
                            Group {
                                if viewModel.isSubmitting {
                                    ProgressView().tint(AppColors.textInverse)
                                } else {
                                    Text("Post grind")
                                }
                            }
                            .primaryButton()
                        }
                        .disabled(!viewModel.isValid || viewModel.isSubmitting || viewModel.captionTooLong)
                        .opacity((viewModel.isValid && !viewModel.captionTooLong) ? 1 : 0.4)

                        Color.clear.frame(height: AppSpacing.bottomNavHeight)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.top, AppSpacing.md)
                }
            }
            .navigationTitle("Daily Grind")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.bgPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task { await viewModel.loadGoals() }
        .overlay(alignment: .top) {
            if viewModel.showSuccessToast {
                SuccessToast(message: "Grind posted. Keep it up.")
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation { viewModel.showSuccessToast = false }
                        }
                    }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.showSuccessToast)
    }
}

struct SuccessToast: View {
    let message: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Text("🔥")
            Text(message)
                .font(AppTypography.bodySemibold)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm + 2)
        .background(AppColors.bgElevated)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(AppColors.border, lineWidth: 0.5))
        .padding(.top, 60)
        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
    }
}
