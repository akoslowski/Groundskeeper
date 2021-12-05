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

struct Create: ParsableCommand {
    @Argument(help: "Name of the new playground")
    var name: String?

    @Option(help: "URL to the output path where the playground will be created. Defaults to ~/Downloads")
    var outputPath: String = "~/Downloads"

    @Flag(inversion: .prefixedNo, help: "Automatically open the playground after creation")
    var autoOpen: Bool = true

    @Option(help: "Source code template for the playground page. Options are 'swift', 'swiftui' or a URL pointing to a file")
    var template: SourceCodeTemplate = .swift

    func run() throws {
        guard let url = URL(string: outputPath) else { throw GroundskeeperError.invalidURL }
        let g = Groundskeeper(fileSystem: FileManager.default)
        let targetURL = try g.createPlayground(with: name, outputURL: url, sourceCodeTemplate: template)

        if autoOpen { openWithXcode(targetURL) }

        print(targetURL.path)
    }
}

struct AddPage: ParsableCommand {
    @Argument(help: "URL to the existing playground")
    var playgroundPath: String

    @Argument(help: "Name of the new playground page")
    var pageName: String?

    @Flag(inversion: .prefixedNo, help: "Automatically open the playground after adding a page")
    var autoOpen: Bool = true

    @Option(help: "Source code template for the playground page. Options are 'swift', 'swiftui' or a URL pointing to a file")
    var template: SourceCodeTemplate = .swift

    func run() throws {
        guard let url = URL(string: playgroundPath) else { throw GroundskeeperError.invalidURL }

        let g = Groundskeeper(fileSystem: FileManager.default)
        let targetURL = try g.addPage(playgroundURL: url, pageName: pageName, sourceCodeTemplate: template)

        if autoOpen { openWithXcode(targetURL) }

        print(targetURL.path)
    }
}

GroundskeeperCommand.main()
