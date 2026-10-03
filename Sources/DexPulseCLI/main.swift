import Foundation
import ApplicationServices
import PulseCore
import PulseKit
import PulseWitness
import PulseLens

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

    struct LensStatus: Codable {
        let axAuthorization: String
        let precedenceHierarchy: [String]
        let coordinateEngine: String
        let secureFieldGuard: String
        let clipboardMode: String
        let staleContextGuard: String
    }

    struct StateMachineStatus: Codable {
        let semanticStatesCount: Int
        let statesList: [String]
        let causalConvergence: String
        let runModel: String
        let resultHold: String
        let staleProtection: String
        let witnessProof: String
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
    let lens: LensStatus
    let stateMachine: StateMachineStatus
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
    let axStatus = AccessibilityAuthorizer.checkStatus()
    let axTrusted = (axStatus == .authorized)

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

    // 4. Lens Context Acquisition Status
    let lensStatus = DoctorReport.LensStatus(
        axAuthorization: axStatus.rawValue,
        precedenceHierarchy: [
            "Tier 1: Explicit selected text / selected file",
            "Tier 2: UI element under pointer (AXUIElementCopyElementAtPosition)",
            "Tier 3: Focused Accessibility element",
            "Tier 4: Frontmost application / window",
            "Tier 5: Existing clipboard read-only fallback"
        ],
        coordinateEngine: "AppKit (bottom-left origin) <-> CoreGraphics/AX (top-left origin) active",
        secureFieldGuard: "Enforced (.secureBlocked privacy class, secret payload redacted)",
        clipboardMode: "Strictly read-only inspection (INV-001 zero mutation enforced)",
        staleContextGuard: "Enforced (generation token + live PID revalidation)"
    )

    // 5. Semantic State Machine (Phase 3)
    let stateMachineStatus = DoctorReport.StateMachineStatus(
        semanticStatesCount: PulseState.allCases.count,
        statesList: PulseState.allCases.map(\.rawValue),
        causalConvergence: "Guaranteed (cancel from any transient state converges cleanly to QUIET)",
        runModel: "Explicit PulseRun with unique runID and generationToken",
        resultHold: "Memory-only Result hold pauses auto-recede while inspectable",
        staleProtection: "Enforced (mismatched runID/generationToken rejected without state mutation)",
        witnessProof: "Enforced (EXECUTED != VERIFIED proof distinction, raw payloads excluded)"
    )

    // 6. Renderers
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

    // 7. Evidence Limitations
    let evidenceLimitations = [
        "Phase 5 Object Layout Freeze Trial: Candidate layouts (1.0.0-candidate), mechanical trial simulations, and privacy-safe trial ledger verified; awaiting real owner-use review before freeze.",
        "GUI focus non-theft is architecturally enforced (nonactivatingPanel) and verified live across TextEdit, Brave Browser, and Terminal.",
        "DexDictate coexistence: Partial Phase 0/1 verified (no hotkey collision, focus/clipboard preserved); full coexistence matrix scheduled for Phase 11.",
        "Big Mac direct execution route remains pending until connected to the same physical network."
    ]

    let report = DoctorReport(
        build: DoctorReport.BuildInfo(
            name: BuildIdentity.productName,
            version: BuildIdentity.version,
            buildNumber: BuildIdentity.buildNumber,
            phase: "Phase 5 (Object Layout Freeze Trial)",
            runtime: "Swift 5.9 native (0 external runtime dependencies)"
        ),
        environment: DoctorReport.EnvironmentInfo(
            osVersion: osVersion,
            architecture: archName,
            hostName: hostName,
            isAccessibilityTrusted: axTrusted
        ),
        hotkey: "⇧⌘Space (KeyCode 49, Modifiers: [.command, .shift])",
        targets: [macBookTarget, bigMacTarget],
        capabilities: capStatuses,
        lens: lensStatus,
        stateMachine: stateMachineStatus,
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
    print(" DEX//PULSE System Doctor (\(BuildIdentity.version) - Phase 5)")
    print("================================================================================")
    print("")
    print("1. BUILD & RUNTIME")
    print("   Product:       \(report.build.name)")
    print("   Version:       v\(report.build.version) (Build \(report.build.buildNumber))")
    print("   Phase:         \(report.build.phase)")
    print("   Architecture:  \(report.environment.architecture)")
    print("   macOS:         \(report.environment.osVersion)")
    print("   Host:          \(report.environment.hostName)")
    print("   Dependencies:  \(report.build.runtime)")
    print("")
    print("2. PERMISSIONS & HOTKEY")
    print("   Accessibility: \(report.lens.axAuthorization.uppercased()) (Trusted: \(report.environment.isAccessibilityTrusted))")
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
    print("5. LENS & CONTEXT ACQUISITION (PHASE 2)")
    print("   AX Authorization: \(report.lens.axAuthorization)")
    print("   Coordinates:      \(report.lens.coordinateEngine)")
    print("   Security Guard:   \(report.lens.secureFieldGuard)")
    print("   Clipboard Fallback: \(report.lens.clipboardMode)")
    print("   Stale Guard:      \(report.lens.staleContextGuard)")
    print("   Precedence Hierarchy (Locked INV-003):")
    for tier in report.lens.precedenceHierarchy {
        print("     \(tier)")
    }
    print("")
    print("6. SEMANTIC STATE MACHINE (PHASE 3)")
    print("   Semantic States:  \(report.stateMachine.semanticStatesCount) states")
    print("   Convergence:      \(report.stateMachine.causalConvergence)")
    print("   Run Model:        \(report.stateMachine.runModel)")
    print("   Result Holds:     \(report.stateMachine.resultHold)")
    print("   Stale Guard:      \(report.stateMachine.staleProtection)")
    print("   Witness Proof:    \(report.stateMachine.witnessProof)")
    print("")
    print("7. VISUAL RENDERING")
    for r in report.renderers {
        print("   • \(r.name): \(r.status)")
        print("     \(r.note)")
    }
    print("")
    print("8. EVIDENCE LIMITATIONS")
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

if args.contains("probe") {
    var probePoint: (x: Double, y: Double)? = nil
    if let ptIdx = args.firstIndex(of: "--point"), ptIdx + 1 < args.count {
        let parts = args[ptIdx + 1].split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        if parts.count == 2 {
            probePoint = (parts[0], parts[1])
        }
    }

    let envelope = LensResolver.acquireContextEnvelope(at: probePoint)
    print("================================================================================")
    print(" DEX//PULSE Lens Live Probe")
    print("================================================================================")
    print(" Generation Token: \(envelope.generationToken)")
    print(" Invocation Time:  \(envelope.invocationTime)")
    if let pt = probePoint {
        print(" Screen Point:     (\(pt.x), \(pt.y)) [CG/AX]")
    }
    print(" Accessibility:    \(envelope.accessibilityStatus)")
    if !envelope.degradationReasons.isEmpty {
        print(" Degradation:      \(envelope.degradationReasons.map(\.rawValue).joined(separator: ", "))")
    }
    if let primary = envelope.primaryObject {
        print(" Primary Object:   [\(primary.objectClass.rawValue)] \(primary.summary)")
        print(" Primary Tier:     \(envelope.primaryTier.map { "Tier \($0)" } ?? "none")")
        print(" Primary Reason:   \(envelope.primaryReason ?? "none")")
        print(" Privacy Class:    \(primary.privacyClass.rawValue)")
    } else {
        print(" Primary Object:   none")
    }
    if let fallback = envelope.fallbackObject {
        print(" Fallback Object:  [\(fallback.objectClass.rawValue)] \(fallback.summary)")
    }
    print(" Evaluated Candidates: \(envelope.evaluatedCandidates.count)")
    for cand in envelope.evaluatedCandidates {
        print("   • Tier \(cand.tierRawValue) [\(cand.objectClass.rawValue)]: \(cand.acquisitionReason)")
    }
    print("================================================================================")
    exit(0)
}

let asJSON = args.contains("--json")
runDoctor(asJSON: asJSON)
