import SwiftUI
import MapKit


enum Country: String, CaseIterable, Identifiable {
    case usa = "USA"
    case canada = "Canada"
    case japan = "Japan"
    case france = "France"
    case india = "India"
    
    var id: String { rawValue }
    
    var coordinate: CLLocationCoordinate2D {
        switch self {
            case .usa: return CLLocationCoordinate2D(latitude: 37.0902, longitude: -95.7129)
            case .canada: return CLLocationCoordinate2D(latitude: 56.1304, longitude: -106.3468)
            case .japan: return CLLocationCoordinate2D(latitude: 36.2048, longitude: 138.2529)
            case .france: return CLLocationCoordinate2D(latitude: 46.6034, longitude: 1.8883)
            case .india: return CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629)
        }
    }
    
    var icon: String {
        switch self {
            case .usa: return "USA"
            case .canada: return "Canada"
            case .japan: return "Japan"
            case .france: return "France"
            case .india: return "India"
        }
    }
    
    var color: Color {
        switch self {
            case .usa: return .red
            case .canada: return .green
            case .japan: return .pink
            case .france: return .blue
            case .india: return .orange
        }
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            colors: [color.opacity(0.8), color.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct CountryButton: View {
    let country: Country
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                ZStack {
                    Image(country.icon)
                        .resizable()
//                        .scaledToFill()
                }
                .frame(width: 265, height: 265)
                .overlay {
                    RoundedRectangle(cornerRadius: 16).stroke(country.gradient, lineWidth: 8)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                Text(country.rawValue)
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
        }
//        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Adventure Map View
struct AdventureMapView: View {
    @State private var selectedAchievement: MapAchievement?
    @State private var showShareSheet = false
    @State private var showStatistics = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.0902, longitude: -95.7129),
        span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
    )
    
    @State private var selectedCountry: Country? = nil
    @State private var showCountryPicker = true
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var locationManager = CLLocationManager()
    @StateObject private var statsViewModel = MapStatisticsViewModel()
    @Environment(\.dismiss) var dismiss
    let layout = [
            GridItem(),
            GridItem(),
        ]
    var body: some View {
        ZStack {
            if let selectedCountry = selectedCountry {
                Map(
                    coordinateRegion: $region,
                    showsUserLocation: true,
                    userTrackingMode: .none,
                    annotationItems: selectedCountry.achievements
                ) { achievement in
                    MapAnnotation(coordinate: achievement.location) {
                        AchievementMarker(
                            achievement: achievement,
                            isSelected: selectedAchievement?.id == achievement.id
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedAchievement = achievement
                                region.center = achievement.location
                                region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            }
                        }
                    }
                }
                .ignoresSafeArea()
            } else {
                Color.black.opacity(0.5 ).ignoresSafeArea()
                countryPicker
            }
            
            if let selectedCountry = selectedCountry {
                VStack {
                    headerView(for: selectedCountry)
                        .padding(.horizontal)
                    Spacer()
                    
                    if let achievement = selectedAchievement {
                        AchievementDetailView(achievement: achievement) {
                            showShareSheet = true
                        }
                      
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    achievementsScrollView(for: selectedCountry)
                        .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            setupLocationManager()
        }
        .sheet(isPresented: $showShareSheet) {
            if let achievement = selectedAchievement {
                ShareSheet(activityItems: [achievement.shareText])
            }
        }
        .sheet(isPresented: $showStatistics) {
            MapStatisticsView(viewModel: statsViewModel)
        }
    }
}

extension AdventureMapView {
    
    private func headerView(for country: Country) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(country.rawValue) Adventures")
                    .font(.custom("Montserrat-Bold", size: 26))
                    .foregroundColor(.white)
                
                Text("\(country.achievements.filter { $0.isUnlocked }.count) of \(country.achievements.count) unlocked")
                    .font(.custom("Montserrat-Bold", size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        selectedCountry = nil
                        selectedAchievement = nil
                    }
                }) {
                    Image(systemName: "globe")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.orange.opacity(0.8))
                        .clipShape(Circle())
                }
                
                Button(action: {
                    showStatistics = true
                }) {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.green.opacity(0.8))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    private var countryPicker: some View {
        VStack(spacing: 20) {
            Text("Choose Your Adventure 🌍")
                .font(.custom("Montserrat-Bold", size: 26))
                .foregroundColor(.white)
                .shadow(radius: 4)
            
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Spacer(minLength: geometry.size.height * 0.15)
                        
//                        LazyVGrid(columns: layout, spacing: 20) {
                            ForEach(Country.allCases) { country in
                                CountryButton(country: country) {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        selectedCountry = country
                                        region.center = country.coordinate
                                        region.span = MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
                                    }
                                }
                                .transition(.scale.combined(with: .opacity))
                                .padding(.leading, 30)
                            }
//                        }
//                        .padding(.horizontal, 16)
                        
                        Spacer(minLength: geometry.size.height * 0.2)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.7)
            .padding(.horizontal)
            .background(Color.clear)
            .transition(.scale.combined(with: .opacity))
        }
    }

    
    private func achievementsScrollView(for country: Country) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(country.achievements) { achievement in
                    AchievementCard(
                        achievement: achievement,
                        isSelected: selectedAchievement?.id == achievement.id
                    )
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedAchievement = achievement
                            region.center = achievement.location
                            region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        }
                    }
                }
            }
            .padding(.bottom, 100)
            .padding(.horizontal)
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = makeCoordinator()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    private func makeCoordinator() -> LocationCoordinator {
        LocationCoordinator { location in
            DispatchQueue.main.async {
                self.userLocation = location.coordinate
                if abs(self.region.center.latitude - 37.0902) < 0.0001 {
                    withAnimation {
                        self.region.center = location.coordinate
                        self.region.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    }
                }
            }
        }
    }
}

