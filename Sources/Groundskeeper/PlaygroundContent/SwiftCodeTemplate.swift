import Foundation

public enum SourceCodeTemplate {
    case custom(fileAt: URL)
    case swift
    case swiftUI

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

    func content(targetPlatform: TargetPlatform, contentProvider: (URL) throws -> Data) throws -> Data {
        switch (self, targetPlatform) {
        case (.custom(fileAt: let url), _):
            return try contentProvider(url)

        case (.swift, _):
            return Data(swiftTemplate.utf8)

        case (.swiftUI, .ios):
            return Data(iOSSwiftUITemplate.utf8)

        case (.swiftUI, .macos):
            return Data(macOSSwiftUITemplate.utf8)
        }
    }
}

var swiftTemplate: String {
    """
    import Foundation

    let greeting = "Hello, playground"
    """
}

var iOSSwiftUITemplate: String {
    #"""
    import SwiftUI
    import PlaygroundSupport

    struct DemoView: View {
        let name: String

        var body: some View {
            Text("Hello \(name)")
                .font(.largeTitle)
                .padding()
        }
    }

    PlaygroundPage.current.liveView = UIHostingController(rootView: DemoView(name: "Paula"))
    """#
}

var macOSSwiftUITemplate: String {
    #"""
    import SwiftUI
    import PlaygroundSupport

    struct DemoView: View {
        let name: String

        var body: some View {
            Text("Hello \(name)")
                .font(.largeTitle)
                .padding()
        }
    }

    PlaygroundPage.current.liveView = NSHostingController(rootView: DemoView(name: "Paula"))
    """#
}
