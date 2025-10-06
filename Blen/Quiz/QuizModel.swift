import Foundation
import SwiftUI


struct Quiz: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: QuizCategory
    let difficulty: Adventure.Difficulty
    let questions: [Question]
    let requiredScore: Int
    var userScore: Int?
    var completionDate: Date?
    var relatedCourseId: UUID?
    let relatedAdventureId: UUID?
    
    var progress: Double {
        let answered = questions.filter { $0.userAnswer != nil }.count
        return Double(answered) / Double(questions.count)
    }
    
    var status: QuizStatus {
        if completionDate != nil {
            return isPassed ? .passed : .failed
        }
        return progress > 0 ? .inProgress : .notStarted
    }
    
    struct Question: Identifiable, Codable {
        let id: UUID
        let text: String
        let options: [String]
        let correctAnswer: Int
        let explanation: String
        var userAnswer: Int?
        
        var isCorrect: Bool? {
            guard let userAnswer = userAnswer else { return nil }
            return userAnswer == correctAnswer
        }
        
        init(id: UUID, text: String, options: [String], correctAnswer: Int, explanation: String, userAnswer: Int?) {
            self.id = id
            self.text = text
            self.options = options
            self.correctAnswer = correctAnswer
            self.explanation = explanation
            self.userAnswer = userAnswer
        }
    }
    
    enum QuizCategory: String, Codable, CaseIterable {
        case safetyBasics = "Safety Basics"
        case equipment = "Equipment Knowledge"
        case navigation = "Navigation Skills"
        case survival = "Survival Skills"
        case firstAid = "First Aid"
        case environmentalAwareness = "Environmental Awareness"
        case weatherKnowledge = "Weather Knowledge"
        case techniqueBasics = "Technique Basics"
        
        var icon: String {
            switch self {
            case .safetyBasics: return "shield.fill"
            case .equipment: return "backpack.fill"
            case .navigation: return "map.fill"
            case .survival: return "leaf.fill"
            case .firstAid: return "cross.case.fill"
            case .environmentalAwareness: return "tree.fill"
            case .weatherKnowledge: return "cloud.fill"
            case .techniqueBasics: return "figure.hiking"
            }
        }
        
        var color: Color {
            switch self {
            case .safetyBasics: return .red
            case .equipment: return .orange
            case .navigation: return .blue
            case .survival: return .green
            case .firstAid: return .pink
            case .environmentalAwareness: return .mint
            case .weatherKnowledge: return .cyan
            case .techniqueBasics: return .purple
            }
        }
        
        var detailedDescription: String {
            switch self {
            case .safetyBasics: return "Essential safety protocols and risk management"
            case .equipment: return "Gear selection, maintenance and proper usage"
            case .navigation: return "Map reading, compass use and route finding"
            case .survival: return "Wilderness survival techniques and emergency shelter"
            case .firstAid: return "Emergency medical response and injury treatment"
            case .environmentalAwareness: return "Ecosystem understanding and leave no trace principles"
            case .weatherKnowledge: return "Weather patterns recognition and storm safety"
            case .techniqueBasics: return "Proper movement techniques and physical preparedness"
            }
        }
    }
    
    var scorePercentage: Double {
        guard let score = userScore else { return 0 }
        return Double(score) / Double(questions.count) * 100
    }
    var isPassed: Bool {
        guard let score = userScore else { return false }
        return score >= requiredScore
    }
    
    var correctAnswersCount: Int {
        questions.filter { $0.isCorrect == true }.count
    }
    
    var incorrectAnswersCount: Int {
        questions.filter { $0.isCorrect == false }.count
    }
}

enum QuizStatus {
    case notStarted, inProgress, passed, failed
}
extension Quiz.QuizCategory {
    var jsonKey: String {
        switch self {
        case .safetyBasics: return "safetyBasics"
        case .equipment: return "equipmentKnowledge"
        case .navigation: return "navigationSkills"
        case .survival: return "survivalSkills"
        case .firstAid: return "firstAid"
        case .environmentalAwareness: return "environmentalAwareness"
        case .weatherKnowledge: return "weatherKnowledge"
            case .techniqueBasics: return "techniqueBasics" 
        }
    }
}
