import Foundation
import PulseCore

/// Input route used during a Veil layout interaction trial.
public enum VeilInputRoute: String, Sendable, Codable, Equatable, CustomStringConvertible {
    case pointer  = "pointer"
    case keyboard = "keyboard"

    public var description: String { rawValue }
}

/// Bitfield flags tracking boundary challenges or simulated navigation discrepancies.
///
/// NON-BINDING MECHANICAL DIAGNOSTIC:
/// These flags track synthetic simulation events (e.g. boundary seam crossings, radial overshoot).
/// They are NOT real-world human motor misfires.
public struct VeilMisfireFlags: OptionSet, Sendable, Codable, Equatable, Hashable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// Synthetic cursor crossed into a neighboring sector during jitter/challenge test.
    public static let wrongSector        = VeilMisfireFlags(rawValue: 1 << 0)

    /// Sector was armed, disarmed into neutral center or neighboring sector, and re-armed.
    public static let reArm              = VeilMisfireFlags(rawValue: 1 << 1)

    /// Pointer trajectory traversed an excessive distance (> 2.5x nominal sector distance).
    public static let excessiveTraversal = VeilMisfireFlags(rawValue: 1 << 2)

    /// Trial was aborted before clean selection (e.g. cancelled or exited boundary).
    public static let abort              = VeilMisfireFlags(rawValue: 1 << 3)

    public var isClean: Bool { rawValue == 0 }

    public var summary: String {
        if isClean { return "clean" }
        var parts: [String] = []
        if contains(.wrongSector) { parts.append("simulated-wrong-sector") }
        if contains(.reArm) { parts.append("re-arm") }
        if contains(.excessiveTraversal) { parts.append("excessive-traversal") }
        if contains(.abort) { parts.append("abort") }
        return parts.joined(separator: "|")
    }
}

/// Privacy-safe, content-free telemetry record of a single layout interaction trial.
///
/// STRICT PRIVACY GUARANTEE:
/// This structure strictly records geometric, temporal, and categorical metadata.
/// It NEVER stores selected text strings, URLs, file paths, UI element accessibility names,
/// window titles, AX hierarchies, or clipboard payloads.
public struct VeilLayoutTrialRecord: Sendable, Codable, Equatable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let objectClass: ObjectClass
    public let layoutVersion: String
    public let sectorChosen: CompassDirection?
    public let intendedDirection: CompassDirection?
    public let distanceTraveledPt: Double
    public let seamCrossings: Int
    public let radialOvershootPt: Double
    public let latencyMs: Double
    public let inputRoute: VeilInputRoute
    public let misfires: VeilMisfireFlags

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        objectClass: ObjectClass,
        layoutVersion: String,
        sectorChosen: CompassDirection?,
        intendedDirection: CompassDirection? = nil,
        distanceTraveledPt: Double,
        seamCrossings: Int,
        radialOvershootPt: Double = 0.0,
        latencyMs: Double,
        inputRoute: VeilInputRoute,
        misfires: VeilMisfireFlags = []
    ) {
        self.id = id
        self.timestamp = timestamp
        self.objectClass = objectClass
        self.layoutVersion = layoutVersion
        self.sectorChosen = sectorChosen
        self.intendedDirection = intendedDirection
        self.distanceTraveledPt = distanceTraveledPt
        self.seamCrossings = seamCrossings
        self.radialOvershootPt = radialOvershootPt
        self.latencyMs = latencyMs
        self.inputRoute = inputRoute
        self.misfires = misfires
    }

    /// Whether this trial completed cleanly without any recorded challenge flags.
    public var isClean: Bool {
        misfires.isClean && (intendedDirection == nil || sectorChosen == intendedDirection)
    }
}

/// Aggregated synthetic metrics for an object class layout across mechanical trials.
///
/// NON-BINDING MECHANICAL DIAGNOSTIC:
/// Aggregates reflect synthetic geometry reachability and tracker math.
/// They do NOT satisfy product freeze criteria (which require real owner invocations).
public struct VeilLayoutTrialAggregate: Sendable, Codable, Equatable {
    public let objectClass: ObjectClass
    public let layoutVersion: String
    public let totalSyntheticTrials: Int
    public let cleanSelections: Int
    public let simulatedWrongSectorCount: Int
    public let simulatedWrongSectorRate: Double
    public let avgDistancePt: Double
    public let avgSeamCrossings: Double
    public let avgRadialOvershootPt: Double
    public let avgLatencyMs: Double
    public let pointerTrials: Int
    public let keyboardTrials: Int
    public let coveredDirections: [CompassDirection]

    // Backward-compatibility properties
    public var totalTrials: Int { totalSyntheticTrials }
    public var successfulSelections: Int { cleanSelections }
    public var misfireCount: Int { simulatedWrongSectorCount }
    public var misfireRate: Double { simulatedWrongSectorRate }

    /// Diagnostic baseline reachability check (synthetic diagnostics only).
    public var hasMechanicalBaselineCoverage: Bool {
        totalSyntheticTrials >= 6 && coveredDirections.count >= 4
    }

    public var isCandidateReady: Bool { hasMechanicalBaselineCoverage }
}

/// In-memory, privacy-safe trial recorder ledger for Phase 5 Object Layout Freeze trials.
///
/// STRICT SEPARATION:
/// Synthetic trials and real owner invocations are tracked through completely distinct counters.
/// Synthetic trial count NEVER satisfies real owner invocation requirements.
public final class VeilLayoutTrialLedger: @unchecked Sendable {
    public static let shared = VeilLayoutTrialLedger()