// MARK: - Statistics View Model
class MapStatisticsViewModel: ObservableObject {
    @Published var totalDistance: Double = 0
    @Published var totalDuration: TimeInterval = 0
    @Published var totalCalories: Int = 0
    @Published var totalPoints: Int = 0
    @Published var achievementsByType: [AchievementType: Int] = [:]
    @Published var monthlyProgress: [MonthlyProgress] = []
    
    var totalDurationFormatted: String {
        let hours = Int(totalDuration) / 3600
        let minutes = Int(totalDuration) / 60 % 60
        return "\(hours)h \(minutes)m"
    }
    
    var completionPercentage: Double {
        let total = AchievementType.allCases.count * 3
        let unlocked = achievementsByType.values.reduce(0, +)
        return Double(unlocked) / Double(total) * 100
    }
    
    func calculateStatistics(from achievements: [MapAchievement]) {
        totalDistance = achievements
            .filter { $0.isUnlocked }
            .compactMap { $0.distance }
            .reduce(0, +)
        
        totalDuration = achievements
            .filter { $0.isUnlocked }
            .compactMap { $0.duration }
            .reduce(0, +)
        
        totalCalories = achievements
            .filter { $0.isUnlocked }
            .compactMap { $0.calories }
            .reduce(0, +)
        
        achievementsByType = Dictionary(
            grouping: achievements.filter { $0.isUnlocked },
            by: { $0.type }
        ).mapValues { $0.count }
        
        totalPoints = achievements.filter { $0.isUnlocked }.count * 50
        
        calculateMonthlyProgress(from: achievements)
    }
    
    private func calculateMonthlyProgress(from achievements: [MapAchievement]) {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: achievements.filter { $0.isUnlocked }) { achievement in
            let components = calendar.dateComponents([.year, .month], from: achievement.date)
            return calendar.date(from: components)!
        }
        
        monthlyProgress = grouped.map { date, achievements in
            MonthlyProgress(
                month: date,
                achievementsCount: achievements.count,
                distance: achievements.compactMap { $0.distance }.reduce(0, +),
                duration: achievements.compactMap { $0.duration }.reduce(0, +)
            )
        }.sorted { $0.month > $1.month }
    }
}

// MARK: - Statistics View
struct MapStatisticsView: View {
    @ObservedObject var viewModel: MapStatisticsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(.bgMain)
                    .resizable()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Main statistics
                        overallStatsSection
                        
