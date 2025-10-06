import Foundation

// MARK: - Quiz Data Models
struct QuizData: Codable {
    let categories: [String: Category]
    
    struct Category: Codable {
        let name: String
        let description: String
        let questions: [QuestionData]
    }
    
    struct QuestionData: Codable {
        let id: String
        let text: String
        let options: [String]
        let correctAnswer: Int
        let explanation: String
    }
}

// MARK: - Quiz Data Service
// MARK: - Quiz Data Service
class QuizDataService {
    static let shared = QuizDataService()
    
    private var quizData: QuizData?
    
    private init() {
        loadQuizData()
    }
    
    private func loadQuizData() {
        let possibleFileNames = ["quiz_data", "quiz_questions", "quizzes"]
        
        for fileName in possibleFileNames {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    quizData = try decoder.decode(QuizData.self, from: data)
                    print("✅ Quiz data loaded successfully from \(fileName).json")
                    debugQuizData()
                    return
                } catch {
                    print("❌ Error loading quiz data from \(fileName).json: \(error)")
                    print("Error details: \(error.localizedDescription)")
                }
            }
        }
        
        print("❌ Could not find any quiz data file")
        quizData = createSampleQuizData()
    }
    
    func generateQuiz(category: Quiz.QuizCategory, difficulty: Adventure.Difficulty, questionCount: Int = 10) -> Quiz {
        
        guard let quizData = quizData else {
            print("❌ No quiz data available")
            return createFallbackQuiz(category: category, difficulty: difficulty)
        }
        
        guard let categoryData = quizData.categories[category.jsonKey] else {
//            print("❌ Category not found: \(category.jsonKey)")
            print("Available categories: \(quizData.categories.keys)")
            return createFallbackQuiz(category: category, difficulty: difficulty)
        }
        
        print("✅ Found \(categoryData.questions.count) questions for \(category.jsonKey)")
        
        let questionsToUse: [QuizData.QuestionData]
        if categoryData.questions.isEmpty {
            print("⚠️ No questions found, using fallback")
            questionsToUse = createFallbackQuestions()
        } else {
            let count = min(questionCount, categoryData.questions.count)
            questionsToUse = Array(categoryData.questions.shuffled().prefix(count))
        }
        
        let quizQuestions = questionsToUse.map { question in
            Quiz.Question(
                id: UUID(),
                text: question.text,
                options: question.options,
                correctAnswer: question.correctAnswer,
                explanation: question.explanation,
                userAnswer: nil
            )
        }
        
        return Quiz(
            id: UUID(),
            title: "\(categoryData.name) - \(difficulty.rawValue)",
            description: categoryData.description,
            category: category,
            difficulty: difficulty,
            questions: quizQuestions,
            requiredScore: calculateRequiredScore(difficulty: difficulty, totalQuestions: quizQuestions.count),
            userScore: nil,
            completionDate: nil,
            relatedCourseId: nil,
            relatedAdventureId: nil
        )
    }
    
    private func createFallbackQuiz(category: Quiz.QuizCategory, difficulty: Adventure.Difficulty) -> Quiz {
        print("🔄 Creating fallback quiz for \(category.rawValue) - \(difficulty.rawValue)")
        
        let fallbackQuestions = createFallbackQuestions()
        
        let quizQuestions = fallbackQuestions.map { question in
            Quiz.Question(
                id: UUID(),
                text: question.text,
                options: question.options,
                correctAnswer: question.correctAnswer,
                explanation: question.explanation,
                userAnswer: nil
            )
        }
        
        return Quiz(
            id: UUID(),
            title: "\(category.rawValue) - \(difficulty.rawValue)",
            description: "Temporary quiz - data loading issue",
            category: category,
            difficulty: difficulty,
            questions: quizQuestions,
            requiredScore: calculateRequiredScore(difficulty: difficulty, totalQuestions: quizQuestions.count),
            userScore: nil,
            completionDate: nil,
            relatedCourseId: nil,
            relatedAdventureId: nil
        )
    }
    
    func getAvailableCategories() -> [String] {
        guard let quizData = quizData else { return [] }
        return Array(quizData.categories.keys)
    }
    
    func getQuestionsCount(for category: Quiz.QuizCategory) -> Int {
        guard let quizData = quizData,
              let categoryData = quizData.categories[category.jsonKey] else {
            return 0
        }
        
        return categoryData.questions.count
    }
    
    private func createFallbackQuestions() -> [QuizData.QuestionData] {
        return [
            QuizData.QuestionData(
                id: "fallback_1",
                text: "What is the most important safety rule in outdoor activities?",
                options: [
                    "Always tell someone your plans",
                    "Carry expensive equipment",
                    "Take lots of photos",
                    "Go alone for peace"
                ],
                correctAnswer: 0,
                explanation: "Always inform someone about your plans and expected return time for safety."
            ),
            QuizData.QuestionData(
                id: "fallback_2",
                text: "Why is proper hydration important during hiking?",
                options: [
                    "It's not very important",
                    "Prevents dehydration and maintains energy",
                    "Makes you walk faster",
                    "Only matters in hot weather"
                ],
                correctAnswer: 1,
                explanation: "Proper hydration prevents dehydration and helps maintain energy levels."
            ),
            QuizData.QuestionData(
                id: "fallback_3",
                text: "What should you do if you get lost in the wilderness?",
                options: [
                    "Panic and run in any direction",
                    "Stay calm and stay in one place",
                    "Keep walking until you find something",
                    "Yell continuously for help"
                ],
                correctAnswer: 1,
                explanation: "Staying calm and in one place makes you easier to find and conserves energy."
            )
        ]
    }
    
    private func calculateRequiredScore(difficulty: Adventure.Difficulty, totalQuestions: Int) -> Int {
        let percentage: Double
        switch difficulty {
        case .beginner: percentage = 0.6  // 60%
        case .intermediate: percentage = 0.7  // 70%
        case .advanced: percentage = 0.8  // 80%
        case .expert: percentage = 0.9  // 90%
        }
        return Int(ceil(Double(totalQuestions) * percentage))
    }
    
    func debugQuizData() {
        guard let quizData = quizData else {
            print("❌ No quiz data loaded")
            return
        }
        
        print("\n=== QUIZ DATA DEBUG ===")
        for (key, category) in quizData.categories {
            print("📁 Category: \(key) - \(category.name)")
            print("   Description: \(category.description)")
            print("   📊 Questions: \(category.questions.count)")
        }
        print("=======================\n")
    }
    
    private func createSampleQuizData() -> QuizData {
        return QuizData(categories: [
            "safetyBasics": QuizData.Category(
                name: "Safety Basics",
                description: "Essential safety knowledge for outdoor activities",
                questions: createFallbackQuestions()
            ),
            "equipmentKnowledge": QuizData.Category(
                name: "Equipment Knowledge",
                description: "Understanding and using outdoor equipment effectively",
                questions: createFallbackQuestions()
            ),
            "navigationSkills": QuizData.Category(
                name: "Navigation Skills",
                description: "Mastering map reading, compass use, and route finding",
                questions: createFallbackQuestions()
            ),
            "survivalSkills": QuizData.Category(
                name: "Survival Skills",
                description: "Wilderness survival techniques and emergency procedures",
                questions: createFallbackQuestions()
            ),
            "firstAid": QuizData.Category(
                name: "First Aid",
                description: "Emergency medical response and injury treatment",
                questions: createFallbackQuestions()
            )
        ])
    }
}
