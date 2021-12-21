import Foundation
import Groundskeeper

protocol KeyValueStorage {
    func string(forKey: String) -> String?
}

struct Defaults {
    static let suiteName = "com.groundskeeper.playground"

    private let storage: KeyValueStorage

    init?(storage: KeyValueStorage? = UserDefaults(suiteName: suiteName)) {
        guard let storage = storage else { return nil }
        self.storage = storage
    }

    var playgroundOutputPath: String? {
        storage.string(forKey: "GKPlaygroundOutputPath")
    }

    var playgroundTargetPlatform: String? {
        storage.string(forKey: "GKPlaygroundTargetPlatform")
    }

    // MARK: -

    var outputURL: FileURL? {
        guard let value = playgroundOutputPath else { return nil }
        return try? FileURL(path: value)
    }

    var targetPlatform: TargetPlatform? {
        guard let value = playgroundTargetPlatform else { return nil }
        return TargetPlatform(argument: value)
    }
}

extension UserDefaults: KeyValueStorage {}
