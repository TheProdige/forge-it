import SwiftUI

struct PostCaption: View {
    let text: String
    @State private var isExpanded = false

    private let maxLines = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(isExpanded ? nil : maxLines)
                .animation(.easeInOut(duration: 0.2), value: isExpanded)

            if text.count > 120 && !isExpanded {
                Button("more") {
                    isExpanded = true
                }
                .font(AppTypography.captionBold)
                .foregroundStyle(AppColors.textMuted)
            }
        }
    }
}
