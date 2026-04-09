import XCTest
@testable import Remindly

final class UrgencyLevelTests: XCTestCase {
    func test_none_leadOffsets() {
        XCTAssertEqual(UrgencyLevel.none.leadOffsets, [0])
    }

    func test_low_leadOffsets() {
        XCTAssertEqual(UrgencyLevel.low.leadOffsets, [-3600, 0])
    }

    func test_meeting_leadOffsets() {
        XCTAssertEqual(UrgencyLevel.meeting.leadOffsets, [-1800, -600, 0])
    }

    func test_high_isSpam() {
        XCTAssertTrue(UrgencyLevel.high.isSpam)
        XCTAssertFalse(UrgencyLevel.none.isSpam)
    }

    func test_rawValues_roundtrip() {
        for level in UrgencyLevel.allCases {
            XCTAssertEqual(UrgencyLevel(rawValue: level.rawValue), level)
        }
    }
}
