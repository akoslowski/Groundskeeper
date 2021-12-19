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
        version: "1.2.0",
        subcommands: [Create.self, AddPage.self])
}

struct Create: ParsableCommand {
    @Argument(help: "Name of the new playground. If no name is given, a random name will be used")
    var name: String?

    @Option(help: "URL to the output path where the playground will be created")
    var outputPath: String = "~/Downloads"

    @Flag(inversion: .prefixedNo, help: "Automatically open the playground after creation using 'xed'")
    var xed: Bool = true

    @Option(help: "Source code template for the playground page. Options are 'swift', 'swiftui' or a URL pointing to content")
    var template: SourceCodeTemplate = .swift

    @Option(help: "Target platform for the new playground. Options are 'ios' or 'macos'")
    var targetPlatform: TargetPlatform = .macos

    func outputPathFromDefaults() -> FileURL? {
        if CommandLine.arguments.contains("--output-path") == false,
           let defaultValue = Defaults()?.playgroundOutputPath {
            return try? FileURL(path: defaultValue)
        }
        return nil
    }

    func run() throws {
        var outputURL = try FileURL(path: outputPath)
        if let defaultOutputURL = outputPathFromDefaults() {
            outputURL = defaultOutputURL
        }

        let targetURL = try Groundskeeper(
            fileSystem: FileManager.default,
            fileContentProvider: fileContentProvider
        )
            .createPlayground(
                with: name,
                outputURL: outputURL,
                targetPlatform: targetPlatform,
                sourceCodeTemplate: template
            )

        if xed { openWithXcode(targetURL) }

        print(targetURL.path)
    }
}

struct AddPage: ParsableCommand {
    @Argument(help: "URL to an existing playground")
    var playgroundPath: String

    @Argument(help: "Name of the new playground page. If no name is given, a random name will be used")
    var pageName: String?

    @Flag(inversion: .prefixedNo, help: "Automatically open the playground after adding a page using 'xed'")
    var xed: Bool = true

    @Option(help: "Source code template for the playground page. Options are 'swift', 'swiftui' or a URL pointing to content")
    var template: SourceCodeTemplate = .swift

    @Option(help: "Target platform for the new playground. Options are 'ios' or 'macos'")
    var targetPlatform: TargetPlatform = .macos

    func run() throws {
        let url = try FileURL(path: playgroundPath)

        let targetURL = try Groundskeeper(
            fileSystem: FileManager.default,
            fileContentProvider: fileContentProvider
        )
            .addPage(
                playgroundURL: url,
                pageName: pageName,
                targetPlatform: targetPlatform,
                sourceCodeTemplate: template
            )

        if xed { openWithXcode(targetURL) }

        print(targetURL.path)
    }
}

GroundskeeperCommand.main()
