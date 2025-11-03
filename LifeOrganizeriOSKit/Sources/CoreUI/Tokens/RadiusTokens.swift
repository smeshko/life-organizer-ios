import SwiftUI

// MARK: - Radius Tokens

public extension CGFloat {
    /// No rounding (0pt)
    /// Use for sharp corners and rectangular shapes
    static let lifeRadiusNone: CGFloat = 0

    /// Small radius (6pt)
    /// Use for subtle rounding on buttons and small elements
    static let lifeRadiusSM: CGFloat = 6

    /// Medium radius (12pt)
    /// Use for standard rounding on cards and panels
    static let lifeRadiusMD: CGFloat = 12

    /// Large radius (24pt)
    /// Use for prominent rounding on large elements
    static let lifeRadiusLG: CGFloat = 24

    /// Extra large radius (32pt)
    /// Use for very round corners on special elements
    static let lifeRadiusXL: CGFloat = 32

    /// Pill radius (999pt)
    /// Use for fully rounded ends on buttons and badges
    static let lifeRadiusPill: CGFloat = 999
}
