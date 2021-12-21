import Foundation
import Groundskeeper

extension URL: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral value: String) {
        self = URL(fileURLWithPath: value)
    }
}
enum FileSystemMockError: Error {
    case noEvents
    case unexpectedEvent(FileSystemMock.Event)
    case outOfBounds(index: Int, valid: Range<Int>)
}

final class FileSystemMock: FileSystemInteracting, FileSystemDirectoryProviding {

    let homeDirectoryForCurrentUser: URL
    let currentDirectoryPath: String
    let itemExistenceProvider: (URL) -> Bool

    init(
        homeDirectoryForCurrentUser: URL = URL(string: "file:///root")!,
        currentDirectoryPath: String = "/root/current_directory",
        itemExistenceProvider: @escaping (URL) -> Bool = { _ in true }
    ) {
        self.homeDirectoryForCurrentUser = homeDirectoryForCurrentUser
        self.currentDirectoryPath = currentDirectoryPath
        self.itemExistenceProvider = itemExistenceProvider
    }

    enum Event: Equatable {
        case createDirectory(URL)
        case createFile(URL, Data?)
        case removeItem(URL)
    }

    var events: [Event] = []

    func createDirectoryURL(at index: Int) throws -> URL {
        let event = try eventAt(index)
        switch event {
        case .createDirectory(let url): return url
        case .createFile, .removeItem: throw FileSystemMockError.unexpectedEvent(event)
        }
    }

    func createFileURL(at index: Int) throws -> URL {
        let event = try eventAt(index)
        switch event {
        case .createDirectory, .removeItem: throw FileSystemMockError.unexpectedEvent(event)
        case .createFile(let url, _): return url
        }
    }

    func createFileData(at index: Int) throws -> Data? {
        let event = try eventAt(index)
        switch event {
        case .createDirectory, .removeItem: throw FileSystemMockError.unexpectedEvent(event)
        case .createFile(_, let data): return data
        }
    }

    func removeItem(at index: Int) throws -> URL {
        let event = try eventAt(index)
        switch event {
        case .createDirectory, .createFile: throw FileSystemMockError.unexpectedEvent(event)
        case .removeItem(let url): return url
        }
    }

    func eventAt(_ index: Int) throws -> Event {
        if events.isEmpty { throw FileSystemMockError.noEvents }

        guard (0..<events.endIndex).contains(index) else {
            throw FileSystemMockError.outOfBounds(index: index, valid: (0..<events.endIndex))
        }

        return events[index]
    }

    // MARK: - Conformance -

    func createDirectory(at: URL) throws {
        events.append(.createDirectory(at))
    }

    func createFile(at: URL, content: Data?) throws {
        events.append(.createFile(at, content))
    }

    func removeItem(at: URL) throws {
        events.append(.removeItem(at))
    }

    func itemExists(at: URL) -> Bool {
        itemExistenceProvider(at)
    }
}