                        // Progress by type
                        typeStatsSection
                        
                        // Monthly progress
                        monthlyProgressSection
                        
                        // Achievements
                        achievementsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Adventure Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom("Montserrat-Bold", size: 17))
                }
            }
        }
    }
    
    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("General Statistics")
                .font(.custom("Montserrat-Bold", size: 22))
                .foregroundColor(.blue)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCards(
                    title: "Distance",
                    value: String(format: "%.1f", viewModel.totalDistance),
                    unit: "km",
                    icon: "figure.walk",
                    color: .green
                )
                
                StatCards(
                    title: "Time",
                    value: viewModel.totalDurationFormatted,
                    unit: "activities",
                    icon: "clock.fill",
                    color: .blue
                )
                
                StatCards(
                    title: "Calories",
                    value: "\(viewModel.totalCalories)",
                    unit: "burned",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCards(
                    title: "Points",
                    value: "\(viewModel.totalPoints)",
                    unit: "scored",
                    icon: "star.fill",
                    color: .purple
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var typeStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress by Type")
                .font(.custom("Montserrat-Bold", size: 22))
                .foregroundColor(.blue)
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(AchievementType.allCases, id: \.self) { type in
                    TypeProgressCard(
                        type: type,
                        count: viewModel.achievementsByType[type] ?? 0
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var monthlyProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Progress")
                .font(.custom("Montserrat-Bold", size: 22))
                .foregroundColor(.blue)
            
            ForEach(viewModel.monthlyProgress.prefix(6)) { progress in
                MonthlyProgressRow(progress: progress)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.custom("Montserrat-Bold", size: 22))
                .foregroundColor(.blue)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Overall Progress:")
                        .font(.custom("Montserrat-Bold", size: 16))
                    Spacer()
                    Text("\(Int(viewModel.completionPercentage))%")
                        .font(.custom("Montserrat-Bold", size: 16))
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: viewModel.completionPercentage / 100)
                    .accentColor(.blue)
                
                Text("Unlocked \(viewModel.achievementsByType.values.reduce(0, +)) from \(AchievementType.allCases.count * 3) achievements")
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

// MARK: - Supporting Views and Models

struct MonthlyProgress: Identifiable {
    let id = UUID()
    let month: Date
    let achievementsCount: Int
    let distance: Double
    let duration: TimeInterval
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month)
    }
    
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return "\(hours)h \(minutes)m"
    }
}

