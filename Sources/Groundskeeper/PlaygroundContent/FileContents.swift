import Foundation
import XMLCoder

// MARK: - Playground - content.xcplayground -

public enum TargetPlatform: String, Codable {
    case ios, macos

    public init?(argument: String) {
        switch argument.lowercased() {
        case "ios": self = .ios
        case "macos": self = .macos
        default: self = .macos
        }
    }
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
        case version, buildActiveScheme
        case targetPlatform = "target-platform"
    }

    let version: String
    let targetPlatform: TargetPlatform
    let buildActiveScheme: Bool

    init(version: String = "6.0", targetPlatform: TargetPlatform, buildActiveScheme: Bool = true) {
        self.version = version
        self.targetPlatform = targetPlatform
        self.buildActiveScheme = buildActiveScheme
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

