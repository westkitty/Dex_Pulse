import Foundation
import AppKit
import PulseCore

/// Results of context validity checking before capability execution.
public enum ContextValidationResult: String, Sendable, Codable {
    case valid = "valid"
    case staleGenerationToken = "staleContext.mismatchedGenerationToken"
    case processTerminated = "staleContext.processTerminated"
    case applicationMismatch = "staleContext.applicationMismatch"
}

/// Guard preventing stale or replaced UI/process context from being acted upon.
public struct StaleContextValidator: Sendable {

    /// Validates an object against the active interaction generation token and live process state.
    public static func validate(
        object: any PulseObject,
        activeGenerationToken: String
    ) -> ContextValidationResult {
        // 1. Generation token validation
        if let token = object.contextGenerationToken {
            guard token == activeGenerationToken else {
                return .staleGenerationToken
            }
        }

        // 2. Live Process Validation
        if let pid = object.provenance.sourcePID, pid > 0 {
            // Check if process is still responsive / alive
            let killResult = kill(pid, 0)
            guard killResult == 0 else {
                return .processTerminated
            }

            // Check if owning application bundle still matches if specified
            if let expectedBundle = object.provenance.sourceAppBundle {
                if let runningApp = NSRunningApplication(processIdentifier: pid) {
                    if runningApp.isTerminated {
                        return .processTerminated
                    }
                    if let actualBundle = runningApp.bundleIdentifier, actualBundle != expectedBundle {
                        return .applicationMismatch
                    }
                }
            }
        }

        return .valid
    }
}
