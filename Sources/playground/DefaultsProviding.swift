import Foundation
import struct Groundskeeper.FileURL
import enum Groundskeeper.TargetPlatform

protocol DefaultsProviding {
    associatedtype T

    /// Convenience function for a default value to take precedence over the initial value
    /// - Returns: Self or a default value if available
    func or(_ defaultValue: (Defaults?) throws -> T?) rethrows -> T
}

extension TargetPlatform: DefaultsProviding {
    func or(_ defaultValue: (Defaults?) throws -> Self?) rethrows -> Self {
        try defaultValue(Defaults()) ?? self
    }
}

extension FileURL: DefaultsProviding {
    func or(_ defaultValue: (Defaults?) throws -> Self?) rethrows -> Self {
        try defaultValue(Defaults()) ?? self
    }
}
