import Foundation

struct Certificate: Identifiable, Codable {
    let id: UUID
    let courseId: UUID?
    let userId: UUID
    let issueDate: Date
    let grade: String
    var relatedToQuiz: Bool
    var score: Int?
    var totalQuestions: Int?
    var courseTitle: String?
}
