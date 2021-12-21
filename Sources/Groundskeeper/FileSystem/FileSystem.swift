import Foundation

/// Namespace for file system related models and interactions
enum FileSystem {}

extension FileSystem {
    /// Structure representing a file
    struct File {
        let name: String
        let content: Data
    }

    /// Structure representing a directory
    struct Directory {
        let name: String
        let content: [Item]
    }

    /// Type representing either a file or a dictionary
    enum Item {
        case file(File)
        case directory(Directory)

        /// Name of associated the file or dictionary
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

/// Requirements for interacting with the file system
public protocol FileSystemInteracting {
    /// Creates a directory at the given file URL
    func createDirectory(at: URL) throws
    /// Creates a file at the given file URL and data
    func createFile(at: URL, content: Data?) throws
    /// Removes an item at the given file URL
    func removeItem(at: URL) throws
    /// Returns a Boolean value that indicates whether a file or directory exists at the given URL
    func itemExists(at: URL) -> Bool
}

/// Requirements for locations on the file system
public protocol FileSystemDirectoryProviding {
    /// URL of the home directory for the current user
    var homeDirectoryForCurrentUser: URL { get }
    /// The path to the program’s current directory
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

extension FileManager: FileSystemDirectoryProviding {
    public var homeDirectoryForCurrentUser: URL {
        URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
    }
}
