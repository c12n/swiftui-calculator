import Foundation
import Observation
import SwiftUI // for Array.remove(atOffsets:), per Claude's review

struct HistoryEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    let expression: String
    let result: String
    /// The exact numeric result, so reuse does not depend on the
    /// (possibly rounded / scientific) display text.
    let value: Double
    let date: Date
}

/// Shared, persisted calculation history (UserDefaults, latest first, max 100).
@Observable
final class HistoryStore {
    private(set) var entries: [HistoryEntry] = []

    /// Set when a history result should be loaded into the calculator(s).
    var loadValue: Double?
    var loadRequestID = UUID()

    private let storageKey = "calculationHistory.v1"
    private let maxEntries = 100

    init() {
        load()
    }

    func add(expression: String, result: String, value: Double) {
        entries.insert(
            HistoryEntry(expression: expression, result: result, value: value, date: Date()),
            at: 0
        )
        if entries.count > maxEntries {
            entries.removeLast(entries.count - maxEntries)
        }
        save()
    }

    func remove(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func clear() {
        entries.removeAll()
        save()
    }

    /// Ask the visible calculator panel(s) to load this entry's value.
    func requestLoad(_ entry: HistoryEntry) {
        loadValue = entry.value
        loadRequestID = UUID()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data)
        else { return }
        entries = decoded
    }
}
