import SwiftUI

struct AppTypography {
    // MARK: - Display
    static let display   = Font.system(size: 32, weight: .bold, design: .default)
    static let heading   = Font.system(size: 28, weight: .bold)
    static let title1    = Font.system(size: 24, weight: .bold)
    static let title2    = Font.system(size: 20, weight: .semibold)
    static let title3    = Font.system(size: 17, weight: .semibold)

    // MARK: - Body
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let body      = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 13, weight: .regular)
    static let bodySemibold = Font.system(size: 15, weight: .semibold)

    // MARK: - Caption
    static let caption       = Font.system(size: 12, weight: .regular)
    static let captionMedium = Font.system(size: 12, weight: .medium)
    static let captionBold   = Font.system(size: 12, weight: .semibold)

    // MARK: - Label / UI
    static let label         = Font.system(size: 13, weight: .medium)
    static let labelSmall    = Font.system(size: 11, weight: .medium)
    static let buttonLabel   = Font.system(size: 15, weight: .semibold)
    static let buttonSmall   = Font.system(size: 13, weight: .semibold)
}
