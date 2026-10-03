import Testing
import Foundation
import CoreGraphics
#if canImport(AppKit)
import AppKit
#endif
@testable import PulseCore
@testable import PulseInteraction

@Suite("Veil Interaction Engine — Phase 4 Geometry, Input, and Lifecycle")
struct VeilTests {

    // MARK: - 1. Geometry & Annular Model Tests

    @Test("Cardinal and diagonal directions map to correct nominal angles")
    func directionalAngles() {
        #expect(CompassDirection.e.nominalAngleDegrees == 0.0)
        #expect(CompassDirection.ne.nominalAngleDegrees == 45.0)
        #expect(CompassDirection.n.nominalAngleDegrees == 90.0)
        #expect(CompassDirection.nw.nominalAngleDegrees == 135.0)
        #expect(CompassDirection.w.nominalAngleDegrees == 180.0)
        #expect(CompassDirection.sw.nominalAngleDegrees == 225.0)
        #expect(CompassDirection.s.nominalAngleDegrees == 270.0)
        #expect(CompassDirection.se.nominalAngleDegrees == 315.0)

        // Traversal order
        #expect(CompassDirection.n.clockwise == .ne)
        #expect(CompassDirection.ne.clockwise == .e)
        #expect(CompassDirection.n.counterClockwise == .nw)
        #expect(CompassDirection.n.opposite == .s)
        #expect(CompassDirection.e.opposite == .w)
    }

    @Test("Zero-degree wraparound in East sector")
    func eastSectorWraparound() {
        let geom = VeilRingGeometry(center: .zero)
        guard let eastSec = geom.sectors[.e] else {
            #expect(Bool(false), "East sector missing")
            return
        }

        #expect(eastSec.startAngleDegrees == 337.5)
        #expect(eastSec.endAngleDegrees == 22.5)

        // 350° is in East sector
        #expect(eastSec.containsAngle(350.0))
        // 10° is in East sector
        #expect(eastSec.containsAngle(10.0))
        // 45° is outside East sector
        #expect(!eastSec.containsAngle(45.0))

        // Hit testing points
        let midR = (eastSec.innerRadius + eastSec.outerRadius) / 2.0
        let ptAt0Deg = CGPoint(x: midR, y: 0.0)
        let ptAt10Deg = CGPoint(x: midR * cos(10.0 * .pi / 180.0), y: midR * sin(10.0 * .pi / 180.0))
        let ptAt350Deg = CGPoint(x: midR * cos(350.0 * .pi / 180.0), y: midR * sin(350.0 * .pi / 180.0))

        #expect(eastSec.contains(point: ptAt0Deg))
        #expect(eastSec.contains(point: ptAt10Deg))
        #expect(eastSec.contains(point: ptAt350Deg))
    }

    @Test("Inner boundary, outer boundary, and neutral center")
    func boundariesAndNeutralCenter() {
        let geom = VeilRingGeometry(center: .zero)
        let northSec = geom.sectors[.n]!

        let innerR = geom.innerRadius // 42.0
        let outerR = geom.outerRadius // 112.0

        // In center neutral zone
        let centerPt = CGPoint(x: 0, y: 20)
        #expect(geom.isInsideNeutralCenter(centerPt))
        #expect(geom.hitTest(point: centerPt) == .neutralCenter)

        // Exactly on inner radius along North (y = innerR)
        let innerPt = CGPoint(x: 0, y: innerR)
        #expect(northSec.contains(point: innerPt))

        // Midpoint of North sector
        let midPt = CGPoint(x: 0, y: (innerR + outerR) / 2.0)
        #expect(northSec.contains(point: midPt))
        #expect(geom.hitTest(point: midPt) == .sector(.n, isArmed: false))

        // Outside outer radius along North
        let outsidePt = CGPoint(x: 0, y: outerR + 5.0)
        #expect(!northSec.contains(point: outsidePt, isArmed: false))
    }

