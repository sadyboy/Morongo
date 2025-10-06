import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var userProgress: UserProgress
    @Published var certificates: [Certificate] = []
    @Published var recentActivities: [SportActivity] = []
    
    private var dataService: DataService
    private var cancellables = Set<AnyCancellable>()
    
    init(dataService: DataService = .shared) {
        self.dataService = dataService
        self.userProgress = dataService.userProgress
        
        dataService.$userProgress
            .sink { [weak self] progress in
                self?.userProgress = progress
                self?.certificates = progress.certificates
                self?.recentActivities = Array(progress.activities.suffix(5))
            }
            .store(in: &cancellables)
    }
    
    var completedAdventuresCount: Int {
        userProgress.completedAdventures.count
    }
    
    var completedCoursesCount: Int {
        userProgress.certificates.filter { !$0.relatedToQuiz }.count
    }
    
    var completedQuizzesCount: Int {
        userProgress.quizScores.count
    }
    
    func exportCertificate(_ certificate: Certificate, username: String) -> URL? {
        return CertificateExporter.generatePDF(for: certificate, username: username)
    }
}
