import XCTest
@testable import Groundskeeper

class DefaultValueProvidingTests: XCTestCase {

    func testOutputPath() throws {
        let defaultValue = try FileURL(path: "/root").preferringDefaultValue { try FileURL(path: "/tmp") }
        XCTAssertEqual(defaultValue.url.absoluteString, "file:///tmp/")

        let initialValue = try FileURL(path: "/root").preferringDefaultValue { nil }
        XCTAssertEqual(initialValue.url.absoluteString, "file:///root")
    }

    func testTargetPlatform() throws {
        XCTAssertEqual(TargetPlatform.ios.preferringDefaultValue { .macos }, .macos)

        XCTAssertEqual(TargetPlatform.ios.preferringDefaultValue { nil }, .ios)
    }
}
