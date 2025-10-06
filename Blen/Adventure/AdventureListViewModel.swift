import Foundation
import Combine

// Main ViewModel
class AdventureListViewModel: ObservableObject {
    @Published var adventures: [Adventure] = []
    @Published var filteredAdventures: [Adventure] = []
    @Published var selectedCategory: Adventure.AdventureCategory?
    @Published var selectedDifficulty: Adventure.Difficulty?
    @Published var searchText: String = ""
    
    private var dataService: DataService
    private var cancellables = Set<AnyCancellable>()
    
    init(dataService: DataService = .shared) {
        self.dataService = dataService
        
        dataService.$adventures
            .assign(to: \.adventures, on: self)
            .store(in: &cancellables)
        
        setupBindings()
    }
    
    private func setupBindings() {
        $searchText
            .combineLatest($selectedCategory, $selectedDifficulty, $adventures)
            .map { searchText, category, difficulty, adventures in
                var filtered = adventures
                
                if let category = category {
                    filtered = filtered.filter { $0.category == category }
                }
                
                if let difficulty = difficulty {
                    filtered = filtered.filter { $0.difficulty == difficulty }
                }
                
                if !searchText.isEmpty {
                    filtered = filtered.filter {
                        $0.title.lowercased().contains(searchText.lowercased()) ||
                        $0.description.lowercased().contains(searchText.lowercased())
                    }
                }
                
                return filtered
            }
            .assign(to: \.filteredAdventures, on: self)
            .store(in: &cancellables)
    }
    
    var userProgress: UserProgress {
        dataService.userProgress
    }
    
    func toggleFavorite(adventure: Adventure) {
        if dataService.userProgress.favoriteAdventures.contains(adventure.id) {
            dataService.userProgress.favoriteAdventures.remove(adventure.id)
        } else {
            dataService.userProgress.favoriteAdventures.insert(adventure.id)
        }
        dataService.saveUserProgress()
    }
    
    func markAsCompleted(adventure: Adventure) {
        dataService.userProgress.completedAdventures.insert(adventure.id)
        dataService.userProgress.totalPoints += Int(adventure.difficulty.color == .systemGreen ? 10 :
                                                  adventure.difficulty.color == .systemYellow ? 20 :
                                                  adventure.difficulty.color == .systemOrange ? 30 : 50)
        dataService.saveUserProgress()
    }
}
