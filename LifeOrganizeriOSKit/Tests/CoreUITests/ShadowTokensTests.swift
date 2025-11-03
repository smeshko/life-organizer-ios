// ShadowTokensTests.swift
import Testing
import SwiftUI
@testable import CoreUI

@Suite("Shadow Tokens Tests")
struct ShadowTokensTests {

    @Test("Shadow modifiers compile without errors")
    @MainActor
    func shadowModifiersCompile() {
        let view = Rectangle()

        _ = view.lifeShadowSubtle()
        _ = view.lifeShadowElevated()
    }

    @Test("Both shadow levels exist")
    @MainActor
    func bothShadowLevelsExist() {
        let subtleShadow = Rectangle().lifeShadowSubtle()
        let elevatedShadow = Rectangle().lifeShadowElevated()

        // Verify modifiers can be applied
        _ = subtleShadow
        _ = elevatedShadow
    }
}
