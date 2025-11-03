// IconTokens.swift
import SwiftUI

// MARK: - Icon Size Tokens

public extension Font {
    /// Small icon size (16pt) - for inline icons
    static let lifeIconSM = Font.system(size: 16)

    /// Medium icon size (20pt) - standard icons
    static let lifeIconMD = Font.system(size: 20)

    /// Large icon size (28pt) - prominent icons
    static let lifeIconLG = Font.system(size: 28)

    /// Regular weight icon (20pt) - default icon style
    static let lifeIconRegular = Font.system(size: 20, weight: .regular)

    /// Accent weight icon (20pt) - emphasized icons
    static let lifeIconAccent = Font.system(size: 20, weight: .semibold)
}

// MARK: - Icon Color Tokens

public extension Color {
    /// Active/selected icon color (uses primary brand color)
    static let lifeIconActive = Color.lifePrimary
}
