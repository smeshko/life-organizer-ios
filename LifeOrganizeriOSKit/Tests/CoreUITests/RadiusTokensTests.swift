import Testing
import SwiftUI
@testable import CoreUI

@Suite("Radius Tokens Tests")
struct RadiusTokensTests {

    @Test("Radius values match design specification")
    func radiusValuesMatchSpec() {
        #expect(CGFloat.lifeRadiusNone == 0)
        #expect(CGFloat.lifeRadiusSM == 6)
        #expect(CGFloat.lifeRadiusMD == 12)
        #expect(CGFloat.lifeRadiusLG == 24)
        #expect(CGFloat.lifeRadiusXL == 32)
        #expect(CGFloat.lifeRadiusPill == 999)
    }

    @Test("All 6 radius tokens exist")
    func allRadiusTokensExist() {
        let radii = [
            CGFloat.lifeRadiusNone,
            CGFloat.lifeRadiusSM,
            CGFloat.lifeRadiusMD,
            CGFloat.lifeRadiusLG,
            CGFloat.lifeRadiusXL,
            CGFloat.lifeRadiusPill
        ]

        #expect(radii.count == 6)
    }
}
