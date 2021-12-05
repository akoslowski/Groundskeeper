import Foundation
import ArgumentParser
import Groundskeeper

func fileContentProvider(_ url: URL) throws -> Data {
    try Data(contentsOf: url)
}

extension SourceCodeTemplate: ExpressibleByArgument {
    public init?(argument: String) {
        switch argument.lowercased() {
        case "swift": self = .swift
        case "swiftui": self = .swiftUI
        default:
            if let url = URL(string: argument) {
                self = .custom(fileAt: url)
                return
            }
            return nil
        }
    }
}

func openWithXcode(_ url: URL) {
    runProcess(launchPath: "/usr/bin/xed", arguments: [url.path])
}

func runProcess(launchPath: String, arguments: [String] = []) {
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    task.standardOutput = Pipe()
    task.standardError = Pipe()
    task.launch()
    task.waitUntilExit()
}
