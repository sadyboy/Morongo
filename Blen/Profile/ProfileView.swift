import Foundation
import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var dataService = DataService.shared
    @StateObject private var userVM = UserViewModel()
    @State private var showingImagePicker = false
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    ZStack(alignment: .bottomTrailing) {
                        if let image = userVM.profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                        }
                        
                        Menu {
                            Button("Select a photo") { showingImagePicker = true }
                            if userVM.profileImage != nil {
                                Button("Delete photo", role: .destructive) {
                                    userVM.profileImage = nil
                                }
                            }
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                                .background(Color.white, in: Circle())
                        }
                        .offset(x: -4, y: -4)
                    }
                    
                    VStack(alignment: .leading) {
                        TextField("Enter your name", text: $userVM.username)
                            .font(.custom("Montserrat-Bold", size: 22))
                            .fontWeight(.bold)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 200)

                        Text("Level \(dataService.userProgress.level)")
                             .font(.custom("Montserrat-Bold", size: 17))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("\(dataService.userProgress.totalPoints)")
                            .font(.custom("Montserrat-Bold", size: 22))
                            .fontWeight(.bold)
                        Text("Points")
                            .font(.custom("Montserrat-Bold", size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                    StatCard(title: "Adventures", value: "\(dataService.userProgress.completedAdventures.count)", icon: "figure.hiking")
                    StatCard(title: "Courses", value: "\(dataService.userProgress.certificates.filter { !$0.relatedToQuiz }.count)", icon: "book.fill")
                    StatCard(title: "Quizzes", value: "\(dataService.userProgress.quizScores.count)", icon: "checkmark.circle.fill")
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Certificates")
                        .font(.custom("Montserrat-Bold", size: 22))
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if dataService.userProgress.certificates.isEmpty {
                        Text("No certificates yet. Complete courses and quizzes to earn certificates!")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(dataService.userProgress.certificates) { certificate in
                            CertificateCard(certificate: certificate)
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .photosPicker(isPresented: $showingImagePicker,
                      selection: $selectedPhoto,
                      matching: .images)
        .onChange(of: selectedPhoto) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    userVM.profileImage = uiImage
                }
            }
        }
    }
}

