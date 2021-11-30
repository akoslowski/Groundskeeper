import Foundation

@FileSystemBuilder func makePlayground(_ playgroundName: String, pageName: String) throws -> FileSystem.Item {
    try rootDirectory("\(playgroundName).playground") {
        subDirectory("Sources")
        subDirectory("Pages") {
            subDirectory("\(pageName).xcplaygroundpage") {
                FileSystem.Item.contentsSwift
            }
        }
        try FileSystem.Item.playgroundContentWithSinglePage(pageName: pageName)
        FileSystem.Item.playgroundXCWorkspace
    }
}

extension FileSystem.Item {
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

    static func pagesDirectory(pages: [FileSystem.Item]) -> Self {
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
                    Content(pages: [Page(name: pageName)])
                )
            )
        )
    }
}
