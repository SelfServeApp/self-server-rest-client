// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SelfServerOpenAPI",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SelfServerOpenAPITypes",
            targets: ["SelfServerOpenAPITypes"]
        ),
        .library(
            name: "SelfServerOpenAPIClient",
            targets: ["SelfServerOpenAPITypes", "SelfServerOpenAPIClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-async-http-client", from: "1.0.0"),
        
        // MARK: Misc
        .package(url: "https://github.com/edonv/self-server-types.git", from: "0.0.1"),
        .package(url: "https://github.com/edonv/swift-openapi-security-schemes", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SelfServerOpenAPITypes",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                
                // MARK: Misc
                .product(name: "SelfServerTypes", package: "self-server-types"),
                .product(name: "OpenAPISecuritySchemes", package: "swift-openapi-security-schemes"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        ),
        .target(
            name: "SelfServerOpenAPIClient",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                "SelfServerOpenAPITypes",
                
                // MARK: Misc
                .product(name: "SelfServerTypes", package: "self-server-types"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        ),

        .testTarget(
            name: "SelfServerOpenAPITests",
            dependencies: ["SelfServerOpenAPIClient"]
        ),
    ]
)
