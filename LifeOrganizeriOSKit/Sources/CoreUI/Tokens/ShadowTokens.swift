import SwiftUI

// MARK: - View Extensions

public extension View {
    /// Subtle shadow for cards, chat bubbles, and primary surfaces
    /// - Light mode: Soft, minimal shadow (opacity 0.08, radius 4, offset y:2)
    /// - Dark mode: More prominent for depth perception (opacity 0.4, radius 6, offset y:2)
    func lifeShadowSubtle() -> some View {
        modifier(SubtleShadowModifier())
    }

    /// Elevated shadow for modals, sheets, and floating elements
    /// - Light mode: Moderate shadow for clear elevation (opacity 0.1, radius 8, offset y:4)
    /// - Dark mode: Strong shadow for maximum depth (opacity 0.6, radius 12, offset y:6)
    func lifeShadowElevated() -> some View {
        modifier(ElevatedShadowModifier())
    }
}

// MARK: - Shadow Modifiers

private struct SubtleShadowModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content.shadow(
                color: .lifeShadow.opacity(0.4),
                radius: 6,
                x: 0,
                y: 2
            )
        } else {
            content.shadow(
                color: .lifeShadow.opacity(0.08),
                radius: 4,
                x: 0,
                y: 2
            )
        }
    }
}

private struct ElevatedShadowModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content.shadow(
                color: .lifeShadow.opacity(0.6),
                radius: 12,
                x: 0,
                y: 6
            )
        } else {
            content.shadow(
                color: .lifeShadow.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
}
