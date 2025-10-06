import Foundation


struct ActivityStats {
    let totalDistance: Double
    let totalDuration: TimeInterval
    let totalCalories: Int
    let activityCount: [SportActivity.ActivityType: Int]
}
