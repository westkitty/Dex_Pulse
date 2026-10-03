import Foundation
import CoreGraphics
#if canImport(AppKit)
import AppKit
import PulseCore
import PulseVisuals

/// Visual presentation and interaction view for the annular Veil wheel.
///
/// Invariants:
/// - Single source of truth: visible drawn paths are generated directly from
///   `VeilSectorGeometry.cgPath()`, strictly matching hit-test math (INV-032).
/// - Non-stealing hit testing: transparent corners and neutral center return `nil`
///   from `hitTest(_:)`, allowing underlying clicks to pass through (INV-FOCUS).
/// - Reduced-motion support: snaps state transitions immediately without animations.
/// - Debug mode: renders inner/outer radii, radial overshoot envelopes, and sector seams.
public final class VeilView: NSView {
    public let pointerTracker: VeilPointerTracker
    public let keyboardNavigator: VeilKeyboardNavigator
    public private(set) var layout: VeilObjectLayout
    public private(set) var placement: VeilPlacementResult

    public var showDebugGeometry: Bool = false {
        didSet { needsDisplay = true }
    }

    public var isReducedMotion: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    private var trackingArea: NSTrackingArea?

    public init(
        frame frameRect: NSRect,
        layout: VeilObjectLayout,
        placement: VeilPlacementResult,
        pointerTracker: VeilPointerTracker,
        keyboardNavigator: VeilKeyboardNavigator
    ) {
        self.layout = layout
        self.placement = placement
        self.pointerTracker = pointerTracker
        self.keyboardNavigator = keyboardNavigator
        super.init(frame: frameRect)

        self.wantsLayer = true
        self.layer?.backgroundColor = .clear

        setupTracking()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTracking() {
        let options: NSTrackingArea.Options = [
            .mouseMoved,
            .mouseEnteredAndExited,
            .activeAlways,
            .inVisibleRect
        ]
        let area = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(area)
        self.trackingArea = area
    }

    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        setupTracking()
    }

    /// Center of the annular wheel in local view coordinates.
    public var wheelCenter: CGPoint {
        CGPoint(x: bounds.midX, y: bounds.midY)
    }

    // MARK: - Hit Testing Pass-Through

    /// Non-activating click-through evaluation.
    ///
    /// Transparent corners and the hollow neutral center return `nil` so underlying
    /// applications receive clicks without interference (INV-FOCUS).
    public override func hitTest(_ point: NSPoint) -> NSView? {
        let geom = pointerTracker.geometry

        // Convert point to center-relative
        let hitResult = geom.hitTest(
            point: point,
            armedDirection: pointerTracker.armedDirection,
            activeNestedParent: pointerTracker.activeNestedParent
        )

        switch hitResult {
        case .neutralCenter, .outside:
            // Pass through clicks to underlying applications
            return nil
        case .sector, .nestedSector:
            return self
        }
    }

    // MARK: - Mouse Interaction

    public override func mouseMoved(with event: NSEvent) {
        let viewPoint = convert(event.locationInWindow, from: nil)
        _ = pointerTracker.updatePointer(at: viewPoint)
        needsDisplay = true
    }

    public override func mouseDown(with event: NSEvent) {
        let viewPoint = convert(event.locationInWindow, from: nil)
        let result = pointerTracker.updatePointer(at: viewPoint)

        switch result {
        case .sector(let dir, _):
            _ = keyboardNavigator.selectDirection(dir)
            _ = keyboardNavigator.activate()
        case .nestedSector(let parent, let choiceID):
            keyboardNavigator.onActivated?(parent, choiceID)
        case .neutralCenter, .outside:
            break
        }
    }

    // MARK: - Drawing & Parity

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        let center = wheelCenter
        let geom = pointerTracker.geometry
        let armedDir = pointerTracker.armedDirection ?? keyboardNavigator.selectedDirection
        let nestedParent = pointerTracker.activeNestedParent
        let activeNestedChoice = pointerTracker.activeNestedChoiceID

        // 1. Draw Causal Origin Connector if shifted
        if placement.isShifted {
            let causalInView = CGPoint(
                x: center.x - CGFloat(placement.translationOffset.dx),
                y: center.y - CGFloat(placement.translationOffset.dy)
            )
            ctx.saveGState()
            ctx.setStrokeColor(CGColor(red: 0.0, green: 0.89, blue: 1.0, alpha: 0.35))
            ctx.setLineWidth(1.0)
            ctx.setLineDash(phase: 0, lengths: [4, 4])
            ctx.move(to: causalInView)
            ctx.addLine(to: center)
            ctx.strokePath()

            // Small causal origin anchor dot
            ctx.setFillColor(CGColor(red: 0.0, green: 0.89, blue: 1.0, alpha: 0.7))
            ctx.fillEllipse(in: CGRect(x: causalInView.x - 3, y: causalInView.y - 3, width: 6, height: 6))
            ctx.restoreGState()
        }

