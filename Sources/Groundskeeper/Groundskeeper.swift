import Foundation
import XMLCoder

struct File {
    let name: String
    let content: Data
}

struct Directory {
    let name: String
    let content: [Item]
}

enum Item {
    case file(File)
    case directory(Directory)
}

struct Playground {
    let name: String
    let manifest: [Item]

    init(name: String, items: [Item]) {
        self.name = name
        self.manifest = items
    }
}

// MARK: - Static content -

extension Item {
    static func playgroundPage(named name: String) -> Self {
        .directory(
            .init(
                name: "\(name).xcplaygroundpage",
                content: [
                    .contentsSwift
                ]
            )
        )
    }

    static func pagesDirectory(pages: [Item]) -> Self {
        .directory(
            .init(
                name: "Pages",
                content: pages
            )
        )
    }

    static var sources: Self { .directory(.init(name: "Sources", content: [])) }

    static var contentsSwift: Self {
        .file(
            .init(
                name: "Contents.swift",
                content: Data("""
                import Foundation

                let greeting = "Hello, playground"
                """.utf8)
            )
        )
    }

    static var playgroundXCWorkspace: Self {
        .directory(
            .init(
                name: "playground.xcworkspace",
                content: [
                    .file(
                        .init(
                            name: "contents.xcworkspacedata",
                            content: Data("""
                            <?xml version="1.0" encoding="UTF-8"?>
                            <Workspace version = "1.0">
                                <FileRef location="self:"></FileRef>
                            </Workspace>
                            """.utf8)
                        )
                    )
                ]
            )
        )
    }

    static func playgroundContentWithSinglePage(pageName: String) throws -> Self {
        .file(
            .init(
                name: "contents.xcplayground",
                content: try encode(
                    Content(
                        version: "6.0",
                        targetPlatform: "ios",
                        buildActiveScheme: true,
                        pages: [Page(name: pageName)]
                    )
                )
            )
        )
    }
}

// MARK: - Playground - content.xcplayground -

struct Page: Codable, DynamicNodeEncoding {
    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        .attribute
    }

    let name: String
}

struct Pages: Codable {
    enum CodingKeys: String, CodingKey {
        case values = "page"
    }

    let values: [Page]
}

struct Content: Codable, DynamicNodeEncoding {
    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case CodingKeys.version, CodingKeys.targetPlatform, CodingKeys.buildActiveScheme:
            return .attribute
        default:
            return .element
        }
    }

    enum CodingKeys: String, CodingKey {
        case version, buildActiveScheme, pages
        case targetPlatform = "target-platform"
    }

    let version: String
    let targetPlatform: String
    let buildActiveScheme: Bool

    let pages: Pages

    init(version: String, targetPlatform: String, buildActiveScheme: Bool, pages: [Page]) {
        self.version = version
        self.targetPlatform = targetPlatform
        self.buildActiveScheme = buildActiveScheme
        self.pages = .init(values: pages)
    }

    func adding(_ page: Page) throws -> Self {
        .init(
            version: version,
            targetPlatform: targetPlatform,
            buildActiveScheme: buildActiveScheme,
            pages: pages.values + [page]
        )
    }
}

func encode(_ content: Content) throws -> Data {
    let encoder = XMLEncoder()
    encoder.outputFormatting = [.prettyPrinted]
    return try encoder.encode(
        content,
        withRootKey: "playground",
        rootAttributes: nil,
        header: XMLHeader(
            version: 1.0,
            encoding: "UTF-8",
            standalone: "yes"
        )
    )
}

// MARK: - Groundskeeper - Create Playground -

public struct Groundskeeper {
    let fileSystem: FileSystemInteracting

    public init(fileSystem: FileSystemInteracting) {
        self.fileSystem = fileSystem
    }

    /// Creates a new playground with a single page
    public func createPlayground(with name: String?, outputURL: URL) throws -> URL {
        let playgroundName = name ?? randomName()
        let fileName = "\(playgroundName).playground"
        let pageName = "First Page"
        let playground = Playground(
            name: playgroundName,
            items: [
                .sources,
                .pagesDirectory(pages: [.playgroundPage(named: pageName)]),
                try .playgroundContentWithSinglePage(pageName: pageName),
                .playgroundXCWorkspace
            ]
        )

        let rootURL = fileSystem.replaceTildeInFileURL(outputURL)
        let playgroundRoot = rootURL.appendingPathComponent(fileName)
        try fileSystem.createDirectory(at: playgroundRoot)

        try playground.manifest.forEach {
            try $0.create(at: playgroundRoot, fileSystem: fileSystem)
        }

        return playgroundRoot
    }

    public func addPage(playgroundURL: URL, pageName: String?) throws -> URL {
        let rootURL = fileSystem.replaceTildeInFileURL(playgroundURL)
        let contentsURL = rootURL
            .appendingPathComponent("contents.xcplayground")
        let data = try Data(contentsOf: contentsURL)
        let contents = try XMLDecoder().decode(Content.self, from: data)

        let newPageName = pageName ?? uniqueString()
        let newContent = try contents.adding(Page(name: newPageName))
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let newData = try encoder.encode(
            newContent,
            withRootKey: "playground",
            rootAttributes: nil,
            header: XMLHeader(
                version: 1.0,
                encoding: "UTF-8",
                standalone: "yes"
            )
        )
        try fileSystem.createFile(at: contentsURL, content: newData)
        try Item.playgroundPage(named: newPageName).create(at: rootURL.appendingPathComponent("Pages"), fileSystem: fileSystem)

        return rootURL
    }
}

// MARK: -

func uniqueString(length: Int = 4) -> String {
    UUID().uuidString.prefix(length).lowercased()
}
