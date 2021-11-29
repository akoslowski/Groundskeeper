import Foundation
import XMLCoder

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
        let playground = FileSystem.Playground(
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
        let newData = try encode(newContent)
        try fileSystem.createFile(at: contentsURL, content: newData)
        try FileSystem.Item.playgroundPage(named: newPageName).create(at: rootURL.appendingPathComponent("Pages"), fileSystem: fileSystem)

        return rootURL
    }
}

// MARK: -

func uniqueString(length: Int = 4) -> String {
    UUID().uuidString.prefix(length).lowercased()
}
