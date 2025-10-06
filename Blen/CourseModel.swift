import Foundation

struct Course: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: Adventure.AdventureCategory
    let difficulty: Adventure.Difficulty
    let duration: String
    let modules: [Module]
    let imageURL: String
    let instructor: String
    let rating: Double
    let reviews: Int
    let price: String
    let features: [String] 
    let imageName: String
    
    struct Module: Identifiable, Codable {
        let id: UUID
        let title: String
        let description: String
        let lessons: [Lesson] 
        var isCompleted: Bool
    }
    
    struct Lesson: Identifiable, Codable {
        let id: UUID
        let title: String
        let description: String
        let type: LessonType
        let duration: Int 
        let content: String
        var isCompleted: Bool
        
        enum LessonType: String, Codable {
            case video = "video"
            case interactive = "interactive"
            case text = "text"
            case quiz = "quiz"
            
            var icon: String {
                switch self {
                case .video: return "play.rectangle.fill"
                case .interactive: return "hand.tap.fill"
                case .text: return "doc.text.fill"
                case .quiz: return "questionmark.circle.fill"
                }
            }
        }
    }
}
