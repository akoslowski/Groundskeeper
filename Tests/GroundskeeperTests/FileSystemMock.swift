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

final class FileSystemMock: FileSystemInteracting {
    enum Event: Equatable {
        case createDirectory(URL)
        case createFile(URL, Data?)
    }

    var events: [Event] = []

    func createDirectoryURL(at index: Int) throws -> URL {
        let event = try event(at: index)
        switch event {
        case .createDirectory(let url): return url
        case .createFile: throw FileSystemMockError.unexpectedEvent(event)
        }
    }

    func createFileURL(at index: Int) throws -> URL {
        let event = try event(at: index)
        switch event {
        case .createDirectory: throw FileSystemMockError.unexpectedEvent(event)
        case .createFile(let url, _): return url
        }
    }

    func createFileData(at index: Int) throws -> Data? {
        let event = try event(at: index)
        switch event {
        case .createDirectory: throw FileSystemMockError.unexpectedEvent(event)
        case .createFile(_, let data): return data
        }
    }

    func event(at index: Int) throws -> Event {
        if events.isEmpty { throw FileSystemMockError.noEvents }

        guard (0..<events.endIndex).contains(index) else {
            throw FileSystemMockError.outOfBounds(index: index, valid: (0..<events.endIndex))
        }

        return events[index]
    }

    // MARK: - Conformance -

    var homeDirectoryForCurrentUser: URL = URL(fileURLWithPath: "/root")

    func createDirectory(at: URL) throws {
        events.append(.createDirectory(at))
    }

    func createFile(at: URL, content: Data?) throws {
        events.append(.createFile(at, content))
    }
}
