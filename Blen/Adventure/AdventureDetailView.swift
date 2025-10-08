import Foundation
import SwiftUI
import Combine


// Adventure Detail View
struct AdventureDetailView: View {
    let adventure: Adventure
    @StateObject private var viewModel: AdventureDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    init(adventure: Adventure) {
        self.adventure = adventure
        self._viewModel = StateObject(wrappedValue: AdventureDetailViewModel(adventure: adventure))
    }
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.3)
                .ignoresSafeArea()
            VStack {
                HStack {
                    Button {
                        dismiss.callAsFunction()
                    } label: {
                        Image(.backBtn)
                            .resizable()
                            .frame(width: 44, height: 44)
                        Spacer()
                    }
                }
                .padding(.horizontal)
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // --- HEADER ---
                        ZStack(alignment: .bottomLeading) {
                            Image(adventure.category.icon)
                                .resizable()
                                .scaledToFill()
                                .offset(y: 25)
                                .frame(height: 300)
                                .clipped()
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.black.opacity(0.6), .clear]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(adventure.title)
                                    .font(.custom("Montserrat-Bold", size: 34))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(radius: 4)
                                
                                HStack {
                                    DifficultyBadge(difficulty: adventure.difficulty)
                                    
                                    Label(adventure.location, systemImage: "location.fill")
                                        .font(.custom("Montserrat-Bold", size: 17))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                            .padding()
                        }
                        .ignoresSafeArea(edges: .top)
                        
                        // --- INFO BLOCKS ---
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 20) {
                                InfoCard(title: "Duration", value: adventure.duration, icon: "clock.fill")
                                if let distance = adventure.distance {
                                    InfoCard(title: "Distance", value: "\(String(format: "%.1f", distance)) mi", icon: "location.fill")
                                }
                                InfoCard(title: "access", value: "Free", icon: "book.fill")
                            }
                            
                            // Description
                            VStack(alignment: .leading, spacing: 8) {
                                Text("About")
                                    .font(.custom("Montserrat-Bold", size: 22)).bold()
                                Text(adventure.description)
                                    .font(.custom("Montserrat-Bold", size: 17))
                                    .foregroundColor(.secondary)
                            }
                            
                            // Best Season
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Best Season")
                                    .font(.custom("Montserrat-Bold", size: 22)).bold()
                                Text(adventure.bestSeason)
                                    .font(.custom("Montserrat-Bold", size: 17))
                                    .foregroundColor(.secondary)
                            }
                            
                            // Tips
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Pro Tips")
                                    .font(.custom("Montserrat-Bold", size: 22)).bold()
                                ForEach(adventure.tips, id: \.self) { tip in
                                    HStack(alignment: .top) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text(tip)
                                            .font(.custom("Montserrat-Bold", size: 17))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            // Equipment
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Required Equipment")
                                    .font(.custom("Montserrat-Bold", size: 22)).bold()
                                ForEach(adventure.equipment, id: \.self) { item in
                                    HStack {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 6))
                                            .foregroundColor(.secondary)
                                        Text(item)
                                            .font(.custom("Montserrat-Bold", size: 17))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            // --- ACTION BUTTONS ---
                            VStack(spacing: 12) {
                                Button(action: viewModel.openInMaps) {
                                    HStack {
                                        Image(systemName: "map.fill")
                                        Text("Open in Maps")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                if !viewModel.isCompleted {
                                    Button(action: viewModel.markAsCompleted) {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                            Text("Mark as Completed")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: viewModel.toggleFavorite) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isFavorite ? .red : .primary)
                }
            }
        }
    }
}
