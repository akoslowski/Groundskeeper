import Foundation
import XMLCoder

public struct Groundskeeper {
    /// File system abstraction for all interactions, like file- or directory creation
    let fileSystem: FileSystemInteracting

    /// function to provide data from a given URL, e.g. for reading a source code template, or any existing file
    let fileContentProvider: (URL) throws -> Data

    /// Designated initializer
    ///
    /// - Parameter fileSystem: File system abstraction for all interactions, like file- or directory creation
    public init(fileSystem: FileSystemInteracting, fileContentProvider: @escaping (URL) throws -> Data) {
        self.fileSystem = fileSystem
        self.fileContentProvider = fileContentProvider
    }

    /// Creates a new playground with a single page
    ///
    /// - Parameters:
    ///   - name: Name of the new playground; defaults to a random name
    ///   - outputURL: URL to the directory where the playground will be stored
    /// - Returns: URL to the new playground
    public func createPlayground(
        with name: String?,
        outputURL: URL,
        sourceCodeTemplate: SourceCodeTemplate
    ) throws -> URL {
        let playgroundName = name ?? randomName(.capitalizedCamelCased)
        let rootURL = fileSystem.replaceTildeInFileURL(outputURL)

        let playground = try makePlayground(
            playgroundName,
            pageName: "First Page",
            sourceCodeTemplate: sourceCodeTemplate,
            contentProvider: fileContentProvider
        )
        try playground.create(at: rootURL, fileSystem: fileSystem)

        let playgroundRoot = rootURL.appendingPathComponent(playground.name)
        return playgroundRoot
    }

    /// Adds a new page to an existing playground
    ///
    /// - Parameters:
    ///   - playgroundURL: URL to an existing playground
    ///   - pageName: Optional name for the page; defaults to a random name
    /// - Returns: URL to the existing, changed playground
    public func addPage(
        playgroundURL: URL,
        pageName: String?,
        sourceCodeTemplate: SourceCodeTemplate
    ) throws -> URL {
        let rootURL = fileSystem.replaceTildeInFileURL(playgroundURL)
        let contentsURL = rootURL
            .appendingPathComponent("contents.xcplayground")
        let data = try fileContentProvider(contentsURL)
        let contents = try XMLDecoder().decode(Content.self, from: data)

        let newPageName = pageName ?? randomName(.capitalizedWhitespaced)
        let newContent = try contents.adding(Page(name: newPageName))
        let newData = try encode(newContent)
        try fileSystem.createFile(at: contentsURL, content: newData)
        try FileSystem.Item.xcplaygroundPage(
            named: newPageName,
            sourceCodeTemplate: sourceCodeTemplate,
            contentProvider: fileContentProvider
        )
            .create(at: rootURL.appendingPathComponent("Pages"), fileSystem: fileSystem)

        return rootURL
    }
}