        // 2. Draw Primary Annular Sectors
        for (dir, sec) in geom.sectors {
            let isSelected = (armedDir == dir)
            let descriptor = layout.reflex(at: dir)
            let isInteractive = descriptor?.state.isInteractive ?? false

            let path = sec.cgPath()

            ctx.saveGState()
            ctx.addPath(path)

            if isSelected && isInteractive {
                // Armed/Attuned highlight: luminous cyan-azure
                ctx.setFillColor(CGColor(red: 0.05, green: 0.28, blue: 0.48, alpha: 0.95))
                ctx.setStrokeColor(CGColor(red: 0.0, green: 0.89, blue: 1.0, alpha: 0.9))
                ctx.setLineWidth(2.0)
            } else if isInteractive {
                // Interactive idle: dark obsidian slate
                ctx.setFillColor(CGColor(red: 0.07, green: 0.09, blue: 0.13, alpha: 0.88))
                ctx.setStrokeColor(CGColor(red: 0.22, green: 0.27, blue: 0.35, alpha: 0.7))
                ctx.setLineWidth(1.2)
            } else {
                // Disabled / Locked / Empty: dimmed
                ctx.setFillColor(CGColor(red: 0.04, green: 0.05, blue: 0.08, alpha: 0.5))
                ctx.setStrokeColor(CGColor(red: 0.15, green: 0.18, blue: 0.22, alpha: 0.4))
                ctx.setLineWidth(1.0)
            }

            ctx.drawPath(using: .fillStroke)
            ctx.restoreGState()

            // Draw Sector Label & Keyboard Hint
            drawSectorContent(dir: dir, sec: sec, descriptor: descriptor, isSelected: isSelected, in: ctx)
        }

