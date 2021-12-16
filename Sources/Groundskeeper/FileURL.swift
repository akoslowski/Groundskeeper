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

        if path.starts(with: "~/") {
            url = fileSystem.homeDirectoryForCurrentUser.appendingPathComponent(path.replacingOccurrences(of: "~/", with: "", options: .literal, range: path.range(of: "~/")))

        } else if path == "~" {
            url = URL(fileURLWithPath: path.replacingOccurrences(of: "~", with: fileSystem.currentDirectoryPath))

        } else if path == "." {
            url = URL(fileURLWithPath: path.replacingOccurrences(of: ".", with: fileSystem.currentDirectoryPath))

        } else if path.starts(with: "./") {
            url = URL(fileURLWithPath: path.replacingOccurrences(of: "./", with: "\(fileSystem.currentDirectoryPath)/", options: .literal, range: path.range(of: "./")))

        } else if path.starts(with: "/") {
            url = URL(fileURLWithPath: path)

        } else if path.starts(with: "file:") {
            guard let url = URL(string: path) else { throw URLError(.badURL) }
            self.url = url

        } else {
            url = URL(fileURLWithPath: fileSystem.currentDirectoryPath).appendingPathComponent(path)
        }
    }

    public var debugDescription: String {
        url.absoluteString
    }
}
