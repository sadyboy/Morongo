import Foundation

// User Progress Model
struct UserProgress: Codable {
    // Adventure Progress
    var completedAdventures: Set<UUID>
    var favoriteAdventures: Set<UUID>
    
    // Academy Progress
    var completedLessons: Set<UUID>
    var certificates: [Certificate]
    var quizScores: [UUID: Int]
    
    // Sports Tracker Progress
    var activities: [SportActivity]
    var goals: [Goal]
    var activeChallenges: [Challenge]
    var completedChallenges: [Challenge]
    var milestones: [Milestone]
    
    // Gamification
    var totalPoints: Int
    var level: Int
    var achievements: [Achievement]
    var weeklyStreak: Int
    var lastActivityDate: Date?
    
    // Stats
    var totalDistance: Double
    var totalDuration: TimeInterval
    var totalCalories: Int
    var activityCount: [SportActivity.ActivityType: Int]
    
    struct Achievement: Codable {
        let id: UUID
        let title: String
        let description: String
        let icon: String
        let unlockedDate: Date?
        let points: Int
        let type: AchievementType
        
        enum AchievementType: String, Codable {
            case adventure
            case course
            case activity
            case challenge
            case milestone
        }
    }
    
    // Helper methods for stats
    mutating func addActivity(_ activity: SportActivity) {
        activities.append(activity)
        
        // Update stats
        if let distance = activity.distance {
            totalDistance += distance
        }
        totalDuration += activity.duration
        totalCalories += activity.calories
        activityCount[activity.type, default: 0] += 1
        
        // Update streak
        updateStreak(activityDate: activity.startTime)
        
        // Check milestones
        checkMilestones()
        
        // Update challenges
        updateChallenges(with: activity)
        
        // Award points
        awardPointsForActivity(activity)
    }
    
    private mutating func updateStreak(activityDate: Date) {
        let calendar = Calendar.current
        
        if let lastDate = lastActivityDate {
            let daysSinceLastActivity = calendar.dateComponents([.day], from: lastDate, to: activityDate).day ?? 0
            
            if daysSinceLastActivity == 1 {
                weeklyStreak += 1
            } else if daysSinceLastActivity > 1 {
                weeklyStreak = 1
            }
        } else {
            weeklyStreak = 1
        }
        
        lastActivityDate = activityDate
    }
    
    private mutating func checkMilestones() {
        for (index, milestone) in milestones.enumerated() {
            if !milestone.isAchieved {
                var isAchieved = false
                
                switch milestone.type {
                case .totalDistance:
                    isAchieved = totalDistance >= milestone.threshold
                case .totalDuration:
                    isAchieved = totalDuration >= milestone.threshold
                case .totalCalories:
                    isAchieved = Double(totalCalories) >= milestone.threshold
                case .totalActivities:
                    isAchieved = Double(activities.count) >= milestone.threshold
                case .specificActivity:
                    if let activityType = SportActivity.ActivityType.allCases.first(where: { $0.rawValue == milestone.title }) {
                        isAchieved = Double(activityCount[activityType, default: 0]) >= milestone.threshold
                    }
                }
                
                if isAchieved {
                    milestones[index].isAchieved = true
                    milestones[index].achievedDate = Date()
                    totalPoints += milestone.reward
                }
            }
        }
    }
    
    private mutating func updateChallenges(with activity: SportActivity) {
        for (index, challenge) in activeChallenges.enumerated() {
            if challenge.startDate <= activity.startTime && activity.startTime <= challenge.endDate {
                var progress: Double = 0
                
                switch challenge.type {
                case .distance:
                    progress = activity.distance ?? 0
                case .elevation:
                    if let route = activity.route {
                        progress = calculateElevationGain(from: route)
                    }
                case .activities:
                    progress = 1
                case .duration:
                    progress = activity.duration
                }
                
                if let userIndex = challenge.leaderboard.firstIndex(where: { $0.userId == UUID() }) {
                    let newProgress = challenge.leaderboard[userIndex].progress + progress
                    let newEntry = Challenge.LeaderboardEntry(
                        id: UUID(),
                        userId: challenge.leaderboard[userIndex].userId,
                        progress: newProgress,
                        rank: challenge.leaderboard[userIndex].rank
                    )
                    activeChallenges[index].leaderboard[userIndex] = newEntry
                    
                    if newProgress >= challenge.target {
                        totalPoints += challenge.reward
                        
                        completedChallenges.append(challenge)
                        activeChallenges.remove(at: index)
                    }
                }
            }
        }
    }
    
    private func calculateElevationGain(from route: [SportActivity.LocationPoint]) -> Double {
        var totalGain: Double = 0
        guard route.count > 1 else { return 0 }
        
        for i in 1..<route.count {
            let elevation = route[i].altitude - route[i-1].altitude
            if elevation > 0 {
                totalGain += elevation
            }
        }
        
        return totalGain
    }
    
    private mutating func awardPointsForActivity(_ activity: SportActivity) {
        var points = 10
        
        points += Int(activity.duration / 300)

        switch activity.difficulty {
        case .beginner: points += 5
        case .intermediate: points += 10
        case .advanced: points += 15
        case .expert: points += 20
        }
        
        if activity.relatedAdventureId != nil || activity.relatedCourseId != nil {
            points += 15
        }
        
        totalPoints += points
        updateLevel()
    }
    
    private mutating func updateLevel() {
        level = totalPoints / 100 + 1
    }
}
extension UserProgress {
    mutating func issueCertificate(for courseId: UUID, grade: String) -> Certificate {
        let certificate = Certificate(
            id: UUID(),
            courseId: courseId,
            userId: UUID(),
            issueDate: Date(),
            grade: grade,
            relatedToQuiz: false
        )
        certificates.append(certificate)
        return certificate
    }
}
// MARK: - View
