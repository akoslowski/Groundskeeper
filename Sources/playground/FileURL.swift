import Foundation

protocol FileURLDirectoryProviding {
    var homeDirectoryForCurrentUser: URL { get }
    var currentDirectoryPath: String { get }
}

extension FileManager: FileURLDirectoryProviding {}

struct FileURL: CustomDebugStringConvertible {

    let url: URL
    let fileSystem: FileURLDirectoryProviding

    init(path: String, fileSystem: FileURLDirectoryProviding = FileManager.default) throws {
        self.fileSystem = fileSystem

        if path.isEmpty { throw URLError(.badURL) }

        if path.starts(with: "~/") {
            url = fileSystem.homeDirectoryForCurrentUser.appendingPathComponent(path.replacingOccurrences(of: "~/", with: "", options: .literal, range: path.range(of: "~/")))

        } else if path == "." {
            url = URL(fileURLWithPath: path.replacingOccurrences(of: ".", with: fileSystem.currentDirectoryPath))

        } else if path.starts(with: "./") {
            url = URL(fileURLWithPath: path.replacingOccurrences(of: "./", with: "\(fileSystem.currentDirectoryPath)/", options: .literal, range: path.range(of: "./")))

        } else {
            url = URL(fileURLWithPath: path)
        }
    }

    var debugDescription: String {
        url.absoluteString
    }
}
