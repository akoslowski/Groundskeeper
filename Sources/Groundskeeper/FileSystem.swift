import Foundation

enum FileSystem {}

extension FileSystem {
    struct File {
        let name: String
        let content: Data
    }

    struct Directory {
        let name: String
        let content: [Item]
    }

    enum Item {
        case file(File)
        case directory(Directory)
    }

    struct Playground {
        let name: String
        let manifest: [Item]

        init(name: String, items: [Item]) {
            self.name = name
            self.manifest = items
        }
    }
}

public enum FileSystemError: Error {
    case couldNotCreateFile(atPath: String)
}

public protocol FileSystemInteracting {
    var homeDirectoryForCurrentUser: URL { get }
    func createDirectory(at: URL) throws
    func createFile(at: URL, content: Data?) throws

    func replaceTildeInFileURL(_ url: URL) -> URL
}

extension FileSystemInteracting {
    public func replaceTildeInFileURL(_ url: URL) -> URL {
        if url.path.starts(with: "~/") {
            let path = url.path.replacingOccurrences(of: "~/", with: "")
            return URL(fileURLWithPath: path, relativeTo: homeDirectoryForCurrentUser)
        }
        return url
    }
}

// MARK: - FileManager Support -

extension FileManager: FileSystemInteracting {
    public func createDirectory(at url: URL) throws {
        try createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
    }

    public func createFile(at url: URL, content: Data?) throws {
        let result = createFile(atPath: url.path, contents: content, attributes: nil)
        if result == false { throw FileSystemError.couldNotCreateFile(atPath: url.path) }
    }
}
