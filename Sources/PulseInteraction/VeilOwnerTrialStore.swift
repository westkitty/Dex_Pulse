import Foundation
import PulseCore

/// Explicit owner evaluation feedback for a real Veil trial.
public enum VeilOwnerFeedback: String, Sendable, Codable, CaseIterable, CustomStringConvertible {
    case unreviewed           = "unreviewed"
    case good                 = "good"
    case misfire              = "misfire"
    case wrongDirection       = "wrong-direction"
    case missingDesiredReflex = "missing-reflex"
    case needsMoreUse         = "needs-more-use"

    public var description: String { rawValue }

    public init?(cliString: String) {
        let normalized = cliString.lowercased().replacingOccurrences(of: "_", with: "-")
        switch normalized {
        case "good":
            self = .good
        case "misfire":
            self = .misfire
        case "wrong-direction", "wrongdirection":
            self = .wrongDirection
        case "missing-reflex", "missingreflex", "missing-desired-reflex", "missingdesiredreflex":
            self = .missingDesiredReflex
        case "needs-more-use", "needsmoreuse":
            self = .needsMoreUse
        case "unreviewed":
            self = .unreviewed
        default:
            return nil
        }
    }
}

/// Strictly privacy-safe, content-free telemetry record of a REAL human owner interaction trial.
///
/// STRICT CONTENT-FREE PRIVACY GUARANTEE:
/// This record type is structurally distinct from synthetic simulation records.
/// It contains ONLY operational, temporal, and categorical metadata:
/// - NO text strings, selected content, or clipboard bytes.
/// - NO filenames, paths, URLs, or window titles.
/// - NO accessibility element names, roles, or hierarchy snapshots.
/// - NO execution result payloads or terminal output.
public struct VeilOwnerTrialRecord: Sendable, Codable, Equatable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let objectClass: ObjectClass
    public let layoutFamily: VeilLayoutFamily
    public let layoutVersion: String
    public let inputRoute: VeilInputRoute
    public let initialArmedDirection: CompassDirection?
    public let finalSelectedDirection: CompassDirection?
    public let selectedReflexID: String?
    public let seamCrossingCount: Int
    public let maxRadialOvershootPt: Double
    public let elapsedSelectionMs: Double
    public let wasCancelled: Bool
    public let didEnterNested: Bool
    public var feedback: VeilOwnerFeedback

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        objectClass: ObjectClass,
        layoutFamily: VeilLayoutFamily,
        layoutVersion: String,
        inputRoute: VeilInputRoute,
        initialArmedDirection: CompassDirection? = nil,
        finalSelectedDirection: CompassDirection? = nil,
        selectedReflexID: String? = nil,
        seamCrossingCount: Int = 0,
        maxRadialOvershootPt: Double = 0.0,
        elapsedSelectionMs: Double = 0.0,
        wasCancelled: Bool = false,
        didEnterNested: Bool = false,
        feedback: VeilOwnerFeedback = .unreviewed
    ) {
        self.id = id
        self.timestamp = timestamp
        self.objectClass = objectClass
        self.layoutFamily = layoutFamily
        self.layoutVersion = layoutVersion
        self.inputRoute = inputRoute
        self.initialArmedDirection = initialArmedDirection
        self.finalSelectedDirection = finalSelectedDirection
        self.selectedReflexID = selectedReflexID
        self.seamCrossingCount = seamCrossingCount
        self.maxRadialOvershootPt = maxRadialOvershootPt
        self.elapsedSelectionMs = elapsedSelectionMs
        self.wasCancelled = wasCancelled
        self.didEnterNested = didEnterNested
        self.feedback = feedback
    }
}

/// Per-class aggregated metrics computed exclusively from REAL owner trials.
public struct VeilOwnerClassAggregate: Sendable, Codable, Equatable {
    public let objectClass: ObjectClass
    public let lifecycle: VeilLayoutLifecycle
    public let layoutVersion: String
    public let totalRealInvocations: Int
    public let completedSelections: Int
    public let cancellations: Int
    public let pointerInvocations: Int
    public let keyboardInvocations: Int
    public let meanLatencyMs: Double
    public let medianLatencyMs: Double
    public let totalSeamCrossings: Int
    public let avgSeamCrossings: Double
    public let maxRadialOvershootPt: Double
    public let directionDistribution: [CompassDirection: Int]
    public let reflexDistribution: [String: Int]
    public let feedbackBreakdown: [VeilOwnerFeedback: Int]
    public let meetsInvocationThreshold: Bool
    public let remainingGaps: [String]

