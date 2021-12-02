import Foundation
import ArgumentParser
import Groundskeeper

enum GroundskeeperError: Error {
    case invalidURL
}

struct GroundskeeperCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "playground",
        abstract: "A utility for performing actions on Swift playgrounds.",
        version: "1.0.0",
        subcommands: [Create.self, AddPage.self])
}

struct AddPage: ParsableCommand {
    @Argument(help: "URL to the existing playground")
    var playgroundPath: String

    @Argument(help: "Name of the new playground page")
    var pageName: String?

    @Flag(inversion: .prefixedNo, help: "Automatically open the playground after adding a page")
    var autoOpen: Bool = true

    func run() throws {
        let url = URL(fileURLWithPath: playgroundPath)

        let g = Groundskeeper(fileSystem: FileManager.default)
        let targetURL = try g.addPage(playgroundURL: url, pageName: pageName)

        if autoOpen { openWithXcode(targetURL) }

        print(targetURL.path)
    }
}

struct Create: ParsableCommand {
    @Argument(help: "Name of the new playground")
    var name: String?

    @Option(help: "URL to the output path where the playground will be created. Defaults to ~/Downloads")
    var outputPath: String?

    @Flag(inversion: .prefixedNo, help: "Automatically open the playground after creation")
    var autoOpen: Bool = true

    func run() throws {
        guard let url = URL(string: outputPath ?? "~/Downloads") else { throw GroundskeeperError.invalidURL }
        let g = Groundskeeper(fileSystem: FileManager.default)
        let targetURL = try g.createPlayground(with: name, outputURL: url)

        if autoOpen { openWithXcode(targetURL) }

        print(targetURL.path)
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

GroundskeeperCommand.main()
