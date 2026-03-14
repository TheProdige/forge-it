import SwiftUI

struct AppColors {
    // MARK: - Backgrounds
    static let bgPrimary   = Color(red: 0.039, green: 0.039, blue: 0.039)  // #0A0A0A
    static let bgSecondary = Color(red: 0.067, green: 0.067, blue: 0.067)  // #111111
    static let bgCard      = Color(red: 0.086, green: 0.086, blue: 0.086)  // #161616
    static let bgElevated  = Color(red: 0.110, green: 0.110, blue: 0.110)  // #1C1C1C
    static let bgInput     = Color(red: 0.122, green: 0.122, blue: 0.122)  // #1F1F1F

    // MARK: - Text
    static let textPrimary   = Color.white
    static let textSecondary = Color(white: 0.627)  // #A0A0A0
    static let textMuted     = Color(white: 0.376)  // #606060
    static let textInverse   = Color(red: 0.039, green: 0.039, blue: 0.039)

    // MARK: - Accent
    /// Electric lime — builder energy, primary CTA
    static let accent        = Color(red: 0.910, green: 1.000, blue: 0.353)  // #E8FF5A
    static let accentMuted   = Color(red: 0.910, green: 1.000, blue: 0.353).opacity(0.15)
    static let accentDim     = Color(red: 0.910, green: 1.000, blue: 0.353).opacity(0.6)

    // MARK: - Borders
    static let border        = Color(white: 0.157)  // #282828
    static let borderSubtle  = Color(white: 0.118)  // #1E1E1E
    static let borderFocus   = Color(red: 0.910, green: 1.000, blue: 0.353).opacity(0.4)

    // MARK: - Reactions
    static let grindOrange   = Color(red: 1.000, green: 0.420, blue: 0.208)  // 🔥
    static let respectBlue   = Color(red: 0.420, green: 0.780, blue: 1.000)  // 💪

    // MARK: - Status
    static let success       = Color(red: 0.290, green: 0.855, blue: 0.502)  // #4ADE80
    static let error         = Color(red: 0.973, green: 0.443, blue: 0.443)  // #F87171
    static let warning       = Color(red: 0.984, green: 0.749, blue: 0.141)  // #FBBF24

    // MARK: - Streak
    static let streakFire    = Color(red: 1.000, green: 0.580, blue: 0.000)  // Warm fire
    static let streakGlow    = Color(red: 1.000, green: 0.420, blue: 0.000).opacity(0.2)
}