    public init(
        objectClass: ObjectClass,
        lifecycle: VeilLayoutLifecycle,
        layoutVersion: String,
        totalRealInvocations: Int,
        completedSelections: Int,
        cancellations: Int,
        pointerInvocations: Int,
        keyboardInvocations: Int,
        meanLatencyMs: Double,
        medianLatencyMs: Double,
        totalSeamCrossings: Int,
        avgSeamCrossings: Double,
        maxRadialOvershootPt: Double,
        directionDistribution: [CompassDirection: Int],
        reflexDistribution: [String: Int],
        feedbackBreakdown: [VeilOwnerFeedback: Int],
        meetsInvocationThreshold: Bool,
        remainingGaps: [String]
    ) {
        self.objectClass = objectClass
        self.lifecycle = lifecycle
        self.layoutVersion = layoutVersion
        self.totalRealInvocations = totalRealInvocations
        self.completedSelections = completedSelections
        self.cancellations = cancellations
        self.pointerInvocations = pointerInvocations
        self.keyboardInvocations = keyboardInvocations
        self.meanLatencyMs = meanLatencyMs
        self.medianLatencyMs = medianLatencyMs
        self.totalSeamCrossings = totalSeamCrossings
        self.avgSeamCrossings = avgSeamCrossings
        self.maxRadialOvershootPt = maxRadialOvershootPt
        self.directionDistribution = directionDistribution
        self.reflexDistribution = reflexDistribution
        self.feedbackBreakdown = feedbackBreakdown
        self.meetsInvocationThreshold = meetsInvocationThreshold
        self.remainingGaps = remainingGaps
    }
}

/// Persistent store payload for Phase 5 development evidence.
public struct VeilOwnerTrialStoreData: Sendable, Codable, Equatable {
    public var schemaVersion: Int
    public var isTrialModeEnabled: Bool
    public var lastUpdated: Date
    public var records: [VeilOwnerTrialRecord]

    public init(
        schemaVersion: Int = 1,
        isTrialModeEnabled: Bool = false,
        lastUpdated: Date = Date(),
        records: [VeilOwnerTrialRecord] = []
    ) {
        self.schemaVersion = schemaVersion
        self.isTrialModeEnabled = isTrialModeEnabled
        self.lastUpdated = lastUpdated
        self.records = records
    }
}

/// Local development evidence store for Phase 5 real owner trials.
///
/// SCOPE & LIFECYCLE INVARIANTS:
/// 1. Trial mode is OFF by default. No trials are recorded while disabled.
/// 2. Records are stored locally in Application Support (outside the Git repository).
/// 3. NOT committed to Git and NOT part of the Phase 10 habit ledger.
/// 4. Provides per-class aggregates, never combining synthetic trials into real counts.
/// 5. Gracefully recovers from missing or corrupted store files without crashing.
public final class VeilOwnerTrialStore: @unchecked Sendable {
    public static let shared = VeilOwnerTrialStore()

