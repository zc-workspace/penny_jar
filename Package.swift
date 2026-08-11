// swift-tools-version:6.0
import PackageDescription

// SwiftPM 包 —— 仅用于在 Linux 沙箱编译并跑通「平台无关的 Domain 层」测试。
// SwiftData/@Model 持久化属于 Apple 平台专属，归入后续 Data/App 层适配（见 index.md）。
let package = Package(
    name: "PennyJarDomain",
    targets: [
        .target(
            name: "PennyJarDomain",
            path: "Src/Domain"
        ),
        .testTarget(
            name: "PennyJarDomainTests",
            dependencies: ["PennyJarDomain"],
            path: "Tests",
            exclude: [
                "App", "Common", "Features", "Resources",
                "Domain/Persistence"
            ]
        )
    ]
)