    @Test("Radial overshoot tolerance envelope")
    func radialOvershootTolerance() {
        let geom = VeilRingGeometry(center: .zero)
        let northSec = geom.sectors[.n]!
        let outerR = geom.outerRadius // 112.0
        let tol = VeilTuningTokens.radialOvershootTolerance // 16.0

        // Point within overshoot envelope (e.g. outerR + 10)
        let overshootPt = CGPoint(x: 0, y: outerR + 10.0)

        // When NOT armed, must be rejected
        #expect(!northSec.contains(point: overshootPt, isArmed: false))
        #expect(geom.hitTest(point: overshootPt, armedDirection: nil) == .outside)

        // When ARMED in .n, must be accepted within overshoot envelope
        #expect(northSec.contains(point: overshootPt, isArmed: true))
        #expect(geom.hitTest(point: overshootPt, armedDirection: .n) == .sector(.n, isArmed: true))

        // Beyond overshoot envelope (e.g. outerR + tol + 5)
        let wayOutsidePt = CGPoint(x: 0, y: outerR + tol + 5.0)
        #expect(!northSec.contains(point: wayOutsidePt, isArmed: true))
        #expect(geom.hitTest(point: wayOutsidePt, armedDirection: .n) == .outside)
    }

    @Test("Angular hysteresis prevents fluttering along sector seams")
    func angularHysteresis() {
        let geom = VeilRingGeometry(center: .zero)
        let midR = (geom.innerRadius + geom.outerRadius) / 2.0

        // Boundary between N (nominal 90°, start 67.5°, end 112.5°) and NE (nominal 45°, start 22.5°, end 67.5°) is at 67.5°
        // A point just slightly inside NE at 66.5° (1.0° clockwise of the seam)
        let rad66_5 = 66.5 * .pi / 180.0
        let ptNearSeamInNE = CGPoint(x: midR * cos(rad66_5), y: midR * sin(rad66_5))

        // Without armed direction, point resolves strictly to NE
        let hitNormal = geom.hitTest(point: ptNearSeamInNE, armedDirection: nil)
        #expect(hitNormal == .sector(.ne, isArmed: false))

        // With N currently armed, hysteresis (6°) expands N's boundary from 67.5° down to 61.5°
        // So 66.5° remains within armed N!
        let hitWithNArmed = geom.hitTest(point: ptNearSeamInNE, armedDirection: .n)
        #expect(hitWithNArmed == .sector(.n, isArmed: true))

        // But moving past hysteresis (e.g. 55°, well past the 6° hysteresis band) transitions to NE
        let rad55 = 55.0 * .pi / 180.0
        let ptFarInNE = CGPoint(x: midR * cos(rad55), y: midR * sin(rad55))
        let hitFar = geom.hitTest(point: ptFarInNE, armedDirection: .n)
        #expect(hitFar == .sector(.ne, isArmed: false))
    }

    @Test("Single Source of Truth: CoreGraphics path strictly matches mathematical hit testing")
    func visiblePathAndHitTestParity() {
        let geom = VeilRingGeometry(center: CGPoint(x: 100, y: 100))
        let midR = (geom.innerRadius + geom.outerRadius) / 2.0

        // Test sample points across every compass sector
        for dir in CompassDirection.allCases {
            let sec = geom.sectors[dir]!

            // 1. Center of sector
            let centerAngleRad = dir.nominalAngleDegrees * .pi / 180.0
            let pCenter = CGPoint(
                x: sec.center.x + midR * cos(centerAngleRad),
                y: sec.center.y + midR * sin(centerAngleRad)
            )
            let parityCenter = sec.verifyParity(point: pCenter)
            #expect(parityCenter.parityMatches, "Parity failed for sector \(dir) center")
            #expect(parityCenter.pathContains, "Path should contain sector \(dir) center")
            #expect(parityCenter.mathContains, "Math should contain sector \(dir) center")

            // 2. Point inside inner neutral circle
            let pInside = CGPoint(x: sec.center.x, y: sec.center.y)
            let parityInside = sec.verifyParity(point: pInside)
            #expect(parityInside.parityMatches, "Parity failed for inside point")
            #expect(!parityInside.pathContains, "Path should not contain center origin")

            // 3. Point far outside
            let pOutside = CGPoint(
                x: sec.center.x + (geom.outerRadius + 80) * cos(centerAngleRad),
                y: sec.center.y + (geom.outerRadius + 80) * sin(centerAngleRad)
            )
            let parityOutside = sec.verifyParity(point: pOutside)
            #expect(parityOutside.parityMatches, "Parity failed for far outside point")
            #expect(!parityOutside.pathContains, "Path should not contain outside point")

            // 4. Opposite sector point
            let oppAngleRad = dir.opposite.nominalAngleDegrees * .pi / 180.0
            let pOpp = CGPoint(
                x: sec.center.x + midR * cos(oppAngleRad),
                y: sec.center.y + midR * sin(oppAngleRad)
            )
            let parityOpp = sec.verifyParity(point: pOpp)
            #expect(parityOpp.parityMatches, "Parity failed for opposite sector point")
            #expect(!parityOpp.pathContains, "Path should not contain opposite sector point")
        }
    }

