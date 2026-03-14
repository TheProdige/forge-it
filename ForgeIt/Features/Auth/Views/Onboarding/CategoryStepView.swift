import SwiftUI

struct CategoryStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                OnboardingStepHeader(
                    step: "02 / 03",
                    title: "What are you building?",
                    subtitle: "Helps us show your content to the right people."
                )

                LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                    ForEach(EntrepreneurCategory.allCases) { category in
                        CategoryTile(
                            category: category,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.selectedCategory = category
                        }
                    }
                }

                Button {
                    viewModel.next()
                } label: {
                    Text("Continue")
                        .primaryButton()
                }
                .disabled(viewModel.selectedCategory == nil)
                .opacity(viewModel.selectedCategory == nil ? 0.4 : 1)
            }
            .padding(AppSpacing.screenPadding)
        }
    }
}

struct CategoryTile: View {
    let category: EntrepreneurCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(category.emoji)
                    .font(.system(size: 28))
                Text(category.displayName)
                    .font(AppTypography.bodySemibold)
                    .foregroundStyle(isSelected ? AppColors.textInverse : AppColors.textPrimary)
                Text(category.tagline)
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(isSelected ? AppColors.textInverse.opacity(0.7) : AppColors.textMuted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.md)
            .background(isSelected ? AppColors.accent : AppColors.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                    .strokeBorder(isSelected ? AppColors.accent : AppColors.border, lineWidth: isSelected ? 0 : 0.5)
            )
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }
}
