import Foundation

@FileSystemBuilder func makePlayground(
    _ playgroundName: String,
    pageName: String,
    sourceCodeTemplate: SourceCodeTemplate = .swift
) throws -> FileSystem.Item {
    try rootDirectory("\(playgroundName).playground") {
        subDirectory("Sources")
        try subDirectory("Pages") {
            try subDirectory("\(pageName).xcplaygroundpage") {
                try FileSystem.Item.contentsSwift(sourceCodeTemplate)
            }
        }
        try FileSystem.Item.contentsXCPlayground(pageName: pageName)
        FileSystem.Item.playgroundXCWorkspace
    }
}

extension FileSystem.Item {
    static func playgroundPage(named name: String, sourceCodeTemplate: SourceCodeTemplate) throws -> Self {
        .directory(
            .init(
                name: "\(name).xcplaygroundpage",
                content: [
                    try .contentsSwift(sourceCodeTemplate)
                ]
            )
        )
    }

//    static var contentsSwift: Self {
//        .file(
//            .init(
//                name: "Contents.swift",
//                content: try! SourceCodeTemplate.swift.content()
//            )
//        )
//    }

    static func contentsSwift(_ sourceCodeTemplate: SourceCodeTemplate) throws -> Self {
        .file(
            .init(
                name: "Contents.swift",
                content: try sourceCodeTemplate.content()
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

    static func contentsXCPlayground(pageName: String) throws -> Self {
        .file(
            .init(
                name: "contents.xcplayground",
                content: try encode(
                    Content(pages: [Page(name: pageName)])
                )
            )
        )
    }
}
