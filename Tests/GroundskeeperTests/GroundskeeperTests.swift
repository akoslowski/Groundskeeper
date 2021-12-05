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
                outputURL: URL(fileURLWithPath: "/root/playgrounds"),
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
        XCTAssertEqual(try mock.createFileData(at: 5)?.count, 203)
        XCTAssertEqual(try mock.createDirectoryURL(at: 6), "/root/playgrounds/Foo.playground/playground.xcworkspace")
        XCTAssertEqual(try mock.createFileURL(at: 7),      "/root/playgrounds/Foo.playground/playground.xcworkspace/contents.xcworkspacedata")
        XCTAssertEqual(try mock.createFileData(at: 7)?.count, 120)
    }

    func testContentsForNewPlayground() throws {
        let encoded = try encode(
            Content(
                version: "6.0",
                targetPlatform: "ios",
                buildActiveScheme: true,
                pages: [Page(name: "First Page")]
            )
        )

        let expected = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <playground version="6.0" buildActiveScheme="true" target-platform="ios">
            <pages>
                <page name="First Page" />
            </pages>
        </playground>
        """

        XCTAssertEqual(String(decoding: encoded, as: UTF8.self), expected)
    }

    func testContentsFileRoundtrip() throws {
        let data = Data("""
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <playground buildActiveScheme="true" target-platform="ios" version="6.0">
            <pages>
                <page name='First Page'/>
                <page name='2nd Page'/>
                <page name='3rd Page'/>
            </pages>
        </playground>
        """.utf8)

        let content = try XMLDecoder().decode(Content.self, from: data)

        XCTAssertEqual(content.version, "6.0")
        XCTAssertEqual(content.pages.values.count, 3)

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
        print(String(decoding: encoded, as: UTF8.self))

        let roundtrip = try XMLDecoder().decode(Content.self, from: encoded)
        XCTAssertEqual(roundtrip.version, content.version)
        XCTAssertEqual(roundtrip.pages.values.count, content.pages.values.count)
    }

    func testAddPageToPlayground() throws {
        func fileContentMock(_ url: URL) throws -> Data {
            switch url {
            case "/root/playgrounds/Test.playground/contents.xcplayground":
                return Data("""
                <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
                <playground version="6.0" buildActiveScheme="true" target-platform="ios">
                    <pages>
                        <page name="ExistingPage" />
                    </pages>
                </playground>
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
                playgroundURL: "/root/playgrounds/Test.playground",
                pageName: "AddedPage",
                sourceCodeTemplate: .custom(fileAt: "/template.swift")
            )

        XCTAssertEqual(mock.events.count, 3)
        XCTAssertEqual(try mock.createFileURL(at: 0), "/root/playgrounds/Test.playground/contents.xcplayground")

        let newContent = try XMLCoder.XMLDecoder().decode(Content.self, from: try mock.createFileData(at: 0)!)
        XCTAssertEqual(newContent.pages.values.count, 2)
        XCTAssertEqual(newContent.pages.values[0].name, "ExistingPage")
        XCTAssertEqual(newContent.pages.values[1].name, "AddedPage")

        XCTAssertEqual(try mock.createDirectoryURL(at: 1), "/root/playgrounds/Test.playground/Pages/AddedPage.xcplaygroundpage")

        XCTAssertEqual(try mock.createFileURL(at: 2), "/root/playgrounds/Test.playground/Pages/AddedPage.xcplaygroundpage/Contents.swift")
        XCTAssertEqual(String(decoding: try mock.createFileData(at: 2)!, as: UTF8.self), "// Swift content for the playground page")
    }
}
