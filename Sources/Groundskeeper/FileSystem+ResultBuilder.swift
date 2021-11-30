import Foundation

@resultBuilder
struct FileSystemBuilder {
    static func buildBlock(_ directory: FileSystem.Directory) -> FileSystem.Item {
        .directory(directory)
    }
}

@resultBuilder
struct DirectoryContentBuilder {
    static func buildBlock(_ components: FileSystem.Item...) -> [FileSystem.Item] {
        components
    }

    static func buildOptional(_ component: [FileSystem.Item]?) -> [FileSystem.Item] {
        []
    }
}

func rootDirectory(_ name: String, @DirectoryContentBuilder content: () throws -> [FileSystem.Item] = { [] }) rethrows -> FileSystem.Directory {
    .init(name: name, content: try content())
}

func file(_ name: String, content: Data = Data()) throws -> FileSystem.Item {
    .file(.init(name: name, content: content))
}

func subDirectory(_ name: String) -> FileSystem.Item {
    .directory(.init(name: name, content: []))
}

func subDirectory(_ name: String, @DirectoryContentBuilder content: () throws -> [FileSystem.Item] = { [] }) rethrows -> FileSystem.Item {
    .directory(.init(name: name, content: try content()))
}
