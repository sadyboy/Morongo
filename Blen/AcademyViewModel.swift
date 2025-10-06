import Foundation
import Combine
import SwiftUI

// Academy ViewModel
class AcademyViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var selectedCourse: Course?
    @Published var filteredCourses: [Course] = []
    @Published var quizzes: [Quiz] = []
    @Published var filteredQuizzes: [Quiz] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: Adventure.AdventureCategory?
    @Published var adventures: [Adventure] = []
    private var dataService: DataService
    private var cancellables = Set<AnyCancellable>()
    
    init(dataService: DataService = .shared) {
        self.dataService = dataService
        
        dataService.$courses
            .assign(to: \.courses, on: self)
            .store(in: &cancellables)
        
        dataService.$quizzes
            .assign(to: \.quizzes, on: self)
            .store(in: &cancellables)
        
        dataService.$adventures
            .assign(to: \.adventures, on: self)
            .store(in: &cancellables)
        
        setupBindings()
    }
    
    private func setupBindings() {
        $searchText
            .combineLatest($selectedCategory, $courses)
            .map { searchText, category, courses in
                var filtered = courses
                
                if let category = category {
                    filtered = filtered.filter { $0.category == category }
                }
                
                if !searchText.isEmpty {
                    filtered = filtered.filter {
                        $0.title.lowercased().contains(searchText.lowercased()) ||
                        $0.description.lowercased().contains(searchText.lowercased())
                    }
                }
                
                return filtered
            }
            .assign(to: \.filteredCourses, on: self)
            .store(in: &cancellables)
        

        $searchText
            .combineLatest($selectedCategory, $quizzes)
            .map { searchText, category, quizzes in
                var filtered = quizzes
                
                if let category = category {
                    filtered = filtered.filter { quiz in
                        if let courseId = quiz.relatedCourseId,
                           let course = self.courses.first(where: { $0.id == courseId }) {
                            return course.category == category
                        }
                        return false
                    }
                }
                
                if !searchText.isEmpty {
                    filtered = filtered.filter {
                        $0.title.lowercased().contains(searchText.lowercased()) ||
                        $0.description.lowercased().contains(searchText.lowercased())
                    }
                }
                
                return filtered
            }
            .assign(to: \.filteredQuizzes, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - User Progress Methods
    
    var userProgress: UserProgress {
        dataService.userProgress
    }

    func submitQuiz(_ quiz: Quiz, score: Int) {
        dataService.submitQuiz(quiz, score: score)
    }
    
    func checkCourseCompletion(course: Course) {
        let allModulesCompleted = course.modules.allSatisfy { module in
            module.lessons.allSatisfy { lesson in
                dataService.userProgress.completedLessons.contains(lesson.id)
            }
        }
        
        if allModulesCompleted {
            let certificate = Certificate(
                id: UUID(),
                courseId: course.id,
                userId: UUID(),
                issueDate: Date(),
                grade: calculateGrade(for: course),
                relatedToQuiz: false,
                score: nil,
                totalQuestions: nil,
                courseTitle: course.title
            )
            dataService.userProgress.certificates.append(certificate)
            dataService.userProgress.totalPoints += 100
            dataService.saveUserProgress()
        }
    }
    
    private func calculateGrade(for course: Course) -> String {
        let completedLessonsCount = course.modules
            .flatMap { $0.lessons }
            .filter { dataService.userProgress.completedLessons.contains($0.id) }
            .count
        
        let totalLessonsCount = course.modules.flatMap { $0.lessons }.count
        
        let completionPercentage = Double(completedLessonsCount) / Double(totalLessonsCount) * 100
        
        switch completionPercentage {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
    
    // MARK: - Helper Methods
    
    var userCertificates: [Certificate] {
        dataService.userProgress.certificates
    }
    
    func isLessonCompleted(_ lesson: Course.Lesson) -> Bool {
        dataService.userProgress.completedLessons.contains(lesson.id)
    }
    
    func markLessonCompleted(_ lesson: Course.Lesson) {
        dataService.userProgress.completedLessons.insert(lesson.id)
        dataService.userProgress.totalPoints += 10
        dataService.saveUserProgress()
    }
    
    func getCourseProgress(_ course: Course) -> Double {
        let totalLessons = course.modules.flatMap { $0.lessons }.count
        guard totalLessons > 0 else { return 0 }
        
        let completedLessons = course.modules
            .flatMap { $0.lessons }
            .filter { dataService.userProgress.completedLessons.contains($0.id) }
            .count
        
        return Double(completedLessons) / Double(totalLessons)
    }
}
