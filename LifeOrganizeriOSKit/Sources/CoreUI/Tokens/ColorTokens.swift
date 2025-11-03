import SwiftUI

public extension Color {
    // MARK: - Backgrounds

    /// Main background color for the app
    /// - Light: #FFFFFF (white)
    /// - Dark: #212121 (dark gray)
    static let lifeBackground = Color("Life/Background", bundle: .module)

    /// Primary surface color for cards and panels
    /// - Light: #F7F7F8 (light gray)
    /// - Dark: #2F2F2F (medium dark gray)
    static let lifeSurface = Color("Life/Surface", bundle: .module)

    /// Alternative surface color for nested elements
    /// - Light: #FFFFFF (white)
    /// - Dark: #424242 (medium gray)
    static let lifeSurfaceAlt = Color("Life/SurfaceAlt", bundle: .module)

    // MARK: - Primary

    /// Primary brand color for buttons and accents
    /// - Light: #10A37F (teal)
    /// - Dark: #1BC47D (bright teal)
    static let lifePrimary = Color("Life/Primary", bundle: .module)

    // MARK: - Text

    /// Primary text color for body content
    /// - Light: #000000 (black)
    /// - Dark: #ECECEC (light gray)
    static let lifeTextPrimary = Color("Life/TextPrimary", bundle: .module)

    /// Secondary text color for labels and captions
    /// - Light: #6E6E80 (medium gray)
    /// - Dark: #B4B4B4 (light gray)
    static let lifeTextSecondary = Color("Life/TextSecondary", bundle: .module)

    // MARK: - UI Elements

    /// Divider and border color
    /// - Light: #E5E5E5 (light gray)
    /// - Dark: #3F3F3F (dark gray)
    static let lifeDivider = Color("Life/Divider", bundle: .module)

    /// Shadow color for depth effects
    /// - Light: #000000 (black)
    /// - Dark: #000000 (black)
    static let lifeShadow = Color("Life/Shadow", bundle: .module)

    /// Default icon color
    /// - Light: #6E6E80 (medium gray)
    /// - Dark: #B4B4B4 (light gray)
    static let lifeIconDefault = Color("Life/IconDefault", bundle: .module)
}
