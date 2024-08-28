// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "self-server-rest-client",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SelfServerRESTClient",
            targets: ["SelfServerRESTClient"]
        ),
    ],
    dependencies: [
        // MARK: OpenAPI
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-async-http-client", from: "1.0.0"),
        
        // MARK: Self-Serve
        .package(
            url: "https://github.com/SelfServeApp/self-server-openapi-swift.git",
            branch: "main"
        ),
        .package(url: "https://github.com/SelfServeApp/self-server-extensions.git", from: "0.1.0"),
        
        // MARK: Helper
        .package(url: "https://github.com/edonv/swift-openapi-security-schemes", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SelfServerRESTClient",
            dependencies: [
                // MARK: OpenAPI
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                
                // MARK: Self-Serve
                .product(name: "SelfServerRESTClientStubs", package: "self-server-openapi-swift"),
                .product(name: "SelfServerHelperTypes", package: "self-server-extensions"),
                
                // MARK: Helper
                .product(name: "OpenAPISecuritySchemes", package: "swift-openapi-security-schemes"),
            ]
        ),

        .testTarget(
            name: "SelfServerOpenAPITests",
            dependencies: ["SelfServerRESTClient"]
        ),
    ]
)