    // MARK: - 2. Placement Planner Tests

    @Test("Minimal translation clamping along screen edges and corners")
    func placementEdgeClamping() {
        let visibleFrame = CGRect(x: 0, y: 0, width: 1440, height: 900)
        let screenFrame = visibleFrame
        let radius = VeilTuningTokens.maxActiveRadius // 188.0
        let margin: CGFloat = 8.0
        let clearance = radius + margin // 196.0

        // 1. Center of screen: no shift
        let centerOrigin = CGPoint(x: 720, y: 450)
        let pCenter = VeilPlacementPlanner.computePlacement(
            causalOrigin: centerOrigin,
            visibleFrame: visibleFrame,
            screenFrame: screenFrame
        )
        #expect(!pCenter.isShifted)
        #expect(pCenter.veilCenter == centerOrigin)
        #expect(pCenter.causalOrigin == centerOrigin)

        // 2. Left edge clamp
        let leftOrigin = CGPoint(x: 50, y: 450)
        let pLeft = VeilPlacementPlanner.computePlacement(
            causalOrigin: leftOrigin,
            visibleFrame: visibleFrame,
            screenFrame: screenFrame
        )
        #expect(pLeft.isShifted)
        #expect(pLeft.veilCenter.x == clearance)
        #expect(pLeft.veilCenter.y == 450)
        #expect(pLeft.causalOrigin == leftOrigin)

        // 3. Right edge clamp
        let rightOrigin = CGPoint(x: 1400, y: 450)
        let pRight = VeilPlacementPlanner.computePlacement(
            causalOrigin: rightOrigin,
            visibleFrame: visibleFrame,
            screenFrame: screenFrame
        )
        #expect(pRight.isShifted)
        #expect(pRight.veilCenter.x == 1440 - clearance)
        #expect(pRight.causalOrigin == rightOrigin)

        // 4. Bottom-left corner clamp
        let blOrigin = CGPoint(x: 10, y: 10)
        let pBL = VeilPlacementPlanner.computePlacement(
            causalOrigin: blOrigin,
            visibleFrame: visibleFrame,
            screenFrame: screenFrame
        )
        #expect(pBL.isShifted)
        #expect(pBL.veilCenter.x == clearance)
        #expect(pBL.veilCenter.y == clearance)
        #expect(pBL.causalOrigin == blOrigin)

        // 5. Top-right corner clamp
        let trOrigin = CGPoint(x: 1430, y: 890)
        let pTR = VeilPlacementPlanner.computePlacement(
            causalOrigin: trOrigin,
            visibleFrame: visibleFrame,
            screenFrame: screenFrame
        )
        #expect(pTR.isShifted)
        #expect(pTR.veilCenter.x == 1440 - clearance)
        #expect(pTR.veilCenter.y == 900 - clearance)
        #expect(pTR.causalOrigin == trOrigin)
    }

    @Test("Synthetic multi-monitor fixture with negative origin coordinates")
    func multiMonitorNegativeOrigin() {
        // Left monitor positioned at negative X: [-1920, 0, 1920, 1080]
        let leftMonitorVisible = CGRect(x: -1920, y: 0, width: 1920, height: 1080)
        let leftMonitorScreen = leftMonitorVisible
        let radius = VeilTuningTokens.maxActiveRadius
        let clearance = radius + 8.0

        let causalPt = CGPoint(x: -1900, y: 500)
        let placement = VeilPlacementPlanner.computePlacement(
            causalOrigin: causalPt,
            visibleFrame: leftMonitorVisible,
            screenFrame: leftMonitorScreen
        )

        #expect(placement.isShifted)
        #expect(placement.veilCenter.x == -1920 + clearance)
        #expect(placement.veilCenter.y == 500)
        #expect(placement.causalOrigin == causalPt)
    }

    // MARK: - 3. Layout Registry & Invariant Tests

    @Test("Every V1 ObjectClass resolves deterministically with experimental lifecycle")
    func registryCoverageAndStability() {
        let registry = VeilLayoutRegistry.shared

        for objClass in ObjectClass.allCases {
            let layout = registry.layout(for: objClass)
            #expect(layout.objectClass == objClass)
            #expect(layout.lifecycle == .experimental, "Lifecycle must remain experimental in Phase 4 (INV-040)")
            #expect(!layout.occupiedDirections.isEmpty, "Layout for \(objClass) must have occupied slots")

            // Deterministic repeated lookup
            let layout2 = registry.layout(for: objClass)
            #expect(layout.occupiedDirections == layout2.occupiedDirections)
            for dir in layout.occupiedDirections {
                #expect(layout.reflex(at: dir)?.id == layout2.reflex(at: dir)?.id)
                #expect(layout.reflex(at: dir)?.label == layout2.reflex(at: dir)?.label)
            }
        }
    }