    private let lock = NSLock()
    private var records: [VeilLayoutTrialRecord] = []
    private var _realOwnerInvocations: Int = 0

    public init() {}

    /// Records a single synthetic mechanical trial.
    public func recordTrial(_ record: VeilLayoutTrialRecord) {
        lock.lock()
        defer { lock.unlock() }
        records.append(record)
    }

    /// Records a real owner invocation.
    public func recordRealOwnerInvocation() {
        lock.lock()
        defer { lock.unlock() }
        _realOwnerInvocations += 1
    }

    /// Current count of real owner invocations recorded.
    public var realOwnerInvocationCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _realOwnerInvocations
    }

    /// Current count of synthetic mechanical trials recorded.
    public var syntheticTrialCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return records.count
    }

    /// Returns all trial records.
    public var allRecords: [VeilLayoutTrialRecord] {
        lock.lock()
        defer { lock.unlock() }
        return records
    }

    /// Returns records for a specific object class.
    public func records(for objectClass: ObjectClass) -> [VeilLayoutTrialRecord] {
        lock.lock()
        defer { lock.unlock() }
        return records.filter { $0.objectClass == objectClass }
    }

    /// Clears all recorded trial history.
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        records.removeAll()
        _realOwnerInvocations = 0
    }

    /// Computes aggregated metrics for an object class layout.
    public func aggregateMetrics(for objectClass: ObjectClass) -> VeilLayoutTrialAggregate {
        lock.lock()
        let matching = records.filter { $0.objectClass == objectClass }
        lock.unlock()

        guard !matching.isEmpty else {
            let layout = VeilLayoutRegistry.shared.layout(for: objectClass)
            return VeilLayoutTrialAggregate(
                objectClass: objectClass,
                layoutVersion: layout.version,
                totalSyntheticTrials: 0,
                cleanSelections: 0,
                simulatedWrongSectorCount: 0,
                simulatedWrongSectorRate: 0.0,
                avgDistancePt: 0.0,
                avgSeamCrossings: 0.0,
                avgRadialOvershootPt: 0.0,
                avgLatencyMs: 0.0,
                pointerTrials: 0,
                keyboardTrials: 0,
                coveredDirections: []
            )
        }

        let total = matching.count
        let successes = matching.filter { $0.isClean }.count
        let misfires = total - successes
        let misfireRate = Double(misfires) / Double(total)
        let avgDist = matching.map(\.distanceTraveledPt).reduce(0.0, +) / Double(total)
        let avgSeams = Double(matching.map(\.seamCrossings).reduce(0, +)) / Double(total)
        let avgOvershoot = matching.map(\.radialOvershootPt).reduce(0.0, +) / Double(total)
        let avgLatency = matching.map(\.latencyMs).reduce(0.0, +) / Double(total)
        let pointerCount = matching.filter { $0.inputRoute == .pointer }.count
        let keyboardCount = matching.filter { $0.inputRoute == .keyboard }.count
        let covered = Array(Set(matching.compactMap(\.sectorChosen))).sorted { $0.nominalAngleDegrees < $1.nominalAngleDegrees }
        let version = matching.last?.layoutVersion ?? "1.0.0-candidate"

        return VeilLayoutTrialAggregate(
            objectClass: objectClass,
            layoutVersion: version,
            totalSyntheticTrials: total,
            cleanSelections: successes,
            simulatedWrongSectorCount: misfires,
            simulatedWrongSectorRate: misfireRate,
            avgDistancePt: (avgDist * 10).rounded() / 10,
            avgSeamCrossings: (avgSeams * 100).rounded() / 100,
            avgRadialOvershootPt: (avgOvershoot * 10).rounded() / 10,
            avgLatencyMs: (avgLatency * 10).rounded() / 10,
            pointerTrials: pointerCount,
            keyboardTrials: keyboardCount,
            coveredDirections: covered
        )
    }

    /// Computes aggregated metrics across all registered object classes.
    public func aggregateMetricsForAll() -> [VeilLayoutTrialAggregate] {
        ObjectClass.allCases.map { aggregateMetrics(for: $0) }
    }

    /// Generates a human-readable diagnostic summary table.
    public func summaryReport() -> String {
        let aggregates = aggregateMetricsForAll()
        var lines: [String] = []
        lines.append("=== DEX//PULSE Phase 5 Synthetic Mechanical Diagnostics Report ===")
        lines.append("NOTE: Non-binding diagnostics. Real owner invocations recorded: \(_realOwnerInvocations)")
        lines.append(String(format: "%-16@ %-18@ %-8@ %-8@ %-12@ %-12@ %-8@", "ObjectClass", "Version", "Trials", "Clean", "Challenge%", "AvgDist(pt)", "Seams"))
        lines.append(String(repeating: "-", count: 90))

        for agg in aggregates {
            let misfirePct = String(format: "%.1f%%", agg.simulatedWrongSectorRate * 100.0)
            lines.append(String(
                format: "%-16@ %-18@ %-8d %-8d %-12@ %-12.1f %-8.2f",
                agg.objectClass.rawValue,
                agg.layoutVersion,
                agg.totalSyntheticTrials,
                agg.cleanSelections,
                misfirePct,
                agg.avgDistancePt,
                agg.avgSeamCrossings
            ))
        }
        return lines.joined(separator: "\n")
    }
}
