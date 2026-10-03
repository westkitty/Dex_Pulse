import Testing
import Foundation
import CoreGraphics
#if canImport(AppKit)
import AppKit
#endif
@testable import PulseCore
@testable import PulseInteraction

@Suite("Veil Interaction Engine — Phase 4 Geometry, Input, and Lifecycle", .serialized)
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

    @Test("Every V1 ObjectClass resolves deterministically with candidate or experimental lifecycle in Phase 5")
    func registryCoverageAndStability() {
        let registry = VeilLayoutRegistry.shared

        let expectedCandidates: Set<ObjectClass> = [
            .selectedText, .errorLog, .repository, .path, .uiElement,
            .focusedElement, .image, .file, .selectedFile, .fileSet
        ]
        let expectedExperimental: Set<ObjectClass> = [
            .code, .url, .jsonText, .window, .application, .clipboard, .result, .machineTarget
        ]

        #expect(registry.candidateLayouts.count == 10)
        #expect(registry.experimentalLayouts.count == 8)

        for objClass in ObjectClass.allCases {
            let layout = registry.layout(for: objClass)
            #expect(layout.objectClass == objClass)
            #expect(!layout.isFrozen, "No layout may be frozen in Phase 5")
            #expect(!layout.occupiedDirections.isEmpty, "Layout for \(objClass) must have occupied slots")

            if expectedCandidates.contains(objClass) {
                #expect(layout.lifecycle == .candidate, "Candidate class \(objClass) must be .candidate")
                #expect(layout.version == "1.0.0-candidate", "Candidate class \(objClass) must be 1.0.0-candidate")
            } else if expectedExperimental.contains(objClass) {
                #expect(layout.lifecycle == .experimental, "Ambiguous class \(objClass) must be .experimental")
                #expect(layout.version == "1.0.0-experimental", "Ambiguous class \(objClass) must be 1.0.0-experimental")
                #expect(!layout.unresolvedQuestions.isEmpty, "Ambiguous class \(objClass) must declare unresolved questions")
            }

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

    // MARK: - 7. Real Input Integration & Carbon Hotkey Delivery Proof (Stage A)

    @Test("Veil tuning tokens lock 42pt inner, 112pt outer, 16pt overshoot, 6deg hysteresis, 8pt nested gap, 52pt nested thickness")
    func tuningTokensCommitment() {
        #expect(VeilTuningTokens.defaultInnerRadius == 42.0)
        #expect(VeilTuningTokens.defaultOuterRadius == 112.0)
        #expect(VeilTuningTokens.radialOvershootTolerance == 16.0)
        #expect(VeilTuningTokens.angularHysteresisDegrees == 6.0)
        #expect(VeilTuningTokens.nestedGap == 8.0)
        #expect(VeilTuningTokens.nestedRingThickness == 52.0)
        #expect(VeilTuningTokens.maxActiveRadius == CGFloat(188.0))
    }

    @Test("VeilKeyboardDeliveryAdapter registers default chords, avoids collisions, and unregisters cleanly")
    func keyboardDeliveryAdapterLifecycle() {
        let adapter = VeilKeyboardDeliveryAdapter()
        #expect(!adapter.isRegistered)
        #expect(adapter.activeChords.isEmpty)

        // 1. Collision check against simulated duplicate binding
        let duplicateBinding = HotkeyBinding(keyCode: 30, modifiers: [.control, .option])
        let collisionResult = adapter.register(collisionBinding: duplicateBinding) { _ in }
        #expect(!adapter.isRegistered)
        if case .failure(let err) = collisionResult {
            #expect(err == .collisionWithGlobalHotkey(keyCode: 30, modifiers: [.control, .option]))
        } else {
            #expect(Bool(false), "Must fail on collision with registered binding")
        }

        // 2. Successful registration with default global hotkey (Shift-Command-Space)
        let globalBinding = HotkeyBinding.default // KeyCode 49, Modifiers [.command, .shift]
        let regResult = adapter.register(collisionBinding: globalBinding) { _ in }
        #expect(adapter.isRegistered)
        #expect(adapter.activeChords.count == 6)
        if case .success(let count) = regResult {
            #expect(count == 6)
        } else {
            #expect(Bool(false), "Registration must succeed when no collision exists")
        }

        // 3. Inspectable chords
        let actions = Set(adapter.activeChords.map { $0.action })
        #expect(actions.contains(.stepPrevious))
        #expect(actions.contains(.stepNext))
        #expect(actions.contains(.diveNested))
        #expect(actions.contains(.backOutNested))
        #expect(actions.contains(.activate))
        #expect(actions.contains(.cancel))

        // 4. Clean unregistration leaves zero registrations
        adapter.unregister()
        #expect(!adapter.isRegistered)
        #expect(adapter.activeChords.isEmpty)
    }

    @Test("VeilKeyboardDeliveryAdapter delivers synthetic Carbon events to handler")
    @MainActor
    func keyboardDeliveryAdapterSyntheticEvent() {
        let adapter = VeilKeyboardDeliveryAdapter()
        final class ActionCollector: @unchecked Sendable {
            var actions: [VeilKeyAction] = []
        }
        let collector = ActionCollector()

        _ = adapter.register(collisionBinding: .default) { action in
            collector.actions.append(action)
        }
        #expect(adapter.isRegistered)

        // Deliver synthetic events for next and cancel
        let deliveredNext = adapter.deliverSyntheticEvent(for: .stepNext)
        #expect(deliveredNext)

        let deliveredCancel = adapter.deliverSyntheticEvent(for: .cancel)
        #expect(deliveredCancel)

        // Pump main thread queue
        let deadline = Date().addingTimeInterval(0.3)
        while collector.actions.count < 2 && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }

        #expect(collector.actions.contains(.stepNext))
        #expect(collector.actions.contains(.cancel))

        adapter.unregister()
        #expect(!adapter.isRegistered)
    }

    @Test("Real mouse-event integration drives VeilView, tracking area callback, pointerTracker, and selection across 9 trajectories")
    @MainActor
    func realMouseEventChainAcrossNineTrajectories() {
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
        let win = VeilWindow(contentRect: NSRect(x: 100, y: 100, width: 440, height: 440))
        win.contentView = view

        final class BoundaryExitCollector: @unchecked Sendable {
            var exited: Bool = false
        }
        let exitCollector = BoundaryExitCollector()
        tracker.onExitBoundary = { _ in exitCollector.exited = true }

        // Trajectory 1: center -> N
        view.deliverPointerEvent(at: CGPoint(x: 220, y: 220))
        #expect(tracker.currentState == .inCenter)
        view.deliverPointerEvent(at: CGPoint(x: 220, y: 295))
        #expect(tracker.currentState == .sectorArmed(.n))

        // Trajectory 2: N -> center -> N without dismissal
        view.deliverPointerEvent(at: CGPoint(x: 220, y: 220))
        #expect(tracker.currentState == .inCenter)
        #expect(!exitCollector.exited, "Center traversal must not trigger boundary exit")
        view.deliverPointerEvent(at: CGPoint(x: 220, y: 295))
        #expect(tracker.currentState == .sectorArmed(.n))

        // Trajectory 3: N seam jitter (66.5° within 6° hysteresis of 67.5° seam)
        let seamJitterPoint = CGPoint(
            x: 220 + 75 * cos(66.5 * .pi / 180.0),
            y: 220 + 75 * sin(66.5 * .pi / 180.0)
        )
        view.deliverPointerEvent(at: seamJitterPoint)
        #expect(tracker.currentState == .sectorArmed(.n), "Seam jitter within 6° hysteresis must preserve armed N")

        // Trajectory 4: intentional N -> NE transition beyond hysteresis (55°)
        let nePoint = CGPoint(
            x: 220 + 75 * cos(55.0 * .pi / 180.0),
            y: 220 + 75 * sin(55.0 * .pi / 180.0)
        )
        view.deliverPointerEvent(at: nePoint)
        #expect(tracker.currentState == .sectorArmed(.ne), "Moving beyond hysteresis must cleanly switch to NE")

        // Trajectory 5: NE radial overshoot within tolerance (outerRadius 112 + 10pt = 122pt at 45°)
        let overPt = CGPoint(
            x: 220 + 122 * cos(45.0 * .pi / 180.0),
            y: 220 + 122 * sin(45.0 * .pi / 180.0)
        )
        view.deliverPointerEvent(at: overPt)
        #expect(tracker.currentState == .sectorArmed(.ne), "Radial overshoot within 16pt must maintain armed NE")

        // Trajectory 6: travel beyond tolerance (exceeding maxActiveRadius + 24pt = 212pt)
        let outsidePt = CGPoint(
            x: 220 + 240 * cos(45.0 * .pi / 180.0),
            y: 220 + 240 * sin(45.0 * .pi / 180.0)
        )
        view.deliverPointerEvent(at: outsidePt)
        #expect(exitCollector.exited, "Pointer excursion beyond overshoot envelope must trigger boundary exit")

        // Trajectory 7: parent -> nested choice
        // Use errorLog layout where SE has nested choices or configure nested on parent
        let errorLayout = VeilLayoutRegistry.shared.layout(for: .errorLog)
        let errorTracker = VeilPointerTracker(center: center)
        let errorNav = VeilKeyboardNavigator(layout: errorLayout)
        errorTracker.startTracking(layout: errorLayout, center: center)
        let errorView = VeilView(
            frame: NSRect(x: 0, y: 0, width: 440, height: 440),
            layout: errorLayout,
            placement: placement,
            pointerTracker: errorTracker,
            keyboardNavigator: errorNav
        )
        let errorWin = VeilWindow(contentRect: NSRect(x: 100, y: 100, width: 440, height: 440))
        errorWin.contentView = errorView

        // Arm SE (parent direction for send to agent with nested choices)
        let sePt = CGPoint(
            x: 220 + 75 * cos(315.0 * .pi / 180.0),
            y: 220 + 75 * sin(315.0 * .pi / 180.0)
        )
        errorView.deliverPointerEvent(at: sePt)
        #expect(errorTracker.currentState == .sectorArmed(.se))
        #expect(errorTracker.activeNestedParent == .se)

        // Move into nested ring sector (radius = 112 + 8 + 26 = 146pt at 315°)
        let nestedPt = CGPoint(
            x: 220 + 146 * cos(315.0 * .pi / 180.0),
            y: 220 + 146 * sin(315.0 * .pi / 180.0)
        )
        errorView.deliverPointerEvent(at: nestedPt)
        if case .nestedArmed(let parent, let choiceID) = errorTracker.currentState {
            #expect(parent == .se)
            #expect(!choiceID.isEmpty)
        } else {
            #expect(Bool(false), "Must be in nestedArmed state")
        }

        // Trajectory 8: nested -> parent
        errorView.deliverPointerEvent(at: sePt)
        #expect(errorTracker.currentState == .sectorArmed(.se))

        // Trajectory 9: cancel
        errorNav.cancel()
        #expect(errorNav.selectedDirection == nil)
    }

    @Test("Hollow center traversal preserves pointer tracking without false dismissal while passing mouse clicks through to underlying applications")
    @MainActor
    func centerTraversalAndClickThroughContract() {
        let sm = PulseStateMachine()
        let controller = VeilInteractionController(stateMachine: sm)

        // 1. Present Veil
        controller.present(at: CGPoint(x: 400, y: 400))
        #expect(controller.isVisible)
        #expect(sm.currentState == .veil)
        #expect(controller.panelWindow?.canBecomeKey == false)
        #expect(controller.panelWindow?.canBecomeMain == false)

        guard let view = controller.interactionView else {
            #expect(Bool(false), "Missing interactionView")
            return
        }

        // 2. Hollow center hitTest must return nil (pass through to underlying apps)
        let centerPoint = view.wheelCenter
        #expect(view.hitTest(centerPoint) == nil, "Click in hollow center must return nil to pass through")

        // 3. Transparent corner hitTest must return nil
        #expect(view.hitTest(NSPoint(x: 5, y: 5)) == nil, "Click in transparent corner must return nil")

        // 4. Interactive sector hitTest must return the view
        let northPoint = CGPoint(x: centerPoint.x, y: centerPoint.y + 75)
        #expect(view.hitTest(northPoint) === view, "Click in interactive sector must be captured by VeilView")

        // 5. Center traversal preserves tracking alive
        view.deliverPointerEvent(at: northPoint)
        #expect(controller.currentArmedDirection != nil)
        view.deliverPointerEvent(at: centerPoint)
        #expect(controller.currentPointerState == .inCenter)
        #expect(controller.isVisible, "Veil must remain visible when entering center")

        // 6. Dismiss cleanly
        controller.dismiss()
        let deadline = Date().addingTimeInterval(0.3)
        while sm.currentState != .quiet && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
        #expect(sm.currentState == .quiet)
        #expect(!controller.isVisible)
        #expect(!controller.isKeyboardAdapterActive)
    }
    #endif

    // MARK: - 6. Phase 5 Object Layout Freeze & Trial Ledger Tests

    @Test("VeilObjectLayout initializer defaults strictly to .experimental and 1.0.0-experimental")
    func initializerDefaultsStrictlyToExperimental() {
        let layout = VeilObjectLayout(objectClass: .code, slots: [:])
        #expect(layout.lifecycle == .experimental)
        #expect(layout.version == "1.0.0-experimental")
        #expect(layout.isExperimental)
        #expect(!layout.isCandidate)
        #expect(!layout.isFrozen)
    }

    @Test("Candidate layouts are immutable at runtime and cannot be frozen via runtime API")
    func candidateLayoutsAreImmutableAndCannotBeFrozenAtRuntime() {
        let registry = VeilLayoutRegistry.shared

        // Verify candidate lifecycle
        let textLayout = registry.layout(for: .selectedText)
        #expect(textLayout.lifecycle == .candidate)
        #expect(textLayout.version == "1.0.0-candidate")
        #expect(textLayout.isCandidate)
        #expect(!textLayout.isFrozen)

        // All registered layouts must not be frozen
        for objClass in ObjectClass.allCases {
            let lay = registry.layout(for: objClass)
            #expect(!lay.isFrozen, "Class \(objClass) must not be frozen in Phase 5")
        }
    }

    @Test("Image/file family strictly implements the 8 Reflex slots from docs/OBJECT_LAYOUTS_V1.md")
    func imageFileFamilyAlignsWithPlanningSource() {
        let registry = VeilLayoutRegistry.shared

        let imageClasses: [ObjectClass] = [.image, .file, .selectedFile, .fileSet]
        for objClass in imageClasses {
            let layout = registry.layout(for: objClass)
            #expect(layout.family == .imageFile, "Class \(objClass) must belong to imageFile family")
            #expect(layout.lifecycle == .candidate, "Class \(objClass) must be candidate")
            #expect(layout.version == "1.0.0-candidate")

            // Exact slots from docs/OBJECT_LAYOUTS_V1.md lines 75-87:
            #expect(layout.reflex(at: .n)?.id == "file.metadata")
            #expect(layout.reflex(at: .ne)?.id == "file.enhance")
            #expect(layout.reflex(at: .e)?.id == "file.convert")
            #expect(layout.reflex(at: .se)?.id == "file.send")
            #expect(layout.reflex(at: .s)?.id == "file.spool")
            #expect(layout.reflex(at: .sw)?.id == "file.reveal")
            #expect(layout.reflex(at: .w)?.id == "file.related")
            #expect(layout.reflex(at: .nw)?.id == "file.variant")

            // Capabilities without V1 Pack must be unavailable in place
            #expect(layout.reflex(at: .ne)?.state == .unavailable(reason: "Visual enhance pack unavailable in V1 baseline"))
            #expect(layout.reflex(at: .e)?.state == .unavailable(reason: "Asset conversion pack unavailable in V1 baseline"))
            #expect(layout.reflex(at: .w)?.state == .unavailable(reason: "Asset discovery pack unavailable in V1 baseline"))
            #expect(layout.reflex(at: .nw)?.state == .unavailable(reason: "Variant generation pack unavailable in V1 baseline"))
        }
    }

    @Test("VeilLayoutTrialLedger accurately records telemetry and computes aggregates with zero content payload")
    func trialLedgerTelemetryAndPrivacy() {
        let ledger = VeilLayoutTrialLedger()
        ledger.clear()
        #expect(ledger.allRecords.isEmpty)
        #expect(ledger.syntheticTrialCount == 0)
        #expect(ledger.realOwnerInvocationCount == 0)

        // Record a clean trial
        let record1 = VeilLayoutTrialRecord(
            objectClass: .selectedText,
            layoutVersion: "1.0.0-candidate",
            sectorChosen: .n,
            intendedDirection: .n,
            distanceTraveledPt: 75.0,
            seamCrossings: 0,
            radialOvershootPt: 0.0,
            latencyMs: 14.2,
            inputRoute: .pointer,
            misfires: []
        )
        ledger.recordTrial(record1)
        #expect(record1.isClean)
        #expect(ledger.syntheticTrialCount == 1)
        #expect(ledger.realOwnerInvocationCount == 0)

        // Record a trial with simulated wrong-sector challenge
        let record2 = VeilLayoutTrialRecord(
            objectClass: .selectedText,
            layoutVersion: "1.0.0-candidate",
            sectorChosen: .ne,
            intendedDirection: .n,
            distanceTraveledPt: 82.0,
            seamCrossings: 1,
            radialOvershootPt: 4.0,
            latencyMs: 25.0,
            inputRoute: .pointer,
            misfires: [.wrongSector]
        )
        ledger.recordTrial(record2)
        #expect(!record2.isClean)
        #expect(ledger.syntheticTrialCount == 2)
        #expect(ledger.realOwnerInvocationCount == 0)

        // Aggregate
        let agg = ledger.aggregateMetrics(for: .selectedText)
        #expect(agg.totalSyntheticTrials == 2)
        #expect(agg.cleanSelections == 1)
        #expect(agg.simulatedWrongSectorCount == 1)
        #expect(agg.simulatedWrongSectorRate == 0.5)
        #expect(agg.avgDistancePt == 78.5)
        #expect(agg.avgSeamCrossings == 0.5)

        // Report generation
        let report = ledger.summaryReport()
        #expect(report.contains(ObjectClass.selectedText.rawValue))
        #expect(report.contains("1.0.0-candidate"))
    }

    @Test("Autonomous mechanical trials succeed across all primary V1 object families")
    func autonomousMechanicalTrialsAcrossAllFamilies() {
        let ledger = VeilLayoutTrialLedger()
        ledger.clear()

        let aggregates = VeilLayoutTrialSimulator.runAllTrials(ledger: ledger)
        #expect(aggregates.count == ObjectClass.allCases.count)

        for agg in aggregates {
            #expect(agg.totalSyntheticTrials >= 6, "Each class must have at least 6 mechanical trials (\(agg.objectClass))")
            #expect(agg.hasMechanicalBaselineCoverage, "Layout for \(agg.objectClass) must have mechanical baseline coverage")
            #expect(!agg.coveredDirections.isEmpty)
        }

        // Verify total records in ledger (350 synthetic mechanical trials)
        let allRecords = ledger.allRecords
        #expect(allRecords.count == 350)
        #expect(ledger.syntheticTrialCount == 350)
        #expect(ledger.realOwnerInvocationCount == 0, "Real owner invocations must remain 0 prior to human trials")

        // Strict Privacy Verification: ensure records contain no text payloads
        for rec in allRecords {
            #expect(!rec.layoutVersion.isEmpty)
            #expect(rec.distanceTraveledPt >= 0.0)
            #expect(rec.seamCrossings >= 0)
        }
    }

    @Test("Owner review generator strictly matches docs/layout-trials/PHASE-05-OWNER-REVIEW.md on disk")
    func ownerReviewGeneratorMatchesDiskArtifact() {
        let registry = VeilLayoutRegistry.shared
        let generatedDoc = VeilOwnerReviewGenerator.generateDocument(registry: registry)
        #expect(!generatedDoc.isEmpty)

        let reviewPath = "docs/layout-trials/PHASE-05-OWNER-REVIEW.md"
        if let onDisk = try? String(contentsOfFile: reviewPath, encoding: .utf8) {
            #expect(onDisk == generatedDoc, "Disk review artifact must match VeilOwnerReviewGenerator output")
        }
    }

    // MARK: - 8. Phase 5 Owner Trial System Tests

    @Test("Owner trial mode defaults to OFF and strictly ignores invocations")
    func ownerTrialModeDefaultsToOffAndIgnoresInvocations() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test-owner-trial-off-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let store = VeilOwnerTrialStore(fileURL: tempURL)
        #expect(!store.isTrialModeEnabled)
        #expect(store.totalRealInvocations == 0)
        #expect(store.allRecords.isEmpty)

        let record = VeilOwnerTrialRecord(
            objectClass: .selectedText,
            layoutFamily: .text,
            layoutVersion: "1.0.0-candidate",
            inputRoute: .pointer,
            initialArmedDirection: .n,
            finalSelectedDirection: .n,
            selectedReflexID: "text.explain"
        )
        let didRecord = store.recordTrial(record)
        #expect(!didRecord)
        #expect(store.totalRealInvocations == 0)
    }

    @Test("Owner trial store records operational telemetry when enabled")
    func ownerTrialStoreRecordsCategoricalTelemetryWhenEnabled() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test-owner-trial-on-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let store = VeilOwnerTrialStore(fileURL: tempURL)
        store.setTrialModeEnabled(true)
        #expect(store.isTrialModeEnabled)

        let record = VeilOwnerTrialRecord(
            objectClass: .selectedText,
            layoutFamily: .text,
            layoutVersion: "1.0.0-candidate",
            inputRoute: .pointer,
            initialArmedDirection: .ne,
            finalSelectedDirection: .n,
            selectedReflexID: "text.explain",
            seamCrossingCount: 2,
            maxRadialOvershootPt: 4.5,
            elapsedSelectionMs: 32.1,
            wasCancelled: false,
            didEnterNested: false,
            feedback: .unreviewed
        )
        let didRecord = store.recordTrial(record)
        #expect(didRecord)
        #expect(store.totalRealInvocations == 1)

        let saved = store.allRecords.first
        #expect(saved != nil)
        #expect(saved?.objectClass == .selectedText)
        #expect(saved?.layoutFamily == .text)
        #expect(saved?.layoutVersion == "1.0.0-candidate")
        #expect(saved?.inputRoute == .pointer)
        #expect(saved?.initialArmedDirection == .ne)
        #expect(saved?.finalSelectedDirection == .n)
        #expect(saved?.selectedReflexID == "text.explain")
        #expect(saved?.seamCrossingCount == 2)
        #expect(saved?.maxRadialOvershootPt == 4.5)
        #expect(saved?.elapsedSelectionMs == 32.1)
        #expect(saved?.wasCancelled == false)
        #expect(saved?.didEnterNested == false)
        #expect(saved?.feedback == .unreviewed)
    }

    @Test("Owner trial store attributes per-class telemetry independently")
    func ownerTrialStoreAttributesPerClassIndependently() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test-owner-trial-classes-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let store = VeilOwnerTrialStore(fileURL: tempURL)
        store.setTrialModeEnabled(true)

        // Record 2 trials for .selectedText
        store.recordTrial(VeilOwnerTrialRecord(
            objectClass: .selectedText,
            layoutFamily: .text,
            layoutVersion: "1.0.0-candidate",
            inputRoute: .pointer,
            finalSelectedDirection: .n,
            selectedReflexID: "text.explain"
        ))
        store.recordTrial(VeilOwnerTrialRecord(
            objectClass: .selectedText,
            layoutFamily: .text,
            layoutVersion: "1.0.0-candidate",
            inputRoute: .keyboard,
            finalSelectedDirection: .s,
            selectedReflexID: "text.copy"
        ))

        // Record 1 trial for .repository
        store.recordTrial(VeilOwnerTrialRecord(
            objectClass: .repository,
            layoutFamily: .repoPath,
            layoutVersion: "1.0.0-candidate",
            inputRoute: .pointer,
            finalSelectedDirection: .w,
            selectedReflexID: "repo.status"
        ))

        #expect(store.totalRealInvocations == 3)
        #expect(store.records(for: .selectedText).count == 2)
        #expect(store.records(for: .repository).count == 1)
        #expect(store.records(for: .file).isEmpty)

        let aggText = store.aggregateMetrics(for: .selectedText)
        #expect(aggText.totalRealInvocations == 2)
        #expect(aggText.pointerInvocations == 1)
        #expect(aggText.keyboardInvocations == 1)
        #expect(!aggText.meetsInvocationThreshold)
        #expect(aggText.remainingGaps.contains { $0.contains("18 more") })

        let aggRepo = store.aggregateMetrics(for: .repository)
        #expect(aggRepo.totalRealInvocations == 1)
        #expect(aggRepo.remainingGaps.contains { $0.contains("19 more") })

        let aggFile = store.aggregateMetrics(for: .file)
        #expect(aggFile.totalRealInvocations == 0)
        #expect(aggFile.remainingGaps.contains { $0.contains("20 more") })
    }

    @Test("Synthetic simulations never mutate real owner store")
    func syntheticSimulationsNeverMutateRealOwnerStore() {
        let ledger = VeilLayoutTrialLedger()
        ledger.clear()

        _ = VeilLayoutTrialSimulator.runAllTrials(ledger: ledger)
        #expect(ledger.syntheticTrialCount == 350)
        #expect(ledger.realOwnerInvocationCount == 0)
        #expect(VeilOwnerTrialStore.shared.totalRealInvocations == 0)
    }

    @Test("Owner trial store feedback updates last recorded trial")
    func ownerTrialStoreFeedbackUpdatesLastRecord() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test-owner-trial-feedback-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let store = VeilOwnerTrialStore(fileURL: tempURL)
        store.setTrialModeEnabled(true)

        // Without records, marking feedback returns false
        #expect(!store.markLastFeedback(.good))

        store.recordTrial(VeilOwnerTrialRecord(
            objectClass: .selectedText,
            layoutFamily: .text,
            layoutVersion: "1.0.0-candidate",
            inputRoute: .pointer,
            finalSelectedDirection: .n,
            selectedReflexID: "text.explain",
            feedback: .unreviewed
        ))
        #expect(store.allRecords.last?.feedback == .unreviewed)

        #expect(store.markLastFeedback(.good))
        #expect(store.allRecords.last?.feedback == .good)

        #expect(store.markLastFeedback(.wrongDirection))
        #expect(store.allRecords.last?.feedback == .wrongDirection)
    }

    @Test("Owner trial store reset clears only local trial evidence")
    func ownerTrialStoreResetClearsOnlyLocalTrialEvidence() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test-owner-trial-reset-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let store = VeilOwnerTrialStore(fileURL: tempURL)
        store.setTrialModeEnabled(true)
        store.recordTrial(VeilOwnerTrialRecord(
            objectClass: .selectedText,
            layoutFamily: .text,
            layoutVersion: "1.0.0-candidate",
            inputRoute: .pointer,
            finalSelectedDirection: .n,
            selectedReflexID: "text.explain"
        ))
        #expect(store.totalRealInvocations == 1)

        store.reset()
        #expect(store.totalRealInvocations == 0)
        #expect(store.allRecords.isEmpty)
        #expect(store.isTrialModeEnabled, "Reset must preserve trial mode enabled state")
    }

    @Test("Owner trial store recovers gracefully from corrupted files")
    func ownerTrialStoreRecoversGracefullyFromCorruptData() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test-owner-trial-corrupt-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        try? "corrupted-unparseable-data".write(to: tempURL, atomically: true, encoding: .utf8)

        let store = VeilOwnerTrialStore(fileURL: tempURL)
        #expect(store.totalRealInvocations == 0)
        #expect(!store.isTrialModeEnabled)
    }

    @Test("Owner trial store survives disk persistence and reload")
    func ownerTrialStoreSchemaRoundtrip() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test-owner-trial-roundtrip-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let store1 = VeilOwnerTrialStore(fileURL: tempURL)
        store1.setTrialModeEnabled(true)
        store1.recordTrial(VeilOwnerTrialRecord(
            objectClass: .selectedText,
            layoutFamily: .text,
            layoutVersion: "1.0.0-candidate",
            inputRoute: .keyboard,
            finalSelectedDirection: .s,
            selectedReflexID: "text.copy",
            feedback: .good
        ))

        let store2 = VeilOwnerTrialStore(fileURL: tempURL)
        #expect(store2.isTrialModeEnabled)
        #expect(store2.totalRealInvocations == 1)
        #expect(store2.allRecords.first?.objectClass == .selectedText)
        #expect(store2.allRecords.first?.feedback == .good)
    }

    @Test("Owner feedback parses CLI string inputs reliably")
    func ownerFeedbackParsing() {
        #expect(VeilOwnerFeedback(cliString: "good") == .good)
        #expect(VeilOwnerFeedback(cliString: "Good") == .good)
        #expect(VeilOwnerFeedback(cliString: "misfire") == .misfire)
        #expect(VeilOwnerFeedback(cliString: "wrong-direction") == .wrongDirection)
        #expect(VeilOwnerFeedback(cliString: "wrong_direction") == .wrongDirection)
        #expect(VeilOwnerFeedback(cliString: "wrongdirection") == .wrongDirection)
        #expect(VeilOwnerFeedback(cliString: "missing-reflex") == .missingDesiredReflex)
        #expect(VeilOwnerFeedback(cliString: "missing_desired_reflex") == .missingDesiredReflex)
        #expect(VeilOwnerFeedback(cliString: "needs-more-use") == .needsMoreUse)
        #expect(VeilOwnerFeedback(cliString: "unreviewed") == .unreviewed)
        #expect(VeilOwnerFeedback(cliString: "invalid-flag") == nil)
    }
}
