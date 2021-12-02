import Foundation

enum SwiftCodeTemplate {
    static var swiftDefault: Data {
        Data("""
        import Foundation

        let greeting = "Hello, playground"
        """.utf8)
    }

    static var swiftUIDefault: Data {
        Data(#"""
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
