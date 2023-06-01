import Foundation

@FileSystemBuilder func makePackagePlayground(
    _ playgroundName: String,
    pageName: String,
    targetPlatform: TargetPlatform = .macos,
    sourceCodeTemplate: SourceCodeTemplate = .swift,
    contentProvider: (URL) throws -> Data
) throws -> FileSystem.Item {

    let rootDirName = "\(playgroundName)"

    try rootDirectory(rootDirName) {
        FileSystem.Item.file(
            .init(
                name: "Package.swift",
                content: Data("""
                // swift-tools-version: 5.7
                // The swift-tools-version declares the minimum version of Swift required to build this package.

                import PackageDescription

                let package = Package(
                    name: "\(playgroundName)",
                    platforms: [.macOS(.v12)],
                    products: [
                        // Products define the executables and libraries a package produces, and make them visible to other packages.
                        .library(
                            name: "\(playgroundName)",
                            targets: ["\(playgroundName)"]),
                    ],
                    dependencies: [
                        // Dependencies declare other packages that this package depends on.
                        // .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
                        // .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
                    ],
                    targets: [
                        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
                        // Targets can depend on other targets in this package, and on products in packages this package depends on.
                        .target(
                            name: "\(playgroundName)",
                            dependencies: [
                                // .product(name: "Algorithms", package: "swift-algorithms"),
                                // .product(name: "Collections", package: "swift-collections"),
                            ],
                            path: "\(playgroundName).playground/Sources"
                        ),
                        .testTarget(
                            name: "\(playgroundName)Tests",
                            dependencies: ["\(playgroundName)"]),
                    ]
                )
                """.utf8)
            )
        )
        FileSystem.Item.file(
            .init(
                name: "README.md",
                content: Data("""
                # \(playgroundName) Package Playground

                Hello. I'm a package with a playground included.
                """.utf8)
            )
        )
        subDirectory("Tests") {
            subDirectory("\(rootDirName)Tests") {
                FileSystem.Item.file(
                    .init(
                        name: "\(rootDirName)Tests.swift",
                        content: Data("""
                        import XCTest
                        @testable import \(playgroundName)

                        final class \(playgroundName)Tests: XCTestCase {
                            func testTest() throws {
                                XCTAssertEqual(\(playgroundName)().greeting, "Hello Package Playground")
                            }
                        }
                        """.utf8)
                    )
                )
            }
        }

        try subDirectory("\(playgroundName).playground") {
            subDirectory("Resources")
            subDirectory("Sources") {
                FileSystem.Item.file(
                    .init(
                        name: "\(playgroundName).swift",
                        content: Data("""
                        import Foundation

                        public struct \(playgroundName) {
                            public init() {}

                            public let greeting = "Hello Package Playground"
                        }
                        """.utf8)
                    )
                )
            }
            subDirectory("Pages") {
                subDirectory("\(pageName).xcplaygroundpage") {
                    FileSystem.Item.file(
                        .init(
                            name: "Contents.swift",
                            content: Data("""
                            import Foundation

                            let greeting = \(playgroundName)().greeting

                            print(greeting)
                            """.utf8)
                        )
                    )
                }
            }
            try FileSystem.Item.contentsXCPlayground(
                pageName: pageName,
                targetPlatform: targetPlatform
            )
            FileSystem.Item.playgroundXCWorkspace
        }
    }
}