    @Test("Unavailable capabilities preserve position and never reflow neighbors")
    func disabledSlotPositionPreservation() {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(id: "action.one", label: "One", direction: .n, state: .enabled)
        slots[.e] = VeilReflexDescriptor(id: "action.two", label: "Two", direction: .e, state: .unavailable(reason: "Tool offline"))
        slots[.s] = VeilReflexDescriptor(id: "action.three", label: "Three", direction: .s, state: .enabled)

        let layout = VeilObjectLayout(objectClass: .code, slots: slots)

        // Slot .e must still be occupied at .e, not removed or reflowed
        #expect(layout.reflex(at: .e) != nil)
        #expect(layout.reflex(at: .e)?.state == .unavailable(reason: "Tool offline"))
        #expect(layout.reflex(at: .s)?.direction == .s)
        #expect(layout.occupiedDirections.count == 3)
    }

    // MARK: - 4. Pointer Tracking & Interaction Path Tests

    @Test("Pointer path: Center -> Sector -> Center without dismissal")
    func pointerPathCenterToSectorToCenter() {
        let tracker = VeilPointerTracker(center: .zero)
        let layout = VeilLayoutRegistry.shared.layout(for: .selectedText)
        tracker.startTracking(layout: layout, center: .zero)

        #expect(tracker.isTracking)
        #expect(tracker.currentState == .inCenter)

        // 1. Move to North sector
        let northPt = CGPoint(x: 0, y: 75)
        let hit1 = tracker.updatePointer(at: northPt)
        #expect(hit1 == .sector(.n, isArmed: false))
        #expect(tracker.armedDirection == .n)
        #expect(tracker.currentState == .sectorArmed(.n))

        // 2. Return to neutral center
        let centerPt = CGPoint(x: 0, y: 10)
        let hit2 = tracker.updatePointer(at: centerPt)
        #expect(hit2 == .neutralCenter)
        // Returning to center leaves tracker alive without dismissing
        #expect(tracker.isTracking)
        #expect(tracker.armedDirection == nil)
        #expect(tracker.currentState == .inCenter)

        // 3. Move back out to East sector
        let eastPt = CGPoint(x: 75, y: 0)
        let hit3 = tracker.updatePointer(at: eastPt)
        #expect(hit3 == .sector(.e, isArmed: false))
        #expect(tracker.armedDirection == .e)

        tracker.stopTracking()
        #expect(!tracker.isTracking)
    }

    @Test("Nested disclosure traversal: Parent -> Nested Choice -> Parent")
    func nestedDisclosureTraversal() {
        let tracker = VeilPointerTracker(center: .zero)
        // ErrorLog layout has nested choices in .se
        let layout = VeilLayoutRegistry.shared.layout(for: .errorLog)
        tracker.startTracking(layout: layout, center: .zero)

        // 1. Arm parent .se sector
        let angle315 = 315.0 * .pi / 180.0
        let parentPt = CGPoint(x: 75 * cos(angle315), y: 75 * sin(angle315))
        let hitParent = tracker.updatePointer(at: parentPt)
        #expect(hitParent == .sector(.se, isArmed: false))
        #expect(tracker.activeNestedParent == .se)
        #expect(!tracker.geometry.nestedSectors.isEmpty)

        // 2. Move outward into nested outer ring (inner radius ~120, outer ~172)
        let nestedPt = CGPoint(x: 140 * cos(angle315), y: 140 * sin(angle315))
        let hitNested = tracker.updatePointer(at: nestedPt)
        if case .nestedSector(let parent, let choiceID) = hitNested {
            #expect(parent == .se)
            #expect(tracker.activeNestedChoiceID == choiceID)
            #expect(tracker.currentState == .nestedArmed(parent: .se, choiceID: choiceID))
        } else {
            #expect(Bool(false), "Expected nestedSector hit result")
        }

        // 3. Move back inward into parent .se sector
        let hitBack = tracker.updatePointer(at: parentPt)
        #expect(hitBack == .sector(.se, isArmed: true))
        #expect(tracker.activeNestedChoiceID == nil)

        tracker.stopTracking()
    }

    // MARK: - 5. Keyboard Navigation Engine Tests

