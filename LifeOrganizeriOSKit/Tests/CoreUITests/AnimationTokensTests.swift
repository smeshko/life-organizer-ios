// AnimationTokensTests.swift
import Testing
import SwiftUI
@testable import CoreUI

@Suite("Animation Tokens Tests")
struct AnimationTokensTests {

    @Test("All animation tokens are defined")
    func allAnimationTokensAreDefined() {
        _ = Animation.lifeShort
        _ = Animation.lifeMedium
        _ = Animation.lifeLong
        _ = Animation.lifeSpring
    }

    @Test("All 4 animation tokens exist")
    func allAnimationTokensExist() {
        let animations = [
            Animation.lifeShort,
            Animation.lifeMedium,
            Animation.lifeLong,
            Animation.lifeSpring
        ]

        #expect(animations.count == 4)
    }
}
