import Foundation

public enum SourceCodeTemplate {
    case custom(fileAt: URL)
    case swift
    case swiftUI

    func content(contentProvider: (URL) throws -> Data) throws -> Data {
        switch self {
        case .custom(fileAt: let url):
            return try contentProvider(url)

        case .swift:
            return Data("""
            import Foundation

            let greeting = "Hello, playground"
            """.utf8)

        case .swiftUI:
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
        }
    }

}
