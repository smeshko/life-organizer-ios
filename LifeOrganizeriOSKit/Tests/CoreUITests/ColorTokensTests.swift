import Testing
import SwiftUI
@testable import CoreUI

@Suite("Color Tokens Tests")
struct ColorTokensTests {

    @Test("Background colors are defined")
    func backgroundColorsAreDefined() {
        // Verify colors are not nil by checking they exist
        _ = Color.lifeBackground
        _ = Color.lifeSurface
        _ = Color.lifeSurfaceAlt
    }

    @Test("Primary color is defined")
    func primaryColorIsDefined() {
        _ = Color.lifePrimary
    }

    @Test("Text colors are defined")
    func textColorsAreDefined() {
        _ = Color.lifeTextPrimary
        _ = Color.lifeTextSecondary
    }

    @Test("UI element colors are defined")
    func uiElementColorsAreDefined() {
        _ = Color.lifeDivider
        _ = Color.lifeShadow
        _ = Color.lifeIconDefault
    }

    @Test("All 9 color tokens exist")
    func allColorTokensExist() {
        let colors = [
            Color.lifeBackground,
            Color.lifeSurface,
            Color.lifeSurfaceAlt,
            Color.lifePrimary,
            Color.lifeTextPrimary,
            Color.lifeTextSecondary,
            Color.lifeDivider,
            Color.lifeShadow,
            Color.lifeIconDefault
        ]

        #expect(colors.count == 9)
    }
}
