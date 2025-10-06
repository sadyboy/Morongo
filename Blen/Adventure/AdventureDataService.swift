import Foundation
import MapKit
import SwiftUI

class AdventureDataService {
    private let userDefaultsKey = "userProgress"
    
    func loadAdventures() -> [Adventure] {
        return [
            Adventure(
                id: UUID(),
                title: "Mount San Jacinto Peak Trail",
                category: .hiking,
                difficulty: .advanced,
                duration: "5-7 hours",
                distance: 11.0,
                description: "Challenge yourself with this stunning peak trail offering 360-degree views of Southern California. This trail near Morongo Valley provides an unforgettable hiking experience.",
                location: "San Jacinto Mountains",
                coordinates: Adventure.Coordinates(latitude: 33.8147, longitude: -116.6794),
                tips: [
                    "Start early to avoid afternoon heat",
                    "Bring at least 3 liters of water",
                    "Check weather conditions before hiking",
                    "Wear proper hiking boots"
                ],
                equipment: ["Hiking boots", "Trekking poles", "Sun protection", "First aid kit"],
                bestSeason: "October - May",
                imageNames: ["mountain_trail"],
                rating: 4.8,
                reviews: 245,
            ),
            Adventure(
                id: UUID(),
                title: "Desert Hot Springs Rock Climbing",
                category: .climbing,
                difficulty: .intermediate,
                duration: "3-4 hours",
                distance: nil,
                description: "Experience world-class rock climbing just minutes from Morongo. Perfect granite formations with routes for all skill levels.",
                location: "Desert Hot Springs",
                coordinates: Adventure.Coordinates(latitude: 33.9614, longitude: -116.5017),
                tips: [
                    "Best climbing conditions in morning",
                    "Bring climbing chalk",
                    "Check local climbing regulations",
                    "Consider hiring a guide for first visit"
                ],
                equipment: ["Climbing harness", "Dynamic rope", "Carabiners", "Helmet", "Climbing shoes"],
                bestSeason: "November - March",
                imageNames: ["rock_climbing"],
                rating: 4.6,
                reviews: 178,
            ),
            Adventure(
                id: UUID(),
                title: "Whitewater Preserve Mountain Biking",
                category: .biking,
                difficulty: .intermediate,
                duration: "2-3 hours",
                distance: 15.5,
                description: "Thrilling mountain biking trails through diverse desert terrain. Experience the rush of technical descents and scenic climbs near Morongo.",
                location: "Whitewater Preserve",
                coordinates: Adventure.Coordinates(latitude: 33.9742, longitude: -116.6475),
                tips: [
                    "Check bike before riding",
                    "Wear protective gear",
                    "Ride within your limits",
                    "Carry spare tube and tools"
                ],
                equipment: ["Mountain bike", "Helmet", "Gloves", "Hydration pack"],
                bestSeason: "October - April",
                imageNames: ["mountain_biking"],
                rating: 4.7,
                reviews: 156,
            ),
            Adventure(
                id: UUID(),
                title: "Big Bear Lake Wakeboarding",
                category: .water,
                difficulty: .beginner,
                duration: "2-4 hours",
                distance: nil,
                description: "Learn wakeboarding on the pristine waters of Big Bear Lake. Professional instructors and equipment available. Great weekend adventure from Morongo area.",
                location: "Big Bear Lake",
                coordinates: Adventure.Coordinates(latitude: 34.2439, longitude: -116.9114),
                tips: [
                    "Book lessons in advance",
                    "Wear sunscreen",
                    "Start with beginner board",
                    "Listen to instructor carefully"
                ],
                equipment: ["Wakeboard", "Life vest", "Wetsuit", "Tow rope"],
                bestSeason: "June - September",
                imageNames: ["wakeboarding"],
                rating: 4.5,
                reviews: 203,
            ),
            Adventure(
                id: UUID(),
                title: "Palm Springs Parasailing Adventure",
                category: .air,
                difficulty: .beginner,
                duration: "1-2 hours",
                distance: nil,
                description: "Soar above the Coachella Valley with breathtaking views of the desert landscape. Safe and thrilling experience for all ages near Morongo.",
                location: "Palm Springs",
                coordinates: Adventure.Coordinates(latitude: 33.8303, longitude: -116.5453),
                tips: [
                    "Wear comfortable clothes",
                    "Bring camera with strap",
                    "Book early morning flights",
                    "Check wind conditions"
                ],
                equipment: ["All equipment provided"],
                bestSeason: "Year-round",
                imageNames: ["parasailing"],
                rating: 4.9,
                reviews: 312,
            ),
            Adventure(
                id: UUID(),
                title: "Joshua Tree Bouldering",
                category: .climbing,
                difficulty: .expert,
                duration: "Full day",
                distance: nil,
                description: "World-renowned bouldering destination with thousands of problems. Test your skills on unique rock formations in this desert wonderland.",
                location: "Joshua Tree National Park",
                coordinates: Adventure.Coordinates(latitude: 33.8734, longitude: -115.9010),
                tips: [
                    "Bring crash pads",
                    "Climb with spotters",
                    "Respect the environment",
                    "Stay hydrated"
                ],
                equipment: ["Climbing shoes", "Chalk bag", "Crash pads", "Brush"],
                bestSeason: "October - April",
                imageNames: ["bouldering"],
                rating: 4.8,
                reviews: 467,
            ),
        ]
    }
    
    func loadUserProgress() -> UserProgress {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            return progress
        }
        return UserProgress(completedAdventures: [], favoriteAdventures: [], completedLessons: [], certificates: [], quizScores: [:], activities: [], goals: [], activeChallenges: [], completedChallenges: [], milestones: [], totalPoints: 0, level: 1, achievements: [], weeklyStreak: 1, totalDistance: 1, totalDuration: 1, totalCalories: 1, activityCount: [:])
        

    }
    
    func saveUserProgress(_ progress: UserProgress) {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}
