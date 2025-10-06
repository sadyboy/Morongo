import Foundation
import SwiftUI

struct SportActivity: Identifiable, Codable {
    let id: UUID
    let type: ActivityType
    let startTime: Date
    let duration: TimeInterval
    let distance: Double?
    let calories: Int
    let steps: Int?
    let heartRate: HeartRateData?
    var route: [LocationPoint]?
    let notes: String?
    let photos: [String]?
    let difficulty: Adventure.Difficulty
    let relatedAdventureId: UUID?
    let relatedCourseId: UUID?
    
    struct HeartRateData: Codable {
        let average: Int
        let max: Int
        let min: Int
        let zones: [HeartRateZone]
    }
    
    struct HeartRateZone: Codable {
        let zone: Int
        let duration: TimeInterval
    }
    
    struct LocationPoint: Codable, Identifiable, Equatable {
        var id = UUID()
        let latitude: Double
        let longitude: Double
        let altitude: Double
        let timestamp: Date
    }
    
    enum ActivityType: String, Codable, CaseIterable {
        case hiking = "Hiking"
        case climbing = "Rock Climbing"
        case biking = "Mountain Biking"
        case swimming = "Swimming"
        case running = "Running"
        case yoga = "Yoga"
        
        var icon: String {
            switch self {
            case .hiking: return "figure.hiking"
            case .climbing: return "figure.climbing"
            case .biking: return "bicycle"
            case .swimming: return "figure.pool.swim"
            case .running: return "figure.run"
            case .yoga: return "figure.mind.and.body"
            }
        }
        
        var color: Color {
            switch self {
            case .hiking: return .green
            case .climbing: return .orange
            case .biking: return .blue
            case .swimming: return .cyan
            case .running: return .purple
            case .yoga: return .indigo
            }
        }
        
        var metValue: Double {
            switch self {
            case .hiking: return 6.0
            case .climbing: return 8.0
            case .biking: return 7.5
            case .swimming: return 7.0
            case .running: return 8.5
            case .yoga: return 3.0
            }
        }
    }
}
