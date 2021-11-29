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

    func run() throws {
        let url = URL(fileURLWithPath: playgroundPath)

        let g = Groundskeeper(fileSystem: FileManager.default)
        let targetURL = try g.addPage(playgroundURL: url, pageName: pageName)

        print(targetURL.path)
    }
}

struct Create: ParsableCommand {
    @Argument(help: "Name of the new playground")
    var name: String?

    @Option(help: "URL to the output path where the playground will be created. Defaults to ~/Downloads")
    var outputPath: String?

    func run() throws {
        guard let url = URL(string: outputPath ?? "~/Downloads") else { throw GroundskeeperError.invalidURL }
        let g = Groundskeeper(fileSystem: FileManager.default)
        let targetURL = try g.createPlayground(with: name, outputURL: url)

        print(targetURL.path)
    }
}

GroundskeeperCommand.main()
