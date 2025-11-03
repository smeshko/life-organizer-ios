// AnimationTokens.swift
import SwiftUI

// MARK: - Animation Tokens

public extension Animation {
    /// Short animation (0.15s) - for quick feedback
    static let lifeShort = Animation.easeInOut(duration: 0.15)

    /// Medium animation (0.3s) - standard transitions
    static let lifeMedium = Animation.easeInOut(duration: 0.3)

    /// Long animation (0.6s) - dramatic transitions
    static let lifeLong = Animation.easeInOut(duration: 0.6)

    /// Spring animation - natural, bouncy motion
    /// Response: 0.55, Damping: 0.8
    static let lifeSpring = Animation.spring(response: 0.55, dampingFraction: 0.8)
}
