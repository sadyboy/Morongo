import Foundation

struct Milestone: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let type: MilestoneType
    let threshold: Double
    let reward: Int
    var isAchieved: Bool
    var achievedDate: Date?
    
    enum MilestoneType: String, Codable {
        case totalDistance
        case totalDuration
        case totalCalories
        case totalActivities
        case specificActivity
    }
}
