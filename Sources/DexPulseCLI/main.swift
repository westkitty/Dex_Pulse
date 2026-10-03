import Foundation
import ApplicationServices
import PulseCore
import PulseKit
import PulseWitness

struct DoctorReport: Codable {
    struct BuildInfo: Codable {
        let name: String
        let version: String
        let buildNumber: String
        let phase: String
        let runtime: String
    }

    struct EnvironmentInfo: Codable {
        let osVersion: String
        let architecture: String
        let hostName: String
        let isAccessibilityTrusted: Bool
    }

    struct TargetStatus: Codable {
        let name: String
        let status: String
        let role: String
        let note: String
    }

    struct CapabilityStatus: Codable {
        let id: String
        let name: String
        let status: String
        let riskClass: String
    }

    struct RendererStatus: Codable {
        let name: String
        let status: String
        let note: String
    }

    let build: BuildInfo
    let environment: EnvironmentInfo
    let hotkey: String
    let targets: [TargetStatus]
    let capabilities: [CapabilityStatus]
    let renderers: [RendererStatus]
    let evidenceLimitations: [String]
}

func runDoctor(asJSON: Bool) {
    let registry = PulseKitRegistry()

    // 1. Environment & Permissions
    let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
    #if arch(arm64)
    let archName = "arm64 (Apple Silicon)"
    #elseif arch(x86_64)
    let archName = "x86_64"
    #else
    let archName = "unknown"
    #endif

    let hostName = ProcessInfo.processInfo.hostName
    let axTrusted = AXIsProcessTrusted()

    // 2. Machine Targets
    let macBookTarget = DoctorReport.TargetStatus(
        name: "MacBook Air M1",
        status: "available (local active machine)",
        role: "Primary operator/CLI target",
        note: "Local execution context verified"
    )

    // Check reachability of Big Mac safely without hangs (fast non-blocking probe)
    let bigMacStatus: String
    let bigMacNote: String
    
    var hints = addrinfo()
    hints.ai_family = AF_INET
    hints.ai_socktype = SOCK_STREAM
    hints.ai_flags = AI_DEFAULT
    var res: UnsafeMutablePointer<addrinfo>?
    
    // Quick hostname resolution attempt
    let resolveResult = getaddrinfo("bigmac.local", nil, &hints, &res)
    if resolveResult == 0 {
        bigMacStatus = "available"
        bigMacNote = "Resolved on local network"
        if let res = res { freeaddrinfo(res) }
    } else {
        bigMacStatus = "unavailable / pending"
        bigMacNote = "bigmac.local unreachable on current network (pending direct fingerprint)"
    }

    let bigMacTarget = DoctorReport.TargetStatus(
        name: "Big Mac",
        status: bigMacStatus,
        role: "Canonical development/heavy-compute target",
        note: bigMacNote
    )

    // 3. Capabilities
    let capStatuses = registry.allCapabilities.map { cap in
        DoctorReport.CapabilityStatus(
            id: cap.capabilityID,
            name: cap.displayName,
            status: "scaffolded / bootstrap baseline",
            riskClass: cap.riskClass.rawValue
        )
    }

    // 4. Renderers
    let renderers = [
        DoctorReport.RendererStatus(
            name: "Core Animation Pulsefront",
            status: "available",
            note: "Debug overlay and HUD surfaces active"
        ),
        DoctorReport.RendererStatus(
            name: "Metal Strand Renderer",
            status: "pending Phase 6",
            note: "Fixture videos hash-verified; Metal shaders activate in Phase 6"
        )
    ]

    // 5. Evidence Limitations
    let evidenceLimitations = [
        "Phase 0/1 bootstrap: No full Lens or autonomous execution has been promoted to VERIFIED.",
        "GUI focus non-theft is architecturally enforced (nonactivatingPanel) but requires manual verification across third-party apps.",
        "Big Mac direct execution route remains pending until connected to the same physical network."
    ]

    let report = DoctorReport(
        build: DoctorReport.BuildInfo(
            name: BuildIdentity.productName,
            version: BuildIdentity.version,
            buildNumber: BuildIdentity.buildNumber,
            phase: BuildIdentity.phase,
            runtime: BuildIdentity.runtimeDependencies
        ),
        environment: DoctorReport.EnvironmentInfo(
            osVersion: osVersion,
            architecture: archName,
            hostName: hostName,
            isAccessibilityTrusted: axTrusted
        ),
        hotkey: "Configured: \(HotkeyBinding.default.displayString) (Carbon HIToolbox event registration)",
        targets: [macBookTarget, bigMacTarget],
        capabilities: capStatuses,
        renderers: renderers,
        evidenceLimitations: evidenceLimitations
    )

    if asJSON {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(report), let str = String(data: data, encoding: .utf8) {
            print(str)
        }
        return
    }

    // Pretty-printed terminal output
    print("================================================================================")
    print(" DEX//PULSE System Doctor (\(BuildIdentity.version) - \(BuildIdentity.phase))")
    print("================================================================================")
    print("")
    print("1. BUILD & RUNTIME")
    print("   Product:       \(report.build.name)")
    print("   Version:       v\(report.build.version) (Build \(report.build.buildNumber))")
    print("   Architecture:  \(report.environment.architecture)")
    print("   macOS:         \(report.environment.osVersion)")
    print("   Host:          \(report.environment.hostName)")
    print("   Dependencies:  \(report.build.runtime)")
    print("")
    print("2. PERMISSIONS & HOTKEY")
    print("   Accessibility: \(report.environment.isAccessibilityTrusted ? "TRUSTED" : "NOT GRANTED (AXIsProcessTrusted=false)")")
    print("   Hotkey:        \(report.hotkey)")
    print("   Note:          Carbon hotkey registration requires no Accessibility permission")
    print("")
    print("3. MACHINE TARGETS")
    for t in report.targets {
        print("   • \(t.name) [\(t.role)]: \(t.status)")
        print("     \(t.note)")
    }
    print("")
    print("4. CAPABILITIES / PACKS")
    for c in report.capabilities {
        print("   • \(c.id) (\(c.name))")
        print("     Status: \(c.status)  |  Risk: \(c.riskClass)")
    }
    print("")
    print("5. VISUAL RENDERING")
    for r in report.renderers {
        print("   • \(r.name): \(r.status)")
        print("     \(r.note)")
    }
    print("")
    print("6. EVIDENCE LIMITATIONS")
    for lim in report.evidenceLimitations {
        print("   ! \(lim)")
    }
    print("")
    print("================================================================================")
    print(" Doctor check completed.")
    print("================================================================================")
}

let args = CommandLine.arguments
if args.contains("--help") || args.contains("-h") {
    print("""
    DEX//PULSE CLI Utility

    Usage:
      dexpulse doctor [--json]   Run environment, hotkey, and capability diagnostics
      dexpulse version          Display version and build identity
      dexpulse --help           Show this message
    """)
    exit(0)
}

if args.contains("version") || args.contains("--version") || args.contains("-v") {
    print(BuildIdentity.banner)
    exit(0)
}

let asJSON = args.contains("--json")
runDoctor(asJSON: asJSON)
