import SwiftUI

struct AddGoalSheet: View {
    @Bindable var viewModel: ProgressViewModel
    @FocusState private var titleFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            // Handle
            Capsule()
                .fill(AppColors.border)
                .frame(width: 36, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, AppSpacing.sm)

            Text("New goal")
                .font(AppTypography.title2)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.md)

            VStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("GOAL")
                        .font(AppTypography.labelSmall)
                        .foregroundStyle(AppColors.textMuted)
                        .tracking(0.5)
                    TextField("Ship landing page v2, Land 3 new clients…", text: .init(
                        get: { viewModel.newGoalTitle },
                        set: { viewModel.newGoalTitle = $0 }
                    ))
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .focused($titleFocused)
                    .padding(AppSpacing.md)
                    .background(AppColors.bgInput)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                            .strokeBorder(titleFocused ? AppColors.borderFocus : AppColors.border, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, AppSpacing.md)

            if let err = viewModel.addGoalError {
                Text(err)
                    .font(AppTypography.bodySmall)
                    .foregroundStyle(AppColors.error)
                    .padding(.horizontal, AppSpacing.md)
            }

            Button {
                Task { await viewModel.addGoal() }
            } label: {
                Group {
                    if viewModel.isAddingGoal {
                        ProgressView().tint(AppColors.textInverse)
                    } else {
                        Text("Add goal")
                    }
                }
                .primaryButton()
            }
            .disabled(viewModel.isAddingGoal || viewModel.newGoalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(viewModel.newGoalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
            .padding(.horizontal, AppSpacing.md)

            Spacer()
        }
        .background(AppColors.bgSecondary)
        .onAppear { titleFocused = true }
    }
}
