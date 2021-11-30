import Foundation
import XMLCoder

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

    init(version: String = "6.0", targetPlatform: String = "ios", buildActiveScheme: Bool = true, pages: [Page]) {
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

// MARK: - Content encoder -

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

