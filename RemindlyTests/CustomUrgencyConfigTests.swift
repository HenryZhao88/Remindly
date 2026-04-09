import XCTest
@testable import Remindly

final class CustomUrgencyConfigTests: XCTestCase {
    func test_noToggles_onlyEventTime() {
        let config = CustomUrgencyConfig()
        XCTAssertEqual(config.leadOffsets, [0])
    }

    func test_all_toggles() {
        var config = CustomUrgencyConfig()
        config.notify15min = true
        config.notify30min = true
        config.notify45min = true
        // Sorted furthest-first, event time last
        XCTAssertEqual(config.leadOffsets, [-2700, -1800, -900, 0])
    }

    func test_partial_toggles() {
        var config = CustomUrgencyConfig()
        config.notify15min = true
        XCTAssertEqual(config.leadOffsets, [-900, 0])
    }

    func test_codable_roundtrip() throws {
        var config = CustomUrgencyConfig()
        config.notify30min = true
        config.spamAtEventTime = true
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(CustomUrgencyConfig.self, from: data)
        XCTAssertEqual(decoded.notify30min, true)
        XCTAssertEqual(decoded.spamAtEventTime, true)
        XCTAssertEqual(decoded.notify15min, false)
    }
}
