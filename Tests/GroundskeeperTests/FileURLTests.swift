import XCTest
@testable import Groundskeeper

class FileURLTests: XCTestCase {

    // Mock uses default values:
    // - homeDirectoryForCurrentUser: URL = URL(string: "file:///root")!,
    // - currentDirectoryPath: String     = "/root/current_directory"
    let fileSystem = FileSystemMock()

    func testThrowsOnInvalidFileURL() throws {
        XCTAssertThrowsError(try FileURL(path: "", fileSystem: fileSystem))
    }

    func testFileURLFromAbsolutePath() throws {
        let fileURL = try FileURL(path: "/some/absolute/path", fileSystem: fileSystem)
        XCTAssertEqual(fileURL.url, URL(string: "file:///some/absolute/path"))
    }

    func testFileURLFromRelativePath() throws {
        let fileURL = try FileURL(path: "some/relative/path", fileSystem: fileSystem)
        XCTAssertEqual(fileURL.url.absoluteURL, URL(string: "file:///root/current_directory/some/relative/path"))
    }

    func testFileURLFromRelativePathWithDot() throws {
        let fileURL = try FileURL(path: ".", fileSystem: fileSystem)
        XCTAssertEqual(fileURL.url.absoluteURL, URL(string: "file:///root/current_directory"))
    }

    func testFileURLFromRelativePathWithDotSlash() throws {
        let fileURL = try FileURL(path: "./some/path", fileSystem: fileSystem)
        XCTAssertEqual(fileURL.url.absoluteURL, URL(string: "file:///root/current_directory/some/path"))
    }

    func testFileURLFromRelativePathWithDotDot() throws {
        let fileURL = try FileURL(path: "..", fileSystem: fileSystem)
        XCTAssertEqual(fileURL.url.absoluteURL, URL(string: "file:///root/current_directory/.."))
    }

    func testFileURLFromRelativePathWithDotDotSlash() throws {
        let fileURL = try FileURL(path: "../some/path", fileSystem: fileSystem)
        XCTAssertEqual(fileURL.url.absoluteURL, URL(string: "file:///root/current_directory/../some/path"))
    }

    func testFileURLFromPathWithTilde() throws {
        let fileURL = try FileURL(path: "~", fileSystem: fileSystem)
        XCTAssertEqual(fileURL.url.absoluteURL, URL(string: "file:///root/current_directory"))
    }

    func testFileURLFromPathWithTildeSlash() throws {
        let fileURL = try FileURL(path: "~/some/path", fileSystem: fileSystem)
        XCTAssertEqual(fileURL.url.absoluteURL, URL(string: "file:///root/some/path"))
    }

    func testFileURLFromAbsoluteFileURL() throws {
        let fileURL = try FileURL(path: "file:///some/path", fileSystem: fileSystem)
        XCTAssertEqual(fileURL.url.absoluteURL, URL(string: "file:///some/path"))
    }
}
