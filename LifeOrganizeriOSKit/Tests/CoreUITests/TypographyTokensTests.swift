import Testing
import SwiftUI
@testable import CoreUI

@Suite("Typography Tokens Tests")
struct TypographyTokensTests {

    @Test("All font styles are defined")
    func allFontStylesAreDefined() {
        _ = Font.lifeLargeTitle
        _ = Font.lifeTitle1
        _ = Font.lifeTitle2
        _ = Font.lifeBody
        _ = Font.lifeCallout
        _ = Font.lifeCaption
    }

    @Test("All 6 typography tokens exist")
    func allTypographyTokensExist() {
        let fonts = [
            Font.lifeLargeTitle,
            Font.lifeTitle1,
            Font.lifeTitle2,
            Font.lifeBody,
            Font.lifeCallout,
            Font.lifeCaption
        ]

        #expect(fonts.count == 6)
    }

    @Test("View modifiers compile without errors")
    @MainActor
    func viewModifiersCompile() {
        let text = Text("Test")

        _ = text.lifeLargeTitle()
        _ = text.lifeTitle1()
        _ = text.lifeTitle2()
        _ = text.lifeBody()
        _ = text.lifeCallout()
        _ = text.lifeCaption()
    }
}
