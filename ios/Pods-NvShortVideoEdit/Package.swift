// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShortVideo",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "ShortVideo",
            targets: [
                "NvStreamingSdkCore",
                "NvShortVideoCore",
                "NvMSAICutter"
            ]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "NvStreamingSdkCore",
            path: "Frameworks/NvStreamingSdkCore.xcframework"
        ),
        .binaryTarget(
            name: "NvShortVideoCore",
            path: "Frameworks/NvShortVideoCore.xcframework"
        ),
        .binaryTarget(
            name: "NvMSAICutter",
            path: "Frameworks/NvMSAICutter.xcframework"
        )
    ]
)
