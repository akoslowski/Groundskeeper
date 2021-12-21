import Foundation
import ArgumentParser
import Groundskeeper

func fileContentProvider(_ url: URL) throws -> Data {
    try Data(contentsOf: url)
}

extension TargetPlatform: ExpressibleByArgument {}

extension SourceCodeTemplate: ExpressibleByArgument {}

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
