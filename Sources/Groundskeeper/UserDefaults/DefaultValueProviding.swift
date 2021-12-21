import Foundation

public protocol DefaultValueProviding {
    associatedtype T

    /// Provides a shim over nil coalescing in a default-value-block
    /// - Returns: the default value, if a non-nil-value is returned from the block, or otherwise the initial value
    func preferringDefaultValue(_ defaultValue: () throws -> T?) rethrows -> T
}

extension TargetPlatform: DefaultValueProviding {
    public func preferringDefaultValue(_ defaultValue: () throws -> Self?) rethrows -> Self {
        try defaultValue() ?? self
    }
}

extension FileURL: DefaultValueProviding {
    public func preferringDefaultValue(_ defaultValue: () throws -> Self?) rethrows -> Self {
        try defaultValue() ?? self
    }
}