    public static var defaultStoreDirectory: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("DEX_PULSE/owner-trials", isDirectory: true)
    }

    public static var defaultStoreURL: URL {
        defaultStoreDirectory.appendingPathComponent("phase05-owner-trials.json")
    }

    public let fileURL: URL
    private let lock = NSLock()
    private var data: VeilOwnerTrialStoreData

    public init(fileURL: URL = defaultStoreURL) {
        self.fileURL = fileURL
        self.data = VeilOwnerTrialStore.loadData(from: fileURL)
    }

    /// Whether Phase 5 Owner Trial Mode is currently enabled.
    public var isTrialModeEnabled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return data.isTrialModeEnabled
    }

    /// Enables or disables Phase 5 Owner Trial Mode and persists configuration.
    public func setTrialModeEnabled(_ enabled: Bool) {
        lock.lock()
        data.isTrialModeEnabled = enabled
        data.lastUpdated = Date()
        saveLocked()
        lock.unlock()
    }

    /// Current count of real owner invocations.
    public var totalRealInvocations: Int {
        lock.lock()
        defer { lock.unlock() }
        return data.records.count
    }

    /// All real owner trial records.
    public var allRecords: [VeilOwnerTrialRecord] {
        lock.lock()
        defer { lock.unlock() }
        return data.records
    }

    /// Real owner records for a specific object class.
    public func records(for objectClass: ObjectClass) -> [VeilOwnerTrialRecord] {
        lock.lock()
        defer { lock.unlock() }
        return data.records.filter { $0.objectClass == objectClass }
    }

    /// Records a real owner trial if trial mode is active.
    ///
    /// If trial mode is OFF, this operation is a strict NO-OP (zero records recorded, zero disk I/O).
    @discardableResult
    public func recordTrial(_ record: VeilOwnerTrialRecord) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard data.isTrialModeEnabled else {
            return false
        }
        data.records.append(record)
        data.lastUpdated = Date()
        saveLocked()
        return true
    }

    /// Updates the owner feedback evaluation on the most recently recorded trial.
    @discardableResult
    public func markLastFeedback(_ feedback: VeilOwnerFeedback) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard !data.records.isEmpty else {
            return false
        }
        let lastIndex = data.records.count - 1
        data.records[lastIndex].feedback = feedback
        data.lastUpdated = Date()
        saveLocked()
        return true
    }

    /// Clears only Phase 5 local trial evidence.
    ///
    /// Preserves trial mode enabled/disabled state; does not alter Witness, Spool,
    /// application preferences, or repository state.
    public func reset() {
        lock.lock()
        data.records.removeAll()
        data.lastUpdated = Date()
        saveLocked()
        lock.unlock()
    }

    /// Reloads store state from disk safely.
    public func reloadFromDisk() {
        lock.lock()
        data = VeilOwnerTrialStore.loadData(from: fileURL)
        lock.unlock()
    }

    /// Computes aggregated metrics for an object class exclusively from real owner records.
    public func aggregateMetrics(for objectClass: ObjectClass) -> VeilOwnerClassAggregate {
        lock.lock()
        let matching = data.records.filter { $0.objectClass == objectClass }
        lock.unlock()

        let registry = VeilLayoutRegistry.shared
        let layout = registry.layout(for: objectClass)

        let total = matching.count
        let completed = matching.filter { !$0.wasCancelled }.count
        let cancelled = matching.filter { $0.wasCancelled }.count
        let pointerCount = matching.filter { $0.inputRoute == .pointer }.count
        let keyboardCount = matching.filter { $0.inputRoute == .keyboard }.count

        let latencies = matching.map(\.elapsedSelectionMs).sorted()
        let meanLat = total > 0 ? (latencies.reduce(0.0, +) / Double(total)) : 0.0
        let medianLat: Double
        if total == 0 {
            medianLat = 0.0
        } else if total % 2 == 1 {
            medianLat = latencies[total / 2]
        } else {
            medianLat = (latencies[total / 2 - 1] + latencies[total / 2]) / 2.0
        }

        let totalSeams = matching.map(\.seamCrossingCount).reduce(0, +)
        let avgSeams = total > 0 ? (Double(totalSeams) / Double(total)) : 0.0
        let maxOvershoot = matching.map(\.maxRadialOvershootPt).max() ?? 0.0

        var dirDist: [CompassDirection: Int] = [:]
        for dir in matching.compactMap(\.finalSelectedDirection) {
            dirDist[dir, default: 0] += 1
        }

        var refDist: [String: Int] = [:]
        for rId in matching.compactMap(\.selectedReflexID) {
            refDist[rId, default: 0] += 1
        }

        var feedbackBreakdown: [VeilOwnerFeedback: Int] = [:]
        for fb in VeilOwnerFeedback.allCases {
            feedbackBreakdown[fb] = 0
        }
        for rec in matching {
            feedbackBreakdown[rec.feedback, default: 0] += 1
        }

        let meetsThreshold = total >= 20

        var gaps: [String] = []
        if total < 20 {
            gaps.append("Needs \(20 - total) more real owner invocations")
        }
        if layout.isExperimental {
            gaps.append("Owner family/directional decision required (.experimental)")
        }
        let misfireCount = (feedbackBreakdown[.misfire] ?? 0) + (feedbackBreakdown[.wrongDirection] ?? 0)
        if misfireCount > 0 {
            gaps.append("Owner noted \(misfireCount) misfire(s)")
        }
        if let missing = feedbackBreakdown[.missingDesiredReflex], missing > 0 {
            gaps.append("Owner noted \(missing) missing desired Reflex action(s)")
        }
        if gaps.isEmpty {
            gaps.append("Ready for freeze review")
        }

        return VeilOwnerClassAggregate(
            objectClass: objectClass,
            lifecycle: layout.lifecycle,
            layoutVersion: layout.version,
            totalRealInvocations: total,
            completedSelections: completed,
            cancellations: cancelled,
            pointerInvocations: pointerCount,
            keyboardInvocations: keyboardCount,
            meanLatencyMs: (meanLat * 10).rounded() / 10,
            medianLatencyMs: (medianLat * 10).rounded() / 10,
            totalSeamCrossings: totalSeams,
            avgSeamCrossings: (avgSeams * 100).rounded() / 100,
            maxRadialOvershootPt: (maxOvershoot * 10).rounded() / 10,
            directionDistribution: dirDist,
            reflexDistribution: refDist,
            feedbackBreakdown: feedbackBreakdown,
            meetsInvocationThreshold: meetsThreshold,
            remainingGaps: gaps
        )
    }

    /// Computes aggregated metrics across all 18 V1 object classes.
    public func aggregateMetricsForAll() -> [VeilOwnerClassAggregate] {
        ObjectClass.allCases.map { aggregateMetrics(for: $0) }
    }

    /// Formats a human-readable table of all real owner evidence.
    public func summaryReport() -> String {
        let aggregates = aggregateMetricsForAll()
        let modeStr = isTrialModeEnabled ? "ACTIVE" : "INACTIVE"
        var lines: [String] = []
        lines.append("================================================================================")
        lines.append(" DEX//PULSE Phase 5 Real Owner Trial Evidence Summary")
        lines.append("================================================================================")
        lines.append(" Trial Mode:      \(modeStr)")
        lines.append(" Store Location:  \(fileURL.path)")
        lines.append(" Real Records:    \(totalRealInvocations) (Synthetic trials excluded: 350)")
        lines.append(" Threshold Rule:  At least 20 real invocations or deliberate review per class")
        lines.append("================================================================================")
        lines.append(String(
            format: "%-16@ %-14@ %-18@ %-6@ %-12@ %-8@ %-10@ %-8@ %-8@ %@",
            "ObjectClass", "Lifecycle", "Version", "Invoc", "Feedback(G/M)", "Route", "Avg Lat(ms)", "Seams", "MaxOS(pt)", "Status"
        ))
        lines.append(String(repeating: "-", count: 110))

        for agg in aggregates {
            let goodCount = agg.feedbackBreakdown[.good] ?? 0
            let misCount = (agg.feedbackBreakdown[.misfire] ?? 0) + (agg.feedbackBreakdown[.wrongDirection] ?? 0)
            let fbStr = "\(goodCount)G/\(misCount)M"
            let routeStr = "\(agg.pointerInvocations)P/\(agg.keyboardInvocations)K"
            let status = agg.remainingGaps.first ?? "Unknown"

            lines.append(String(
                format: "%-16@ %-14@ %-18@ %-6d %-12@ %-8@ %-10.1f %-8.2f %-8.1f %@",
                agg.objectClass.rawValue,
                agg.lifecycle.rawValue,
                agg.layoutVersion,
                agg.totalRealInvocations,
                fbStr,
                routeStr,
                agg.meanLatencyMs,
                agg.avgSeamCrossings,
                agg.maxRadialOvershootPt,
                status
            ))
        }
        lines.append("================================================================================")
        return lines.joined(separator: "\n")
    }

    /// Formats store evidence as JSON.
    public func summaryJSON() -> String {
        let aggregates = aggregateMetricsForAll()
        struct JSONSummary: Codable {
            let isTrialModeEnabled: Bool
            let storePath: String
            let totalRealInvocations: Int
            let aggregates: [VeilOwnerClassAggregate]
        }
        let summary = JSONSummary(
            isTrialModeEnabled: isTrialModeEnabled,
            storePath: fileURL.path,
            totalRealInvocations: totalRealInvocations,
            aggregates: aggregates
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(summary), let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "{}"
    }

    // MARK: - Internal Storage Engine

    private func saveLocked() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let dir = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let encoded = try encoder.encode(data)
            try encoded.write(to: fileURL, options: .atomic)
        } catch {
            fputs("[VeilOwnerTrialStore] Warning: failed to save trials to \(fileURL.path): \(error)\n", stderr)
        }
    }

    private static func loadData(from url: URL) -> VeilOwnerTrialStoreData {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return VeilOwnerTrialStoreData()
        }
        do {
            let raw = try Data(contentsOf: url)
            guard !raw.isEmpty else {
                return VeilOwnerTrialStoreData()
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(VeilOwnerTrialStoreData.self, from: raw)
        } catch {
            fputs("[VeilOwnerTrialStore] Warning: failed to decode \(url.path) (\(error)). Starting with clean state.\n", stderr)
            return VeilOwnerTrialStoreData()
        }
    }
}
