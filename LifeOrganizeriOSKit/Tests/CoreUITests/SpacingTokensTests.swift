import Testing
import SwiftUI
@testable import CoreUI

@Suite("Spacing Tokens Tests")
struct SpacingTokensTests {

    @Test("Spacing values match design specification")
    func spacingValuesMatchSpec() {
        #expect(CGFloat.lifeSpacingXXS == 2)
        #expect(CGFloat.lifeSpacingXS == 4)
        #expect(CGFloat.lifeSpacingSM == 8)
        #expect(CGFloat.lifeSpacingMD == 16)
        #expect(CGFloat.lifeSpacingLG == 24)
        #expect(CGFloat.lifeSpacingXL == 32)
        #expect(CGFloat.lifeSpacingXXL == 48)
    }

    @Test("All 7 spacing tokens exist")
    func allSpacingTokensExist() {
        let spacings = [
            CGFloat.lifeSpacingXXS,
            CGFloat.lifeSpacingXS,
            CGFloat.lifeSpacingSM,
            CGFloat.lifeSpacingMD,
            CGFloat.lifeSpacingLG,
            CGFloat.lifeSpacingXL,
            CGFloat.lifeSpacingXXL
        ]

        #expect(spacings.count == 7)
    }
}
