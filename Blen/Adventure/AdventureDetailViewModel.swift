import Foundation
import MapKit

class AdventureDetailViewModel: ObservableObject {
    @Published var adventure: Adventure
    @Published var isFavorite: Bool = false
    @Published var isCompleted: Bool = false
    
    private var dataService: DataService
    
    init(adventure: Adventure, dataService: DataService = .shared) {
        self.adventure = adventure
        self.dataService = dataService
        updateState()
    }
    
    private func updateState() {
        let progress = dataService.userProgress
        isFavorite = progress.favoriteAdventures.contains(adventure.id)
        isCompleted = progress.completedAdventures.contains(adventure.id)
    }
    
    func toggleFavorite() {
        if isFavorite {
            dataService.userProgress.favoriteAdventures.remove(adventure.id)
        } else {
            dataService.userProgress.favoriteAdventures.insert(adventure.id)
        }
        dataService.saveUserProgress()
        updateState()
    }
    
    func markAsCompleted() {
        dataService.userProgress.completedAdventures.insert(adventure.id)
        
        let points: Int
        switch adventure.difficulty {
        case .beginner: points = 10
        case .intermediate: points = 20
        case .advanced: points = 30
        case .expert: points = 50
        }
        dataService.userProgress.totalPoints += points
        
        dataService.saveUserProgress()
        updateState()
    }
    
    func openInMaps() {
        let coordinate = CLLocationCoordinate2D(
            latitude: adventure.coordinates.latitude,
            longitude: adventure.coordinates.longitude
        )
        
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = adventure.title
        mapItem.openInMaps(launchOptions: nil)
    }
}
