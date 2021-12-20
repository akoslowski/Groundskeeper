import Foundation

extension FileSystem.Item {
    func create(at root: URL, fileSystem: FileSystemInteracting) throws {
        switch self {
        case .file(let file):
            let targetURL = root.appendingPathComponent(file.name)
            try fileSystem.createFile(at: targetURL, content: file.content)

        case .directory(let directory):
            let dirURL = root.appendingPathComponent(directory.name)
            try fileSystem.createDirectory(at: dirURL)

            try directory.content.forEach {
                try $0.create(at: dirURL, fileSystem: fileSystem)
            }
        }
    }
}
