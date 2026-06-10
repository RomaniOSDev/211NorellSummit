import Foundation

struct BatchTimelineStep: Identifiable, Codable, Hashable {
    var id: String
    var recipeID: String
    var recipeTitle: String
    var stepIndex: Int
    var instruction: String
    var durationMinutes: Int
    var orderIndex: Int
    var isCompleted: Bool
    var parallelHint: String?
}

struct BatchCookSession: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var recipeIDs: [String]
    var timelineSteps: [BatchTimelineStep]
    var createdDate: Date
    var isCompleted: Bool
}
