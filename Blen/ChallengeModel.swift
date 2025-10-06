import Foundation

struct Challenge: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let type: ChallengeType
    let target: Double
    let startDate: Date
    let endDate: Date
    let reward: Int
    var participants: [UUID]
    var leaderboard: [LeaderboardEntry]
    
    struct LeaderboardEntry: Identifiable, Codable {
        let id: UUID
        let userId: UUID
        var progress: Double
        let rank: Int
    }
    
    enum ChallengeType: String, Codable {
        case distance
        case elevation
        case activities
        case duration
    }
}
extension Challenge {
    func progress(for userId: UUID) -> Double {
        leaderboard.first(where: { $0.userId == userId })?.progress ?? 0
    }
}
extension Challenge {
    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
    
    var isCompleted: Bool {
        leaderboard.contains { $0.progress >= target }
    }
}
extension Challenge {
    static func create(
        title: String,
        description: String,
        type: ChallengeType,
        target: Double,
        durationDays: Int,
        reward: Int
    ) -> Challenge {
        Challenge(
            id: UUID(),
            title: title,
            description: description,
            type: type,
            target: target,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: durationDays, to: Date())!,
            reward: reward,
            participants: [],
            leaderboard: []
        )
    }
}
extension Challenge {
    mutating func updateProgress(for userId: UUID, value: Double) {
        if let index = leaderboard.firstIndex(where: { $0.userId == userId }) {
            leaderboard[index] = LeaderboardEntry(
                id: leaderboard[index].id,
                userId: userId,
                progress: value,
                rank: leaderboard[index].rank
            )
        } else {
            leaderboard.append(LeaderboardEntry(
                id: UUID(),
                userId: userId,
                progress: value,
                rank: leaderboard.count + 1
            ))
            participants.append(userId)
        }
    }
}
