// swift-tools-version: 5.9
import PackageDescription
import Foundation

var testSwiftSettings: [SwiftSetting] = []
var testLinkerSettings: [LinkerSetting] = []

let cltFrameworks = "/Library/Developer/CommandLineTools/Library/Developer/Frameworks"
let cltUsrLib = "/Library/Developer/CommandLineTools/Library/Developer/usr/lib"
let devDir: String = {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/xcode-select")
    task.arguments = ["-p"]
    let pipe = Pipe()
    task.standardOutput = pipe
    try? task.run()
    task.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
}()

if devDir == "/Library/Developer/CommandLineTools" && FileManager.default.fileExists(atPath: cltFrameworks) {
    testSwiftSettings.append(.unsafeFlags(["-F", cltFrameworks]))
    testLinkerSettings.append(.unsafeFlags([
        "-Xlinker", "-F", "-Xlinker", cltFrameworks,
        "-Xlinker", "-framework", "-Xlinker", "Testing",
        "-Xlinker", "-rpath", "-Xlinker", cltFrameworks,
        "-Xlinker", "-rpath", "-Xlinker", cltUsrLib
    ]))
}

let package = Package(
    name: "DexPulse",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "PulseCore", targets: ["PulseCore"]),
        .library(name: "PulseWitness", targets: ["PulseWitness"]),
        .library(name: "PulseKit", targets: ["PulseKit"]),
        .library(name: "PulseLens", targets: ["PulseLens"]),
        .library(name: "PulseVisuals", targets: ["PulseVisuals"]),
        .library(name: "PulseInteraction", targets: ["PulseInteraction"]),
        .executable(name: "DexPulseApp", targets: ["DexPulseApp"]),
        .executable(name: "dexpulse", targets: ["DexPulseCLI"]),
        .executable(name: "PulseVerification", targets: ["PulseVerification"]),
        .executable(name: "PulseLensFixtureApp", targets: ["PulseLensFixtureApp"])
    ],
    dependencies: [],
    targets: [
        // Core domain models, state machine, configuration, and types
        .target(
            name: "PulseCore",
            dependencies: [],
            path: "Sources/PulseCore"
        ),
        
        // Structured evidence, proof vocabulary, and execution receipts
        .target(
            name: "PulseWitness",
            dependencies: ["PulseCore"],
            path: "Sources/PulseWitness"
        ),
        
        // Capability registry, risk classification, and policy engine
        .target(
            name: "PulseKit",
            dependencies: ["PulseCore", "PulseWitness"],
            path: "Sources/PulseKit"
        ),
        
        // Context acquisition structural seams and precedence hierarchy
        .target(
            name: "PulseLens",
            dependencies: ["PulseCore"],
            path: "Sources/PulseLens"
        ),
        
        // Visual theme tokens, Core Animation surfaces, and Metal shader seams
        .target(
            name: "PulseVisuals",
            dependencies: ["PulseCore"],
            path: "Sources/PulseVisuals",
            exclude: ["Shaders/README.md"]
        ),
        
        // Transient overlay window, Carbon global hotkey, and input coordination
        .target(
            name: "PulseInteraction",
            dependencies: ["PulseCore", "PulseLens", "PulseVisuals"],
            path: "Sources/PulseInteraction"
        ),
        
        // Native AppKit application shell and menu-bar utility
        .executableTarget(
            name: "DexPulseApp",
            dependencies: [
                "PulseCore",
                "PulseWitness",
                "PulseKit",
                "PulseLens",
                "PulseVisuals",
                "PulseInteraction"
            ],
            path: "Sources/DexPulseApp"
        ),
        
        // Operator CLI and diagnostic doctor tool (`dexpulse`)
        .executableTarget(
            name: "DexPulseCLI",
            dependencies: [
                "PulseCore",
                "PulseWitness",
                "PulseKit",
                "PulseLens",
                "PulseInteraction"
            ],
            path: "Sources/DexPulseCLI"
        ),
        
        // Deterministic headless verification runner
        .executableTarget(
            name: "PulseVerification",
            dependencies: [
                "PulseCore",
                "PulseWitness",
                "PulseKit",
                "PulseLens",
                "PulseVisuals",
                "PulseInteraction"
            ],
            path: "Sources/PulseVerification"
        ),
        
        // Synthetic Accessibility test fixture application
        .executableTarget(
            name: "PulseLensFixtureApp",
            dependencies: [
                "PulseCore",
                "PulseLens"
            ],
            path: "Sources/PulseLensFixtureApp"
        ),

        // Test targets
        .testTarget(
            name: "PulseCoreTests",
            dependencies: ["PulseCore", "PulseWitness"],
            path: "Tests/PulseCoreTests",
            swiftSettings: testSwiftSettings,
            linkerSettings: testLinkerSettings
        ),
        .testTarget(
            name: "PulseLensTests",
            dependencies: ["PulseLens", "PulseCore"],
            path: "Tests/PulseLensTests",
            swiftSettings: testSwiftSettings,
            linkerSettings: testLinkerSettings
        ),
        .testTarget(
            name: "PulseKitTests",
            dependencies: ["PulseKit", "PulseCore", "PulseWitness"],
            path: "Tests/PulseKitTests",
            swiftSettings: testSwiftSettings,
            linkerSettings: testLinkerSettings
        ),
        .testTarget(
            name: "PulseVerificationTests",
            dependencies: [
                "PulseCore",
                "PulseWitness",
                "PulseKit",
                "PulseLens",
                "PulseVisuals"
            ],
            path: "Tests/PulseVerificationTests",
            swiftSettings: testSwiftSettings,
            linkerSettings: testLinkerSettings
        ),
        .testTarget(
            name: "PulseInteractionTests",
            dependencies: [
                "PulseInteraction",
                "PulseCore",
                "PulseLens",
                "PulseVisuals"
            ],
            path: "Tests/PulseInteractionTests",
            swiftSettings: testSwiftSettings,
            linkerSettings: testLinkerSettings
        )
    ]
)
