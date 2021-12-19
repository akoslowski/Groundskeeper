import Foundation

@FileSystemBuilder func makePlayground(
    _ playgroundName: String,
    pageName: String,
    targetPlatform: TargetPlatform,
    sourceCodeTemplate: SourceCodeTemplate = .swift,
    contentProvider: (URL) throws -> Data
) throws -> FileSystem.Item {
    try rootDirectory("\(playgroundName).playground") {
        subDirectory("Sources")
        try subDirectory("Pages") {
            try subDirectory("\(pageName).xcplaygroundpage") {
                try FileSystem.Item.contentsSwift(
                    targetPlatform: targetPlatform,
                    sourceCodeTemplate: sourceCodeTemplate,
                    contentProvider: contentProvider
                )
            }
        }
        try FileSystem.Item.contentsXCPlayground(
            pageName: pageName,
            targetPlatform: targetPlatform
        )
        FileSystem.Item.playgroundXCWorkspace
    }
}

extension FileSystem.Item {
    static func xcplaygroundPage(named name: String, targetPlatform: TargetPlatform, sourceCodeTemplate: SourceCodeTemplate, contentProvider: (URL) throws -> Data) throws -> Self {
        .directory(
            .init(
                name: "\(name).xcplaygroundpage",
                content: [
                    try .contentsSwift(
                        targetPlatform: targetPlatform,
                        sourceCodeTemplate: sourceCodeTemplate,
                        contentProvider: contentProvider
                    )
                ]
            )
        )
    }

    static func contentsSwift(targetPlatform: TargetPlatform, sourceCodeTemplate: SourceCodeTemplate, contentProvider: (URL) throws -> Data) throws -> Self {
        .file(
            .init(
                name: "Contents.swift",
                content: try sourceCodeTemplate.content(
                    targetPlatform: targetPlatform,
                    contentProvider: contentProvider
                )
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

    static func contentsXCPlayground(pageName: String, targetPlatform: TargetPlatform) throws -> Self {
        .file(
            .init(
                name: "contents.xcplayground",
                content: try encode(
                    Content(targetPlatform: targetPlatform)
                )
            )
        )
    }
}
