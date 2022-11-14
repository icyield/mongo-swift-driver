// swift-tools-version:5.1

///  To avoid breaking Swift 5.1 compatibility, only require newer NIO versions when we need NIO's concurrency APIs.
func getMinNIOVersion() -> PackageDescription.Package.Dependency.Requirement {
#if compiler(>=5.5.2) && canImport(_Concurrency)
    return .upToNextMajor(from: "2.36.0")
#else
    return .upToNextMajor(from: "2.15.0")
#endif
}

import PackageDescription
let package = Package(
    name: "mongo-swift-driver",
    platforms: [
        .macOS(.v10_14)
    ],
    products: [
        .library(name: "MongoSwift", targets: ["MongoSwift"]),
        .library(name: "MongoSwiftSync", targets: ["MongoSwiftSync"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/apple/swift-nio", getMinNIOVersion()),
        .package(url: "https://github.com/icyield/swift-bson", .branch("jsondefaultint64"))
    ],
    targets: [
        .target(name: "MongoSwiftSync", dependencies: ["MongoSwift", "NIO"]),
        .target(name: "AtlasConnectivity", dependencies: ["MongoSwiftSync"]),
        .target(name: "TestsCommon", dependencies: ["MongoSwift", "Nimble"]),
        .testTarget(name: "BSONTests", dependencies: ["MongoSwift", "TestsCommon", "Nimble", "CLibMongoC"]),
        .testTarget(name: "MongoSwiftTests", dependencies: ["MongoSwift", "TestsCommon", "Nimble", "NIO", "NIOConcurrencyHelpers"]),
        .testTarget(name: "MongoSwiftSyncTests", dependencies: ["MongoSwiftSync", "TestsCommon", "Nimble", "MongoSwift"]),
        .target(
            name: "CLibMongoC",
            dependencies: [],
            linkerSettings: [
                .linkedLibrary("resolv"),
                .linkedLibrary("ssl", .when(platforms: [.linux])),
                .linkedLibrary("crypto", .when(platforms: [.linux])),
                .linkedLibrary("z", .when(platforms: [.linux]))
            ]
        )
    ]
)

#if compiler(>=5.3)
package.dependencies += [.package(url: "https://github.com/apple/swift-atomics", .upToNextMajor(from: "1.0.0"))]
package.targets += [.target(name: "MongoSwift", dependencies: ["Atomics", "CLibMongoC", "NIO", "NIOConcurrencyHelpers", "SwiftBSON"])]
#else
package.targets += [.target(name: "MongoSwift", dependencies: ["CLibMongoC", "NIO", "NIOConcurrencyHelpers", "SwiftBSON"])]
#endif
