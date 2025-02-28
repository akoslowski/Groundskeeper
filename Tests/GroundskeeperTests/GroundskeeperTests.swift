import XCTest
import Foundation
import XMLCoder
@testable import Groundskeeper

final class GroundskeeperTests: XCTestCase {
    func testCreatePlayground() throws {
        func fileContentMock(_ url: URL) throws -> Data { Data() }

        let mock = FileSystemMock()
        _ = try Groundskeeper(fileSystem: mock, fileContentProvider: fileContentMock)
            .createPlayground(
                with: "Foo",
                outputURL: FileURL(path: "/root/playgrounds"),
                targetPlatform: .ios,
                sourceCodeTemplate: .swift
            )

        XCTAssertEqual(mock.events.count, 8)
        XCTAssertEqual(try mock.createDirectoryURL(at: 0), "/root/playgrounds/Foo.playground")
        XCTAssertEqual(try mock.createDirectoryURL(at: 1), "/root/playgrounds/Foo.playground/Sources")
        XCTAssertEqual(try mock.createDirectoryURL(at: 2), "/root/playgrounds/Foo.playground/Pages")
        XCTAssertEqual(try mock.createDirectoryURL(at: 3), "/root/playgrounds/Foo.playground/Pages/First Page.xcplaygroundpage")
        XCTAssertEqual(try mock.createFileURL(at: 4),      "/root/playgrounds/Foo.playground/Pages/First Page.xcplaygroundpage/Contents.swift")
        XCTAssertEqual(try mock.createFileData(at: 4)?.count, 53)
        XCTAssertEqual(try mock.createFileURL(at: 5),      "/root/playgrounds/Foo.playground/contents.xcplayground")
        XCTAssertEqual(try mock.createFileData(at: 5)?.count, 131)
        XCTAssertEqual(try mock.createDirectoryURL(at: 6), "/root/playgrounds/Foo.playground/playground.xcworkspace")
        XCTAssertEqual(try mock.createFileURL(at: 7),      "/root/playgrounds/Foo.playground/playground.xcworkspace/contents.xcworkspacedata")
        XCTAssertEqual(try mock.createFileData(at: 7)?.count, 120)
    }

    func testContentsForNewPlayground() throws {
        let encoded = try encode(
            Content(
                version: "6.0",
                targetPlatform: .ios,
                buildActiveScheme: true
            )
        )

        let expected = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <playground version="6.0" buildActiveScheme="true" target-platform="ios" />
        """

        XCTAssertEqual(String(decoding: encoded, as: UTF8.self), expected)
    }

    func testContentsFileRoundtrip() throws {
        let data = Data("""
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <playground buildActiveScheme="true" target-platform="ios" version="6.0" />
        """.utf8)

        let content = try XMLDecoder().decode(Content.self, from: data)

        XCTAssertEqual(content.version, "6.0")

        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let encoded = try encoder.encode(
            content,
            withRootKey: "playground",
            rootAttributes: nil,
            header: XMLHeader(
                version: 1.0,
                encoding: "UTF-8",
                standalone: "yes"
            )
        )

        let roundtrip = try XMLDecoder().decode(Content.self, from: encoded)
        XCTAssertEqual(roundtrip.version, content.version)
    }

    func testAddPageToPlayground() throws {
        func fileContentMock(_ url: URL) throws -> Data {
            switch url {
            case "/root/playgrounds/Test.playground/contents.xcplayground":
                return Data("""
                <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
                <playground version="6.0" buildActiveScheme="true" target-platform="ios" />
                """.utf8)

            case "/template.swift":
                return Data("""
                // Swift content for the playground page
                """.utf8)

            default: return Data()
            }
        }

        let mock = FileSystemMock()
        _ = try Groundskeeper(fileSystem: mock, fileContentProvider: fileContentMock)
            .addPage(
                playgroundURL: FileURL(path: "/root/playgrounds/Test.playground"),
                pageName: "AddedPage",
                sourceCodeTemplate: .custom(fileAt: "/template.swift")
            )

        XCTAssertEqual(mock.events.count, 2)

        XCTAssertEqual(try mock.createDirectoryURL(at: 0), "/root/playgrounds/Test.playground/Pages/AddedPage.xcplaygroundpage")

        XCTAssertEqual(try mock.createFileURL(at: 1), "/root/playgrounds/Test.playground/Pages/AddedPage.xcplaygroundpage/Contents.swift")
        XCTAssertEqual(String(decoding: try mock.createFileData(at: 1)!, as: UTF8.self), "// Swift content for the playground page")
    }

    func testAddPageToSinglePagePlayground() throws {
        func fileContentMock(_ url: URL) throws -> Data {
            switch url {
            case "/root/playgrounds/Test.playground/contents.xcplayground":
                return Data("""
                <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
                <playground version="6.0" buildActiveScheme="true" target-platform="ios" />
                """.utf8)

            case "/template.swift":
                return Data("""
                // Swift content for the playground page
                """.utf8)

            case "/root/playgrounds/Test.playground/Contents.swift":
                return Data("""
                // Existing single page Swift content
                """.utf8)

            default: return Data()
            }
        }

        func itemExists(_ url: URL) -> Bool {
            switch url {
            case "/root/playgrounds/Test.playground/Pages": return false
            case "/root/playgrounds/Test.playground/Contents.swift": return true
            default: return false
            }
        }

        let mock = FileSystemMock(itemExistenceProvider: itemExists)
        _ = try Groundskeeper(fileSystem: mock, fileContentProvider: fileContentMock)
            .addPage(
                playgroundURL: FileURL(path: "/root/playgrounds/Test.playground"),
                pageName: "AddedPage",
                sourceCodeTemplate: .custom(fileAt: "/template.swift")
            )

        XCTAssertEqual(mock.events.count, 6)

        XCTAssertEqual(try mock.createDirectoryURL(at: 0), "/root/playgrounds/Test.playground/Pages")
        XCTAssertEqual(try mock.createDirectoryURL(at: 1), "/root/playgrounds/Test.playground/Pages/First Page.xcplaygroundpage")
        XCTAssertEqual(try mock.createFileURL(at: 2), "/root/playgrounds/Test.playground/Pages/First Page.xcplaygroundpage/Contents.swift")
        XCTAssertEqual(String(decoding: try mock.createFileData(at: 2)!, as: UTF8.self), "// Existing single page Swift content")

        XCTAssertEqual(try mock.removeItem(at: 3), "/root/playgrounds/Test.playground/Contents.swift")

        XCTAssertEqual(try mock.createDirectoryURL(at: 4), "/root/playgrounds/Test.playground/Pages/AddedPage.xcplaygroundpage")
        XCTAssertEqual(try mock.createFileURL(at: 5), "/root/playgrounds/Test.playground/Pages/AddedPage.xcplaygroundpage/Contents.swift")
        XCTAssertEqual(String(decoding: try mock.createFileData(at: 5)!, as: UTF8.self), "// Swift content for the playground page")
    }
}
