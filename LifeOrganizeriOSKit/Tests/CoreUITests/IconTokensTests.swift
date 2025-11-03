// IconTokensTests.swift
import Testing
import SwiftUI
@testable import CoreUI

@Suite("Icon Tokens Tests")
struct IconTokensTests {

    @Test("All icon size tokens are defined")
    func allIconSizeTokensAreDefined() {
        _ = Font.lifeIconSM
        _ = Font.lifeIconMD
        _ = Font.lifeIconLG
    }

    @Test("All icon weight tokens are defined")
    func allIconWeightTokensAreDefined() {
        _ = Font.lifeIconRegular
        _ = Font.lifeIconAccent
    }

    @Test("Icon color tokens are defined")
    func iconColorTokensAreDefined() {
        _ = Color.lifeIconDefault
        _ = Color.lifeIconActive
    }

    @Test("All 5 icon font tokens exist")
    func allIconFontTokensExist() {
        let iconFonts = [
            Font.lifeIconSM,
            Font.lifeIconMD,
            Font.lifeIconLG,
            Font.lifeIconRegular,
            Font.lifeIconAccent
        ]

        #expect(iconFonts.count == 5)
    }
}
