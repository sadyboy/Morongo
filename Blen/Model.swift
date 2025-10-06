import Foundation
import CoreLocation
import UIKit
import SwiftUI
import MapKit

class TrackerDataService {
    private let userDefaultsKey = "userProgress"
    
    func loadUserProgress() -> UserProgress {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            return progress
        }
        return UserProgress(
            completedAdventures: [],
            favoriteAdventures: [],
            completedLessons: [],
            certificates: [],
            quizScores: [:],
            activities: [],
            goals: createDefaultGoals(),
            activeChallenges: [],
            completedChallenges: [],
            milestones: createDefaultMilestones(),
            totalPoints: 0,
            level: 1,
            achievements: [],
            weeklyStreak: 0,
            lastActivityDate: nil,
            totalDistance: 0,
            totalDuration: 0,
            totalCalories: 0,
            activityCount: [:]
        )
    }
    
    func saveUserProgress(_ progress: UserProgress) {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func createDefaultGoals() -> [Goal] {
        return [
            Goal(
                id: UUID(),
                type: .distance,
                target: 5.0,
                period: .daily,
                startDate: Date(),
                progress: 0,
                isCompleted: false
            ),
            Goal(
                id: UUID(),
                type: .duration,
                target: 30,
                period: .daily,
                startDate: Date(),
                progress: 0,
                isCompleted: false
            ),
            Goal(
                id: UUID(),
                type: .calories,
                target: 300,
                period: .daily,
                startDate: Date(),
                progress: 0,
                isCompleted: false
            )
        ]
    }
    
    private func createDefaultMilestones() -> [Milestone] {
        return [
            Milestone(
                id: UUID(),
                title: "Aspiring Traveler",
                description: "Walk 10 km",
                type: .totalDistance,
                threshold: 10,
                reward: 100,
                isAchieved: false,
                achievedDate: nil
            ),
            Milestone(
                id: UUID(),
                title: "Active researcher",
                description: "Spend 5 hours in activities",
                type: .totalDuration,
                threshold: 18000,
                reward: 150,
                isAchieved: false,
                achievedDate: nil
            ),
            Milestone(
                id: UUID(),
                title: "Master of Rock Climbing",
                description: "Complete 10 climbing activities",
                type: .specificActivity,
                threshold: 10,
                reward: 200,
                isAchieved: false,
                achievedDate: nil
            )
        ]
    }
    
    func loadActiveChallenges() -> [Challenge] {
        return [
            Challenge(
                id: UUID(),
                title: "Spring Marathon",
                description: "Run 42 km in a month",
                type: .distance,
                target: 42,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
                reward: 500,
                participants: [],
                leaderboard: []
            ),
            Challenge(
                id: UUID(),
                title: "Altitude Challenge",
                description: "Gain 1000 m in elevation in a week",
                type: .elevation,
                target: 1000,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!,
                reward: 300,
                participants: [],
                leaderboard: []
            )
        ]
    }
}



// MARK: - Views

import SwiftUI
import MapKit

// Main List View
struct AdventureListView: View {
    @StateObject private var viewModel = AdventureListViewModel()
    @State private var showingProfile = false
    @StateObject private var userVM =  UserViewModel()
    @State private var selectedAdventure: Adventure? = nil
    var body: some View {
//        NavigationView {
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Search Bar
                    searchBar
                    
                    // Category Filter
                    categoryFilter
                    
                    // Adventures List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredAdventures) { adventure in
                                AdventureCardView(
                                    adventure: adventure,
                                    isFavorite: viewModel.userProgress.favoriteAdventures.contains(adventure.id),
                                    onFavoriteToggle: { viewModel.toggleFavorite(adventure: adventure) }
                                )
                                .onTapGesture {
                                    selectedAdventure = adventure
                                }
                            }
                        }
                        .padding()
                    }
                    .fullScreenCover(item: $selectedAdventure) { adventure in
                        AdventureDetailView(adventure: adventure)
                    }
                }
   
            .navigationBarHidden(true)
//            .background(Color(UIColor.systemGroupedBackground))
//        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Journey")
                    .font(.custom("Montserrat-Bold", size: 34))
                    .fontWeight(.bold)
                Text(userVM.username)
                    .font(.custom("Montserrat-Bold", size: 22))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: { showingProfile = true }) {
                VStack {
                    if let image = userVM.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .padding()
//        .background(Color(UIColor.systemBackground))
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search adventures...", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
             
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All Adventures
                FilterChip(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil,
                    action: { viewModel.selectedCategory = nil }
                )
                
                // Category filters
                ForEach(Adventure.AdventureCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: viewModel.selectedCategory == category,
                        color: category.color,
                        action: {
                            viewModel.selectedCategory = viewModel.selectedCategory == category ? nil : category
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

// Adventure Card Component
struct AdventureCardView: View {
    let adventure: Adventure
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Image(adventure.category.icon)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .offset(y: 30)
//                    .clipped()
                    .overlay(
                        VStack {
                            Spacer()
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        }
                    )
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(adventure.title)
                                        .font(.custom("Montserrat-Bold", size: 18))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    Text(adventure.location)
                                        .font(.custom("Montserrat-Regular", size: 14))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                            .padding()
                        },
                        alignment: .bottomLeading
                    )
                
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    DifficultyBadge(difficulty: adventure.difficulty)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                        Text(String(format: "%.1f", adventure.rating))
                            .font(.custom("Montserrat-Bold", size: 12))
                        Text("(\(adventure.reviews))")
                            .foregroundColor(.secondary)
                            .font(.custom("Montserrat-Regular", size: 12))
                    }
                }
                
                Text(adventure.description)
                    .font(.custom("Montserrat-Regular", size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label(adventure.duration, systemImage: "clock")
                        .font(.custom("Montserrat-Regular", size: 12))
                    
                    if let distance = adventure.distance {
                        Label("\(String(format: "%.1f", distance)) mi", systemImage: "location")
                            .font(.custom("Montserrat-Regular", size: 12))
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBlue))
        }
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// Helper Components
struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    var color: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.custom("Montserrat-Bold", size: 12))
                }
                Text(title)
                     .font(.custom("Montserrat-Bold", size: 17))
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color(color) : Color.white)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: Adventure.Difficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.custom("Montserrat-Bold", size: 12))
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(difficulty.color))
            .foregroundColor(.black)
            .overlay(content: {
                RoundedRectangle(cornerRadius: 8).stroke(Color.blue.opacity(0.5), lineWidth: 2)
            })
            .cornerRadius(8)
    }
}

extension Color {
    init(_ uiColor: UIColor) {
        self.init(red: 2222,
                  green: 222,
                  blue: 333)
    }
}

extension UIColor {
    func withAlphaComponent(_ alpha: CGFloat) -> Color {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color(red: Double(r), green: Double(g), blue: Double(b)).opacity(Double(alpha))
    }
}