    @Test("Keyboard navigation steps deterministically and reaches all interactive slots")
    func keyboardNavigationTraversal() {
        let layout = VeilLayoutRegistry.shared.layout(for: .selectedText)
        let nav = VeilKeyboardNavigator(layout: layout)

        let interactive = nav.interactiveDirections
        #expect(!interactive.isEmpty)

        // First stepNext selects first slot
        nav.stepNext()
        #expect(nav.selectedDirection == interactive.first)

        // Step through all interactive slots
        var visited: [CompassDirection] = [nav.selectedDirection!]
        for _ in 1..<interactive.count {
            nav.stepNext()
            visited.append(nav.selectedDirection!)
        }
        #expect(visited == interactive)

        // Next wraps back to first
        nav.stepNext()
        #expect(nav.selectedDirection == interactive.first)

        // Step previous wraps to last
        nav.stepPrevious()
        #expect(nav.selectedDirection == interactive.last)
    }

    @Test("Keyboard nested disclosure dive and back-out")
    func keyboardNestedNavigation() {
        let layout = VeilLayoutRegistry.shared.layout(for: .errorLog)
        let nav = VeilKeyboardNavigator(layout: layout)

        // Direct select .se (which has nestedChoices)
        let selectedSE = nav.selectDirection(.se)
        #expect(selectedSE)
        #expect(nav.selectedDirection == .se)
        #expect(!nav.isNestedActive)

        // Dive into nested disclosure
        let dived = nav.diveNested()
        #expect(dived)
        #expect(nav.isNestedActive)
        #expect(nav.selectedNestedChoiceIndex == 0)

        // Step next within nested choices
        nav.stepNext()
        #expect(nav.selectedNestedChoiceIndex == 1)

        // Back out to parent
        let backedOut = nav.backOutNested()
        #expect(backedOut)
        #expect(!nav.isNestedActive)
        #expect(nav.selectedDirection == .se)
    }

    @Test("Escape key cancels cleanly: backs out of nested first, cancels wheel second")
    func keyboardCancelSemantics() {
        let layout = VeilLayoutRegistry.shared.layout(for: .errorLog)
        let nav = VeilKeyboardNavigator(layout: layout)

        _ = nav.selectDirection(.se)
        _ = nav.diveNested()
        #expect(nav.isNestedActive)

        final class Counter: @unchecked Sendable {
            var count = 0
        }
        let counter = Counter()
        nav.onCancelled = { counter.count += 1 }

        // First Escape: backs out of nested
        nav.cancel()
        #expect(!nav.isNestedActive)
        #expect(counter.count == 0, "First escape must not cancel the whole wheel")

        // Second Escape: cancels wheel
        nav.cancel()
        #expect(counter.count == 1, "Second escape must trigger onCancelled")
    }

    // MARK: - 6. Window Hit-Testing & Pass-Through Proof

    #if canImport(AppKit)
    @Test("VeilView hit-test passes through transparent corners and neutral center")
    @MainActor
    func viewHitTestingPassThrough() {
        let layout = VeilLayoutRegistry.shared.layout(for: .selectedText)
        let center = CGPoint(x: 220, y: 220)
        let placement = VeilPlacementResult(
            veilCenter: center,
            causalOrigin: center,
            visibleFrame: CGRect(x: 0, y: 0, width: 1440, height: 900),
            screenFrame: CGRect(x: 0, y: 0, width: 1440, height: 900)
        )
        let tracker = VeilPointerTracker(center: center)
        let nav = VeilKeyboardNavigator(layout: layout)
        tracker.startTracking(layout: layout, center: center)

        let view = VeilView(
            frame: NSRect(x: 0, y: 0, width: 440, height: 440),
            layout: layout,
            placement: placement,
            pointerTracker: tracker,
            keyboardNavigator: nav
        )

        // 1. Transparent corner (e.g. 10, 10) must return nil (pass through)
        let cornerPt = NSPoint(x: 10, y: 10)
        #expect(view.hitTest(cornerPt) == nil, "Transparent corner must pass through clicks")

        // 2. Neutral center hole (e.g. 220, 220) must return nil (pass through)
        let centerPt = NSPoint(x: 220, y: 220)
        #expect(view.hitTest(centerPt) == nil, "Neutral center hole must pass through clicks")

        // 3. Primary sector point (e.g. North sector: x=220, y=295) must return view
        let northPt = NSPoint(x: 220, y: 295)
        #expect(view.hitTest(northPt) === view, "Primary sector must intercept clicks")
    }
    #endif
}
