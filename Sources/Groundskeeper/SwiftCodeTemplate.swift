import Foundation

public enum SourceCodeTemplate {
    case custom(fileAt: URL)
    case swift
    case swiftUI

    func content(targetPlatform: TargetPlatform, contentProvider: (URL) throws -> Data) throws -> Data {
        switch (self, targetPlatform) {
        case (.custom(fileAt: let url), _):
            return try contentProvider(url)

        case (.swift, _):
            return Data("""
            import Foundation

            let greeting = "Hello, playground"
            """.utf8)

        case (.swiftUI, .ios):
            return Data(#"""
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
            """#.utf8)
        case (.swiftUI, .macos):
            return Data(#"""
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
            """#.utf8)
        }
    }

}
