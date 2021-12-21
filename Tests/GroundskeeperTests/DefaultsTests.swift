import XCTest
@testable import Groundskeeper

class DefaultsTests: XCTestCase {
    func testAllValuesAreNilByDefault() throws {
        let defaults = try XCTUnwrap(Defaults([:]))
        XCTAssertNil(defaults.playgroundOutputPath)
        XCTAssertNil(defaults.outputURL)
        XCTAssertNil(defaults.playgroundTargetPlatform)
        XCTAssertNil(defaults.targetPlatform)
    }

    func testExistingValues() throws {
        let defaults = try XCTUnwrap(Defaults(["GKPlaygroundOutputPath": "/tmp", "GKPlaygroundTargetPlatform": "ios"]))
        XCTAssertEqual(defaults.playgroundOutputPath, "/tmp")
        XCTAssertEqual(defaults.outputURL?.url.absoluteString, "file:///tmp/")
        XCTAssertEqual(defaults.playgroundTargetPlatform, "ios")
        XCTAssertEqual(defaults.targetPlatform, .ios)
    }
}

// MARK: -

extension Defaults {
    init?(_ storageMock: KeyValueStorageMock) {
        self.init(storage: storageMock)
    }
}

struct KeyValueStorageMock: KeyValueStorage, ExpressibleByDictionaryLiteral {
    typealias Key = String
    typealias Value = String

    private let storage: [Key: Value]

    init(dictionaryLiteral elements: (String, String)...) {
        var storage = [Key: Value]()
        elements.forEach { (key, value) in
            storage[key] = value
        }
        self.storage = storage
    }

    func string(forKey key: String) -> String? {
        storage[key]
    }
}
