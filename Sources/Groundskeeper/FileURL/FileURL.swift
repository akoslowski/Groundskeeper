import Foundation

/// Explicit wrapper for URL with a file:// scheme. ``FileURL`` provides convenience for convenience URLs starting with `~/` , `.` or `./` ensuring the expected behaviour.
public struct FileURL: CustomDebugStringConvertible {

    /// Foundation.URL containing the absolute URL to a file
    public let url: URL

    /// Protocol-conforming instance for relative directories
    let fileSystem: FileSystemDirectoryProviding

    /// Designated initializer
    ///
    /// - Parameters:
    ///   - path: a local file system path to a directory or file
    ///   - fileSystem: Protocol-conforming instance for relative directories
    /// - Throws: URLError(.badURL) if the given path is empty
    public init(path: String, fileSystem: FileSystemDirectoryProviding = FileManager.default) throws {
        self.fileSystem = fileSystem

        if path.isEmpty { throw URLError(.badURL) }

        let currentDirectory = URL(fileURLWithPath: fileSystem.currentDirectoryPath)

        if path.starts(with: "~/") {
            url = fileSystem
                .homeDirectoryForCurrentUser
                .appendingPathComponent(path.removingFirstOccurrence(of: "~/"))

        } else if path == "~" {
            url = fileSystem.homeDirectoryForCurrentUser

        } else if path == "." {
            url = currentDirectory

        } else if path.starts(with: "./") {
            url = currentDirectory.appendingPathComponent(path.removingFirstOccurrence(of: "./"))

        } else if path.starts(with: "../") {
            url = currentDirectory.appendingPathComponent(path)

        } else if path == ".." {
            url = currentDirectory.appendingPathComponent(path)

        } else if path.starts(with: "/") {
            url = URL(fileURLWithPath: path)

        } else if path.starts(with: "file:") {
            url = try URL(filePath: path)

        } else {
            url = currentDirectory.appendingPathComponent(path)
        }
    }

    public var debugDescription: String {
        url.absoluteString
    }
}

extension String {
    func removingFirstOccurrence(of string: String) -> String {
        self.replacingOccurrences(of: string, with: "", options: .literal, range: self.range(of: string))
    }
}

extension URL {
    init(filePath: String) throws {
        guard let url = URL(string: filePath) else { throw URLError(.badURL) }
        self = url
    }
}
