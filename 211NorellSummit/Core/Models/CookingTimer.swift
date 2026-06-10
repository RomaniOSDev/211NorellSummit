import Foundation

struct CookingTimer: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var durationSeconds: Int
    var remainingSeconds: Int
    var endDate: Date?
    var isRunning: Bool
    var isPaused: Bool

    var liveRemainingSeconds: Int {
        remainingSeconds(at: Date())
    }

    func remainingSeconds(at date: Date) -> Int {
        if isRunning, let endDate {
            return max(0, Int(endDate.timeIntervalSince(date)))
        }
        return remainingSeconds
    }

    func progress(at date: Date) -> Double {
        guard durationSeconds > 0 else { return 0 }
        return Double(remainingSeconds(at: date)) / Double(durationSeconds)
    }
}
