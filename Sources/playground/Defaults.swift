import Foundation

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
}

extension UserDefaults: KeyValueStorage {}
