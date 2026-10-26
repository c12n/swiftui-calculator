import Foundation
import Observation

enum CalculatorOperation: Hashable {
    case add, subtract, multiply, divide

    /// Returns nil on division by zero.
    func apply(_ lhs: Double, _ rhs: Double) -> Double? {
        switch self {
        case .add: return lhs + rhs
        case .subtract: return lhs - rhs
        case .multiply: return lhs * rhs
        case .divide: return rhs == 0 ? nil : lhs / rhs
        }
    }
}

enum CalculatorKey: Hashable {
    case digit(Int)
    case decimal
    case operation(CalculatorOperation)
    case equals
    case clear
    case toggleSign
    case percent
}

@Observable
final class CalculatorViewModel {
    private(set) var displayText = "0"

    /// Operator waiting for its second operand (highlighted in the UI).
    private(set) var activeOperation: CalculatorOperation?

    private var currentValue: Double = 0
    private var storedValue: Double?
    private var pendingOperation: CalculatorOperation?
    private var lastOperation: CalculatorOperation?
    private var lastOperand: Double?
    private var isEnteringNumber = false
    private var hasError = false

    private static let maxDigits = 9

    var clearLabel: String { showsAllClear ? "AC" : "C" }

    private var showsAllClear: Bool {
        hasError || !isEnteringNumber || displayText == "0"
    }

    func press(_ key: CalculatorKey) {
        switch key {
        case .digit(let digit): inputDigit(digit)
        case .decimal: inputDecimal()
        case .operation(let operation): setOperation(operation)
        case .equals: calculate()
        case .clear: clear()
        case .toggleSign: toggleSign()
        case .percent: applyPercent()
        }
    }

    // MARK: - Number entry

    private func inputDigit(_ digit: Int) {
        if hasError { reset() }
        prepareForEntry()
        guard displayText.filter(\.isNumber).count < Self.maxDigits else { return }
        switch displayText {
        case "0": displayText = String(digit)
        case "-0": displayText = "-\(digit)"
        default: displayText += String(digit)
        }
        currentValue = Double(displayText) ?? 0
    }

    private func inputDecimal() {
        if hasError { reset() }
        prepareForEntry()
        if !displayText.contains(".") {
            displayText += "."
        }
    }

    private func toggleSign() {
        guard !hasError else { return }
        if activeOperation != nil || displayText == "0" {
            prepareForEntry()
        }
        displayText = displayText.hasPrefix("-") ? String(displayText.dropFirst()) : "-" + displayText
        currentValue = -currentValue
    }

    /// Starts a fresh number if the display shows a result or an operator was just tapped.
    private func prepareForEntry() {
        activeOperation = nil
        guard !isEnteringNumber else { return }
        displayText = "0"
        currentValue = 0
        isEnteringNumber = true
    }

    // MARK: - Operations

    private func setOperation(_ operation: CalculatorOperation) {
        guard !hasError else { return }
        if activeOperation == nil {
            if let pending = pendingOperation, let stored = storedValue {
                guard showResult(pending.apply(stored, currentValue)) else { return }
            }
            storedValue = currentValue
        }
        pendingOperation = operation
        activeOperation = operation
        isEnteringNumber = false
    }

    private func calculate() {
        guard !hasError else { return }
        if let pending = pendingOperation, let stored = storedValue {
            lastOperation = pending
            lastOperand = currentValue
            showResult(pending.apply(stored, currentValue))
        } else if let last = lastOperation, let operand = lastOperand {
            showResult(last.apply(currentValue, operand))
        }
        storedValue = nil
        pendingOperation = nil
        activeOperation = nil
        isEnteringNumber = false
    }

    private func applyPercent() {
        guard !hasError else { return }
        if let stored = storedValue, pendingOperation == .add || pendingOperation == .subtract {
            showResult(stored * currentValue / 100)
        } else {
            showResult(currentValue / 100)
        }
        activeOperation = nil
        isEnteringNumber = false
    }

    private func clear() {
        if showsAllClear {
            reset()
            return
        }
        displayText = "0"
        currentValue = 0
        isEnteringNumber = false
        activeOperation = pendingOperation
    }

    // MARK: - Helpers

    @discardableResult
    private func showResult(_ value: Double?) -> Bool {
        guard let value, value.isFinite else {
            showError()
            return false
        }
        currentValue = value
        displayText = Self.format(value)
        return true
    }

    private func showError() {
        reset()
        displayText = "Error"
        hasError = true
    }

    private func reset() {
        displayText = "0"
        currentValue = 0
        storedValue = nil
        pendingOperation = nil
        activeOperation = nil
        lastOperation = nil
        lastOperand = nil
        isEnteringNumber = false
        hasError = false
    }

    private static func format(_ value: Double) -> String {
        guard value != 0 else { return "0" }
        let locale = Locale(identifier: "en_US_POSIX")
        let magnitude = abs(value)
        if magnitude >= 1e9 || magnitude < 1e-8 {
            return value.formatted(.number.notation(.scientific).precision(.significantDigits(1...6)).locale(locale)).lowercased()
        }
        return value.formatted(.number.precision(.significantDigits(1...9)).grouping(.never).locale(locale))
    }
}
