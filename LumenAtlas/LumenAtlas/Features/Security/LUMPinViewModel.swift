//
//  LUMPinViewModel.swift
//  LumenAtlas
//
//  Drives the PIN screen across three modes: unlocking the app, setting a new
//  PIN (with confirmation), and disabling an existing one (after verification).
//

import Foundation

final class LUMPinViewModel {

    enum Mode { case unlock, setup, disable }

    enum Step {
        case enter          // unlock or disable: type the existing PIN
        case create         // setup: type a new PIN
        case confirm        // setup: re-type to confirm
    }

    private let security: LUMSecurityServing
    let mode: Mode
    private(set) var step: Step

    /// Buffer of the first entry while confirming a new PIN.
    private var firstEntry: String?

    let pinLength = 4

    init(security: LUMSecurityServing, mode: Mode) {
        self.security = security
        self.mode = mode
        switch mode {
        case .unlock, .disable: self.step = .enter
        case .setup:            self.step = .create
        }
    }

    var prompt: String {
        switch (mode, step) {
        case (.unlock, _):   return "Enter your PIN"
        case (.disable, _):  return "Enter PIN to disable lock"
        case (.setup, .create):  return "Create a 4-digit PIN"
        case (.setup, .confirm): return "Confirm your PIN"
        default:             return "Enter your PIN"
        }
    }

    /// Result of submitting a full-length entry.
    enum Outcome {
        case success            // flow complete (unlocked / set / disabled)
        case advance            // setup moved from create -> confirm
        case mismatch           // confirmation didn't match
        case wrong              // entered PIN was incorrect
    }

    func submit(_ entry: String) -> Outcome {
        switch (mode, step) {
        case (.unlock, _):
            return security.validate(entry) ? .success : .wrong

        case (.disable, _):
            if security.validate(entry) {
                security.clearPIN()
                return .success
            }
            return .wrong

        case (.setup, .create):
            firstEntry = entry
            step = .confirm
            return .advance

        case (.setup, .confirm):
            if entry == firstEntry {
                security.setPIN(entry)
                return .success
            }
            // Reset back to the start of the setup flow.
            firstEntry = nil
            step = .create
            return .mismatch

        default:
            return .wrong
        }
    }
}
