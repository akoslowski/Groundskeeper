import Foundation
import XMLCoder

/// Groundskeeper provides an interface to interact with Swift playgrounds
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
        outputURL: FileURL,
        targetPlatform: TargetPlatform,
        sourceCodeTemplate: SourceCodeTemplate
    ) throws -> URL {
        let playgroundName = name ?? randomName(.capitalizedCamelCased)
        let rootURL = outputURL.url

        let playground = try makePlayground(
            playgroundName,
            pageName: "First Page",
            targetPlatform: targetPlatform,
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
        playgroundURL: FileURL,
        pageName: String?,
        sourceCodeTemplate: SourceCodeTemplate
    ) throws -> URL {
        let rootURL = playgroundURL.url
        let contentsURL = rootURL.appendingPathComponent("contents.xcplayground")
        let data = try fileContentProvider(contentsURL)
        let contents = try XMLDecoder().decode(Content.self, from: data)

        let pagesURL = rootURL.appendingPathComponent("Pages")
        let existingContentsURL = rootURL.appendingPathComponent("Contents.swift")
        let isSinglePagePlayground = fileSystem.itemExists(at: pagesURL) == false && fileSystem.itemExists(at: existingContentsURL)
        
        if isSinglePagePlayground {
            // In case of a single page playground, migrate to
            // a multi-page playground before adding a new page
            try FileSystem.Item.pagesDirectory.create(at: rootURL, fileSystem: fileSystem)

            try FileSystem.Item.xcplaygroundPage(
                named: "First Page",
                targetPlatform: contents.targetPlatform,
                sourceCodeTemplate: .custom(fileAt: existingContentsURL),
                contentProvider: fileContentProvider
            )
                .create(at: pagesURL, fileSystem: fileSystem)

            try fileSystem.removeItem(at: existingContentsURL)
        }

        let newPageName = pageName ?? randomName(.capitalizedWhitespaced)
        try FileSystem.Item.xcplaygroundPage(
            named: newPageName,
            targetPlatform: contents.targetPlatform,
            sourceCodeTemplate: sourceCodeTemplate,
            contentProvider: fileContentProvider
        )
            .create(at: pagesURL, fileSystem: fileSystem)

        return rootURL
    }
}
