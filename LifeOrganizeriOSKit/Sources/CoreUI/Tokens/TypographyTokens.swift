import SwiftUI

// MARK: - Font Extensions

public extension Font {
    /// Large title style (34pt, bold, line height 41pt)
    /// Use for primary page headings
    static let lifeLargeTitle = Font.system(size: 34, weight: .bold)

    /// Title 1 style (28pt, semibold, line height 34pt)
    /// Use for section headings
    static let lifeTitle1 = Font.system(size: 28, weight: .semibold)

    /// Title 2 style (22pt, semibold, line height 28pt)
    /// Use for subsection headings
    static let lifeTitle2 = Font.system(size: 22, weight: .semibold)

    /// Body style (17pt, regular, line height 22pt)
    /// Use for primary body text
    static let lifeBody = Font.system(size: 17, weight: .regular)

    /// Callout style (16pt, medium, line height 21pt)
    /// Use for emphasized body text
    static let lifeCallout = Font.system(size: 16, weight: .medium)

    /// Caption style (13pt, regular, line height 18pt)
    /// Use for supporting text and labels
    static let lifeCaption = Font.system(size: 13, weight: .regular)
}

// MARK: - Line Height Modifier

/// ViewModifier to control line height for typography
struct LineHeightModifier: ViewModifier {
    let font: Font
    let lineHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .font(font)
            .lineSpacing(lineHeight * 0.2) // Approximate line spacing adjustment
    }
}

// MARK: - View Extensions

public extension View {
    /// Apply large title typography style (34pt, bold, line height 41pt)
    func lifeLargeTitle() -> some View {
        modifier(LineHeightModifier(font: .lifeLargeTitle, lineHeight: 41))
    }

    /// Apply title 1 typography style (28pt, semibold, line height 34pt)
    func lifeTitle1() -> some View {
        modifier(LineHeightModifier(font: .lifeTitle1, lineHeight: 34))
    }

    /// Apply title 2 typography style (22pt, semibold, line height 28pt)
    func lifeTitle2() -> some View {
        modifier(LineHeightModifier(font: .lifeTitle2, lineHeight: 28))
    }

    /// Apply body typography style (17pt, regular, line height 22pt)
    func lifeBody() -> some View {
        modifier(LineHeightModifier(font: .lifeBody, lineHeight: 22))
    }

    /// Apply callout typography style (16pt, medium, line height 21pt)
    func lifeCallout() -> some View {
        modifier(LineHeightModifier(font: .lifeCallout, lineHeight: 21))
    }

    /// Apply caption typography style (13pt, regular, line height 18pt)
    func lifeCaption() -> some View {
        modifier(LineHeightModifier(font: .lifeCaption, lineHeight: 18))
    }
}
