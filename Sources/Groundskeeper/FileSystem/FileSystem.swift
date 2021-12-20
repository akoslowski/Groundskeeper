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

        var name: String {
            switch self {
            case .file(let file): return file.name
            case .directory(let directory): return directory.name
            }
        }
    }
}

public enum FileSystemError: Error {
    case couldNotCreateFile(atPath: String)
}

public protocol FileSystemInteracting {
    func createDirectory(at: URL) throws
    func createFile(at: URL, content: Data?) throws
    func removeItem(at: URL) throws
    func itemExists(at: URL) -> Bool
}

public protocol FileSystemDirectoryProviding {
    var homeDirectoryForCurrentUser: URL { get }
    var currentDirectoryPath: String { get }
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

    public func itemExists(at: URL) -> Bool {
        fileExists(atPath: at.path)
    }
}

extension FileManager: FileSystemDirectoryProviding {}