struct StatBadge: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.custom("Montserrat-Bold", size: 14))
                .foregroundColor(.white)
            Text(title)
                .font(.custom("Montserrat-Bold", size: 10))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct StatCards: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.custom("Montserrat-Bold", size: 20))
                .fontWeight(.bold)
            
            Text(title)
                .font(.custom("Montserrat-Bold", size: 12))
                .foregroundColor(.primary)
            
            Text(unit)
                .font(.custom("Montserrat-Bold", size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct TypeProgressCard: View {
    let type: AchievementType
    let count: Int
    
    var body: some View {
        HStack {
            Image(systemName: type.icon)
                .font(.title3)
                .foregroundColor(.white)
                .padding(8)
                .background(type.color)
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(type.rawValue)
                    .font(.custom("Montserrat-Bold", size: 14))
                Text("\(count) achievements")
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct MonthlyProgressRow: View {
    let progress: MonthlyProgress
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(progress.monthName)
                    .font(.custom("Montserrat-Bold", size: 16))
                Text("\(progress.achievementsCount) achievements")                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(String(format: "%.1f", progress.distance)) km")
                    .font(.custom("Montserrat-Bold", size: 14))
                Text(progress.durationFormatted)
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}


// MARK: - Location Coordinator
class LocationCoordinator: NSObject, CLLocationManagerDelegate {
    var onLocationUpdate: ((CLLocation) -> Void)?
    
    init(onLocationUpdate: ((CLLocation) -> Void)? = nil) {
        self.onLocationUpdate = onLocationUpdate
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        onLocationUpdate?(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.startUpdatingLocation()
            case .denied, .restricted:
                print("Location access denied")
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            @unknown default:
                break
        }
    }
}

// MARK: - Achievement Models
// MARK: - Achievement Models
// MARK: - Achievement Models
struct MapAchievement: Identifiable {
    let id: Int
    let title: String
    let location: CLLocationCoordinate2D
    let type: AchievementType
    let date: Date
    let isUnlocked: Bool
    let distance: Double?
    let duration: TimeInterval?
    let calories: Int?
    
    var shareText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return "🗺️ I've reached: \(title)! Date: \(formatter.string(from: date))"    }
    
    init(id: Int, title: String, location: CLLocationCoordinate2D, type: AchievementType, date: Date, isUnlocked: Bool) {
        self.id = id
        self.title = title
        self.location = location
        self.type = type
        self.date = date
        self.isUnlocked = isUnlocked
        self.distance = nil
        self.duration = nil
        self.calories = nil
    }
    
    init(id: Int, title: String, location: CLLocationCoordinate2D, type: AchievementType, date: Date, isUnlocked: Bool, distance: Double?, duration: TimeInterval?, calories: Int?) {
        self.id = id
        self.title = title
        self.location = location
        self.type = type
        self.date = date
        self.isUnlocked = isUnlocked
        self.distance = distance
        self.duration = duration
        self.calories = calories
    }
}

enum AchievementType: String, CaseIterable {
    case hiking = "Hiking"
    case climbing = "Climbing"
    case exploration = "Exploration"
    case learning = "Learning"
    var icon: String {
        switch self {
            case .hiking: return "figure.hiking"
            case .climbing: return "mountain.2"
            case .exploration: return "binoculars.fill"
            case .learning: return "book.fill"
        }
    }
    
    var color: Color {
        switch self {
            case .hiking: return .green
            case .climbing: return .orange
            case .exploration: return .blue
            case .learning: return .purple
        }
    }
}

// MARK: - Achievement Marker
struct AchievementMarker: View {
    let achievement: MapAchievement
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.type.color : Color.gray)
                    .frame(width: isSelected ? 50 : 40, height: isSelected ? 50 : 40)
                
                Image(systemName: achievement.type.icon)
                    .font(.system(size: isSelected ? 20 : 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: achievement.type.color.opacity(0.6), radius: isSelected ? 8 : 4)
            
            if isSelected {
                Text(achievement.title)
                    .font(.custom("Montserrat-Bold", size: 12))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

// MARK: - Achievement Detail View
struct AchievementDetailView: View {
    let achievement: MapAchievement
    let onShare: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: achievement.type.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(achievement.type.color.gradient)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(achievement.title)
                        .font(.custom("Montserrat-Bold", size: 18))
                        .foregroundColor(.primary)
                    Text(achievement.type.rawValue)
                        .font(.custom("Montserrat-Bold", size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            
            Text("Achieved: \(formatDate(achievement.date))")
                .font(.custom("Montserrat-Bold", size: 12))
                .foregroundColor(.secondary)
            
            if achievement.isUnlocked, let distance = achievement.distance {
                HStack(spacing: 16) {
                    if let distance = achievement.distance {
                        StatInfo(title: "Distance", value: "\(String(format: "%.1f", distance)) km", icon: "figure.walk")
                    }
                    
                    if let duration = achievement.duration {
                        StatInfo(title: "Time", value: formatDuration(duration), icon: "clock.fill")
                    }
                    
                    if let calories = achievement.calories {
                        StatInfo(title: "Calories", value: "\(calories)", icon: "flame.fill")
                    }
                }
            }
            
            if !achievement.isUnlocked {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                    Text("This achievement is not yet unlocked")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .foregroundColor(.orange)
                }
            }
            
            // Achievement coordinates
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.blue)
                Text("W: \(String(format: "%.4f", achievement.location.latitude))")
                    .font(.custom("Montserrat-Bold", size: 10))
                Text("D: \(String(format: "%.4f", achievement.location.longitude))")
                    .font(.custom("Montserrat-Bold", size: 10))
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.horizontal)
        .shadow(radius: 10)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return "\(hours)h \(minutes)m"
    }
}

struct StatInfo: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
            Text(value)
                .font(.custom("Montserrat-Bold", size: 12))
                .foregroundColor(.primary)
            Text(title)
                .font(.custom("Montserrat-Bold", size: 10))
                .foregroundColor(.secondary)
        }
    }
}
// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: MapAchievement
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.isUnlocked ? achievement.type.icon : "lock.fill")
                .font(.title3)
                .foregroundColor(.white)
                .padding(12)
                .background(achievement.isUnlocked ? achievement.type.color.gradient : Color.gray.gradient)
                .clipShape(Circle())
            
            Text(achievement.title)
                .font(.custom("Montserrat-Bold", size: 10))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 60)
                .foregroundColor(.primary)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? achievement.type.color.opacity(0.3) : Color.clear)
                .stroke(isSelected ? achievement.type.color : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.1 : 1.0)
    }
}

