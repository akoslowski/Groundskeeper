import XCTest
@testable import Groundskeeper

class RandomNameTests: XCTestCase {
    func testSingleWords() throws {
        XCTAssertEqual(formatted("fast", "fox", configuration: .camelCased), "fastFox")
        XCTAssertEqual(formatted("fast", "fox", configuration: .capitalizedCamelCased), "FastFox")
        XCTAssertEqual(formatted("fast", "fox", configuration: .capitalizedWhitespaced), "Fast Fox")
        XCTAssertEqual(formatted("fast", "fox", configuration: .kebabCased), "fast-fox")
        XCTAssertEqual(formatted("fast", "fox", configuration: .snakeCased), "fast_fox")
    }

    func testDashedOrWhitespacedWords() throws {
        // FIXME: Result for `.camelCased` should be "furiouslyFastFoxCub"
        XCTAssertEqual(formatted("furiously-fast", "fox cub", configuration: .camelCased), "furiouslyfastFoxCub")
        XCTAssertEqual(formatted("furiously-fast", "fox cub", configuration: .capitalizedCamelCased), "FuriouslyFastFoxCub")
        XCTAssertEqual(formatted("furiously-fast", "fox cub", configuration: .capitalizedWhitespaced), "Furiously Fast Fox Cub")
        XCTAssertEqual(formatted("furiously-fast", "fox cub", configuration: .kebabCased), "furiously-fast-fox-cub")
        XCTAssertEqual(formatted("furiously-fast", "fox cub", configuration: .snakeCased), "furiously_fast_fox_cub")
    }
}
