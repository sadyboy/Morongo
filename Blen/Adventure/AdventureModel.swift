import Foundation
import SwiftUI

// Adventure Model
struct Adventure: Identifiable, Codable {
    let id: UUID
    let title: String
    let category: AdventureCategory
    let difficulty: Difficulty
    let duration: String
    let distance: Double?
    let description: String
    let location: String
    let coordinates: Coordinates
    let tips: [String]
    let equipment: [String]
    let bestSeason: String
    let imageNames: [String]
    let rating: Double
    let reviews: Int
//    let Access: String
    
    struct Coordinates: Codable {
        let latitude: Double
        let longitude: Double
    }
    
        enum AdventureCategory: String, Codable, CaseIterable {
            case hiking = "Hiking"
            case climbing = "Climbing"
            case biking = "Biking"
            case water = "Water Sports"
            case air = "Air Sports"
            case skiing = "Skiing"
            case survival = "Survival"
            case navigation = "Navigation"
            case firstAid = "First Aid"
            case environment = "Environment"
            case weather = "Weather"
            
            var icon: String {
                switch self {
                case .hiking: return "hiking"
                case .climbing: return "climbing"
                case .biking: return "biking"
                case .water: return "waterSports"
                case .air: return "airSports"
                case .skiing: return "figure.skiing.downhill"
                case .survival: return "leaf.fill"
                case .navigation: return "map.fill"
                case .firstAid: return "cross.case.fill"
                case .environment: return "tree.fill"
                case .weather: return "cloud.fill"
                }
            }
        

        
        var color: Color {
            switch self {
                case .hiking:
                    return Color.yellow
                case .climbing:
                    return Color.yellow
                case .biking:
                    return Color.yellow
                case .water:
                    return Color.yellow
                case .air:
                    return Color.yellow
                case .skiing:
                    return Color.yellow
                case .survival:
                    return Color.yellow
                case .navigation:
                    return Color.yellow
                case .firstAid:
                    return Color.yellow
                case .environment:
                    return Color.yellow
                case .weather:
                    return Color.yellow
            }
        }
    }
    
    enum Difficulty: String, Codable, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
          
        var color: UIColor {
            switch self {
            case .beginner: return .systemGreen
            case .intermediate: return .systemYellow
            case .advanced: return .systemOrange
            case .expert: return .systemRed
            }
        }
    }
}
