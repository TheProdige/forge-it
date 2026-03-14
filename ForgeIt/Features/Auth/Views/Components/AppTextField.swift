import SwiftUI

struct AppTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(label.uppercased())
                .font(AppTypography.labelSmall)
                .foregroundStyle(AppColors.textMuted)
                .tracking(0.5)

            TextField(placeholder, text: $text)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(AppSpacing.md)
                .background(AppColors.bgInput)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                        .strokeBorder(AppColors.border, lineWidth: 1)
                )
        }
    }
}

struct AppSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @State private var isVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(label.uppercased())
                .font(AppTypography.labelSmall)
                .foregroundStyle(AppColors.textMuted)
                .tracking(0.5)

            HStack {
                if isVisible {
                    TextField(placeholder, text: $text)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } else {
                    SecureField(placeholder, text: $text)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                }

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .foregroundStyle(AppColors.textMuted)
                        .font(.system(size: 15))
                }
            }
            .padding(AppSpacing.md)
            .background(AppColors.bgInput)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMD))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMD)
                    .strokeBorder(AppColors.border, lineWidth: 1)
            )
        }
    }
}
