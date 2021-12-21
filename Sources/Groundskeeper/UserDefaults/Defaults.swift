import Foundation

public protocol KeyValueStorage {
    func string(forKey: String) -> String?
}

public struct Defaults {
    public static let suiteName = "com.groundskeeper.playground"

    let storage: KeyValueStorage

    public init?(storage: KeyValueStorage? = UserDefaults(suiteName: suiteName)) {
        guard let storage = storage else { return nil }
        self.storage = storage
    }

    public var playgroundOutputPath: String? {
        storage.string(forKey: "GKPlaygroundOutputPath")
    }

    public var playgroundTargetPlatform: String? {
        storage.string(forKey: "GKPlaygroundTargetPlatform")
    }

    // MARK: -

    public var outputURL: FileURL? {
        guard let value = playgroundOutputPath else { return nil }
        return try? FileURL(path: value)
    }

    public var targetPlatform: TargetPlatform? {
        guard let value = playgroundTargetPlatform else { return nil }
        return TargetPlatform(argument: value)
    }
}

extension UserDefaults: KeyValueStorage {}
