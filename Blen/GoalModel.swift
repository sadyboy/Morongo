import Foundation

struct Goal: Identifiable, Codable {
    let id: UUID
    let type: GoalType
    let target: Double
    let period: Period
    let startDate: Date
    var progress: Double
    var isCompleted: Bool
    
    enum GoalType: String, Codable {
        case distance
        case duration
        case calories
        case frequency
        
        var unit: String {
            switch self {
            case .distance: return "km"
            case .duration: return "min"
            case .calories: return "kcal"
            case .frequency: return "times"
            }
        }
        
        var icon: String {
            switch self {
            case .distance: return "figure.walk"
            case .duration: return "clock"
            case .calories: return "flame"
            case .frequency: return "repeat"
            }
        }
    }
    
    enum Period: String, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
    }
}