// MARK: - Distance Calculator
extension CLLocationCoordinate2D {
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let toLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return fromLocation.distance(from: toLocation)
    }
}
extension Country {
    var achievements: [MapAchievement] {
        switch self {
            case .usa:
                return [
                    .init(id: 1, title: "First Trip", location: .init(latitude: 40.7128, longitude: -74.0060), type: .hiking, date: .now, isUnlocked: true, distance: 5.2, duration: 7200, calories: 420),
                    .init(id: 2, title: "Mountain Peak", location: .init(latitude: 40.7589, longitude: -73.9851), type: .climbing, date: .now.addingTimeInterval(-86400), isUnlocked: true, distance: 8.7, duration: 10800, calories: 680),
                    .init(id: 3, title: "Forest Lake", location: .init(latitude: 40.6892, longitude: -74.0445), type: .exploration, date: .now.addingTimeInterval(-172800), isUnlocked: false, distance: 3.1, duration: 5400, calories: 290),
                    .init(id: 4, title: "Training Route", location: .init(latitude: 40.7282, longitude: -74.0776), type: .learning, date: .now.addingTimeInterval(-259200), isUnlocked: true, distance: 2.5, duration: 3600, calories: 180)
                ]
            case .canada:
                return [
                    .init(id: 5, title: "Niagara Hike", location: .init(latitude: 43.0896, longitude: -79.0849), type: .hiking, date: .now, isUnlocked: true, distance: 4.5, duration: 3600, calories: 300),
                    .init(id: 6, title: "Rocky Ridge", location: .init(latitude: 51.0486, longitude: -114.0708), type: .climbing, date: .now, isUnlocked: false, distance: 9.1, duration: 9600, calories: 700)
                ]
            case .japan:
                return [
                    .init(id: 7, title: "Fuji Trail", location: .init(latitude: 35.3606, longitude: 138.7274), type: .hiking, date: .now, isUnlocked: true, distance: 10.0, duration: 14400, calories: 950),
                    .init(id: 8, title: "Kyoto Gardens", location: .init(latitude: 35.0116, longitude: 135.7681), type: .exploration, date: .now, isUnlocked: true, distance: 3.2, duration: 4200, calories: 250)
                ]
            case .france:
                return [
                    .init(id: 9, title: "Eiffel Climb", location: .init(latitude: 48.8584, longitude: 2.2945), type: .climbing, date: .now, isUnlocked: true, distance: 1.1, duration: 1800, calories: 180),
                    .init(id: 10, title: "Louvre Quest", location: .init(latitude: 48.8606, longitude: 2.3376), type: .learning, date: .now, isUnlocked: false, distance: 2.5, duration: 3600, calories: 200)
                ]
            case .india:
                return [
                    .init(id: 11, title: "Taj Expedition", location: .init(latitude: 27.1751, longitude: 78.0421), type: .exploration, date: .now, isUnlocked: true, distance: 6.2, duration: 7200, calories: 500),
                    .init(id: 12, title: "Himalaya Trek", location: .init(latitude: 27.9878, longitude: 86.9250), type: .climbing, date: .now, isUnlocked: false, distance: 12.0, duration: 21600, calories: 1200)
                ]
        }
    }
}
