
import Foundation
import Combine
import CoreLocation
import CoreMotion

class TrackerViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userProgress: UserProgress
    @Published var currentActivity: SportActivity?
    @Published var isTracking = false
    @Published var currentLocation: CLLocation?
    @Published var routeLocations: [SportActivity.LocationPoint] = []
    @Published var heartRate: Int?
    @Published var selectedActivityType: SportActivity.ActivityType = .hiking
    @Published var selectedDifficulty: Adventure.Difficulty = .beginner
    private(set) var currentUserId: UUID
    private var locationManager: CLLocationManager?
    private var startTime: Date?
    private var timer: Timer?
    private var dataService: TrackerDataService
    private var cancellables = Set<AnyCancellable>()
    
    
    @Published var steps: Int = 0
    
    private let pedometer = CMPedometer()
    
    
    
    init(dataService: TrackerDataService = TrackerDataService()) {
        self.dataService = dataService
        self.userProgress = dataService.loadUserProgress()
        if let savedId = UserDefaults.standard.string(forKey: "currentUserId"),
                 let uuid = UUID(uuidString: savedId) {
                  self.currentUserId = uuid
              } else {
                  let newId = UUID()
                  self.currentUserId = newId
                  UserDefaults.standard.set(newId.uuidString, forKey: "currentUserId")
              }
        
        super.init()
              
        setupLocationManager()
    }
    
    func deleteActivity(_ activity: SportActivity) {
        if let index = userProgress.activities.firstIndex(where: { $0.id == activity.id }) {
            userProgress.activities.remove(at: index)
            dataService.saveUserProgress(userProgress)
        }
    }

    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self   // ✅
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.activityType = .fitness
        locationManager?.distanceFilter = 10
    }
    
    
    
    func startActivity() {
        guard !isTracking else { return }
        isTracking = true
        startTime = Date()
        routeLocations.removeAll()

        locationManager?.startUpdatingLocation()

        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { [weak self] data, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self?.steps = data.numberOfSteps.intValue
                }
            }
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateCurrentActivity()
        }
    }
    
    func stopActivity() {
            guard isTracking else { return }
            isTracking = false
            locationManager?.stopUpdatingLocation()
            pedometer.stopUpdates()
            timer?.invalidate()
        if var activity = currentActivity {
     
            activity.route = routeLocations
            
            userProgress.addActivity(activity)
            updateChallengesProgress(with: activity)
            dataService.saveUserProgress(userProgress)
        }
        
        currentActivity = nil
        startTime = nil
    }
    
    func pauseActivity() {
        guard isTracking else { return }
        
        isTracking = false
        locationManager?.stopUpdatingLocation()
        timer?.invalidate()
    }
    
    func resumeActivity() {
        guard !isTracking, startTime != nil else { return }
        
        isTracking = true
        locationManager?.startUpdatingLocation()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateCurrentActivity()
        }
    }
    
    func updateChallengesProgress(with activity: SportActivity) {
        for i in userProgress.activeChallenges.indices {
            var challenge = userProgress.activeChallenges[i]

            if let idx = challenge.leaderboard.firstIndex(where: { $0.userId == currentUserId }) {
                var entry = challenge.leaderboard[idx]

                switch challenge.type {
                case .distance:
                    entry.progress += activity.distance ?? 0
                case .duration:
                    entry.progress += activity.duration / 60
                case .activities:
                    entry.progress += 1
                case .elevation:
                    break
                }

                challenge.leaderboard[idx] = entry
            }

            userProgress.activeChallenges[i] = challenge
        }

        dataService.saveUserProgress(userProgress)
    }

    
    private func updateCurrentActivity() {
        guard let startTime = startTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        let distance = calculateTotalDistance()
        let calories = calculateCalories(duration: duration, distance: distance)
        
        currentActivity = SportActivity(
            id: UUID(),
            type: selectedActivityType,
            startTime: startTime,
            duration: duration,
            distance: distance,
            calories: calories, steps: steps,
            heartRate: createHeartRateData(),
            route: routeLocations,
            notes: nil,
            photos: nil,
            difficulty: selectedDifficulty,
            relatedAdventureId: nil,
            relatedCourseId: nil
        )
    }
    
    private func calculateTotalDistance() -> Double? {
        guard routeLocations.count > 1 else { return nil }
        
        var totalDistance: Double = 0
        var previousLocation: CLLocation?
        
        for point in routeLocations {
            let location = CLLocation(
                latitude: point.latitude,
                longitude: point.longitude
            )
            
            if let previous = previousLocation {
                totalDistance += location.distance(from: previous)
            }
            
            previousLocation = location
        }
        
        return totalDistance / 1000
    }
    
    private func calculateCalories(duration: TimeInterval, distance: Double?) -> Int {
        let hours = duration / 3600
        let met = selectedActivityType.metValue
        let weight = 70.0
        
        let calories = met * weight * hours
        return Int(calories)
    }
    
    private func createHeartRateData() -> SportActivity.HeartRateData? {
        guard let currentHeartRate = heartRate else { return nil }
        
        return SportActivity.HeartRateData(
            average: currentHeartRate,
            max: currentHeartRate,
            min: currentHeartRate,
            zones: []
        )
    }
    
    // MARK: - Goals Management
    
    func addGoal(_ goal: Goal) {
        userProgress.goals.append(goal)
        dataService.saveUserProgress(userProgress)
    }
    
    func updateGoalProgress(_ goal: Goal, progress: Double) {
        if let index = userProgress.goals.firstIndex(where: { $0.id == goal.id }) {
            userProgress.goals[index].progress = progress
            if progress >= goal.target {
                userProgress.goals[index].isCompleted = true
                userProgress.totalPoints += 50 
            }
            dataService.saveUserProgress(userProgress)
        }
    }
    
    // MARK: - Challenges Management
    
    func joinChallenge(_ challenge: Challenge) {
        if !userProgress.activeChallenges.contains(where: { $0.id == challenge.id }) {
            var challenge = challenge

            challenge.participants.append(currentUserId)
            challenge.leaderboard.append(
                Challenge.LeaderboardEntry(
                    id: UUID(),
                    userId: currentUserId,
                    progress: 0,
                    rank: challenge.participants.count
                )
            )

            userProgress.activeChallenges.append(challenge)
            dataService.saveUserProgress(userProgress)
        }
    }
    
    // MARK: - Stats
    
    func getStats(for period: Goal.Period) -> ActivityStats {
        let calendar = Calendar.current
        let now = Date()
        
        var startDate: Date
        switch period {
        case .daily:
            startDate = calendar.startOfDay(for: now)
        case .weekly:
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        case .monthly:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        }
        
        let filteredActivities = userProgress.activities.filter { $0.startTime >= startDate }
        
        return ActivityStats(
            totalDistance: filteredActivities.compactMap { $0.distance }.reduce(0, +),
            totalDuration: filteredActivities.map { $0.duration }.reduce(0, +),
            totalCalories: filteredActivities.map { $0.calories }.reduce(0, +),
            activityCount: Dictionary(grouping: filteredActivities, by: { $0.type })
                .mapValues { $0.count }
        )
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        
        for location in locations {
            let point = SportActivity.LocationPoint(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                altitude: location.altitude,  
                timestamp: Date()
        
            )
            routeLocations.append(point)
        }
    }
}