        // 3. Draw Active Nested Disclosure Ring
        if nestedParent != nil, !geom.nestedSectors.isEmpty {
            for (choiceID, nestedSec) in geom.nestedSectors {
                let isNestedArmed = (activeNestedChoice == choiceID)
                let nPath = nestedSec.cgPath()

                ctx.saveGState()
                ctx.addPath(nPath)
                if isNestedArmed {
                    ctx.setFillColor(CGColor(red: 0.12, green: 0.36, blue: 0.60, alpha: 0.95))
                    ctx.setStrokeColor(CGColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0))
                    ctx.setLineWidth(2.0)
                } else {
                    ctx.setFillColor(CGColor(red: 0.09, green: 0.12, blue: 0.18, alpha: 0.85))
                    ctx.setStrokeColor(CGColor(red: 0.28, green: 0.35, blue: 0.46, alpha: 0.7))
                    ctx.setLineWidth(1.0)
                }
                ctx.drawPath(using: .fillStroke)
                ctx.restoreGState()

                // Nested label
                drawNestedContent(choiceID: choiceID, nestedSec: nestedSec, isArmed: isNestedArmed, in: ctx)
            }
        }

        // 4. Neutral Center Ring / Pulse Point
        ctx.saveGState()
        let pulsePointRect = CGRect(x: center.x - 14, y: center.y - 14, width: 28, height: 28)
        ctx.setFillColor(CGColor(red: 0.08, green: 0.11, blue: 0.16, alpha: 0.9))
        ctx.setStrokeColor(CGColor(red: 0.0, green: 0.89, blue: 1.0, alpha: 0.75))
        ctx.setLineWidth(1.5)
        ctx.addEllipse(in: pulsePointRect)
        ctx.drawPath(using: .fillStroke)

        let innerDotRect = CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8)
        ctx.setFillColor(CGColor(red: 0.0, green: 0.89, blue: 1.0, alpha: 0.9))
        ctx.fillEllipse(in: innerDotRect)
        ctx.restoreGState()

        // 5. Debug Geometry Drawing (radii, sector lines, overshoot envelope)
        if showDebugGeometry {
            drawDebugGeometry(in: ctx, geom: geom, center: center)
        }
    }

    private func drawSectorContent(
        dir: CompassDirection,
        sec: VeilSectorGeometry,
        descriptor: VeilReflexDescriptor?,
        isSelected: Bool,
        in ctx: CGContext
    ) {
        let midRadius = (sec.innerRadius + sec.outerRadius) / 2.0
        let angleRad = sec.nominalCenterAngleDegrees * .pi / 180.0
        let textCenter = CGPoint(
            x: sec.center.x + midRadius * cos(angleRad),
            y: sec.center.y + midRadius * sin(angleRad)
        )

        let label = descriptor?.label ?? dir.rawValue
        let isEnabled = descriptor?.state.isInteractive ?? false

        let textColor: NSColor
        if isSelected {
            textColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else if isEnabled {
            textColor = NSColor(red: 0.85, green: 0.90, blue: 0.96, alpha: 0.95)
        } else {
            textColor = NSColor(red: 0.5, green: 0.55, blue: 0.65, alpha: 0.5)
        }

        let font = NSFont.systemFont(ofSize: 10.5, weight: isSelected ? .bold : .medium)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]

        let str = NSAttributedString(string: label, attributes: attrs)
        let strSize = str.size()
        let strRect = CGRect(
            x: textCenter.x - (strSize.width / 2),
            y: textCenter.y - (strSize.height / 2),
            width: strSize.width,
            height: strSize.height
        )

        str.draw(in: strRect)

        // Keyboard hint if present
        if let hint = descriptor?.keyboardHint, !hint.isEmpty {
            let hintFont = NSFont.monospacedSystemFont(ofSize: 8.5, weight: .regular)
            let hintColor = isSelected ? NSColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 0.9) : NSColor(white: 0.6, alpha: 0.7)
            let hintAttrs: [NSAttributedString.Key: Any] = [
                .font: hintFont,
                .foregroundColor: hintColor
            ]
            let hintStr = NSAttributedString(string: hint, attributes: hintAttrs)
            let hintSize = hintStr.size()
            let hintRect = CGRect(
                x: textCenter.x - (hintSize.width / 2),
                y: strRect.minY - hintSize.height - 1,
                width: hintSize.width,
                height: hintSize.height
            )
            hintStr.draw(in: hintRect)
        }
    }

    private func drawNestedContent(
        choiceID: String,
        nestedSec: VeilSectorGeometry,
        isArmed: Bool,
        in ctx: CGContext
    ) {
        let midRadius = (nestedSec.innerRadius + nestedSec.outerRadius) / 2.0
        let angleRad = nestedSec.nominalCenterAngleDegrees * .pi / 180.0
        let textCenter = CGPoint(
            x: nestedSec.center.x + midRadius * cos(angleRad),
            y: nestedSec.center.y + midRadius * sin(angleRad)
        )

        let label = choiceID.split(separator: ".").last.map(String.init) ?? choiceID
        let font = NSFont.systemFont(ofSize: 9.0, weight: isArmed ? .bold : .medium)
        let textColor = isArmed ? NSColor.white : NSColor(white: 0.8, alpha: 0.9)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        let str = NSAttributedString(string: label, attributes: attrs)
        let size = str.size()
        let rect = CGRect(
            x: textCenter.x - (size.width / 2),
            y: textCenter.y - (size.height / 2),
            width: size.width,
            height: size.height
        )
        str.draw(in: rect)
    }

    private func drawDebugGeometry(in ctx: CGContext, geom: VeilRingGeometry, center: CGPoint) {
        ctx.saveGState()

        // 1. Inner radius circle (yellow)
        ctx.setStrokeColor(CGColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 0.8))
        ctx.setLineWidth(1.0)
        ctx.addEllipse(in: CGRect(x: center.x - geom.innerRadius, y: center.y - geom.innerRadius, width: 2 * geom.innerRadius, height: 2 * geom.innerRadius))
        ctx.strokePath()

        // 2. Outer radius circle (yellow)
        ctx.addEllipse(in: CGRect(x: center.x - geom.outerRadius, y: center.y - geom.outerRadius, width: 2 * geom.outerRadius, height: 2 * geom.outerRadius))
        ctx.strokePath()

        // 3. Overshoot envelopes for sectors (magenta dashed)
        ctx.setStrokeColor(CGColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 0.7))
        ctx.setLineDash(phase: 0, lengths: [2, 2])
        for (_, sec) in geom.sectors {
            ctx.addPath(sec.overshootPath())
            ctx.strokePath()
        }

        // 4. Sector boundary rays (cyan)
        ctx.setStrokeColor(CGColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.5))
        ctx.setLineDash(phase: 0, lengths: [])
        for (_, sec) in geom.sectors {
            let startRad = sec.startAngleDegrees * .pi / 180.0
            ctx.move(to: CGPoint(x: center.x + sec.innerRadius * cos(startRad), y: center.y + sec.innerRadius * sin(startRad)))
            ctx.addLine(to: CGPoint(x: center.x + sec.outerRadius * cos(startRad), y: center.y + sec.outerRadius * sin(startRad)))
            ctx.strokePath()
        }

        ctx.restoreGState()
    }
}
#endif
