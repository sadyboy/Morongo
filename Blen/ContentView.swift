import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @Namespace private var animation
    
    init() {
        let appearance = UITabBarAppearance()
         appearance.configureWithTransparentBackground()
         appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
         appearance.backgroundColor = UIColor.clear
         
         UITabBar.appearance().standardAppearance = appearance
         UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(.bgMain)
                .resizable()
                .ignoresSafeArea()
            
                    VStack(spacing: 24) {
//                        Group {
                            switch selectedTab {
                                   case 0: AdventureListView()
                                   case 1: AcademyView()
                                   case 2: TrackerView()
                                   case 3: ProfileView()
                                   case 4: AdventureMapView() 
                                   default: EmptyView()
                            }
//                        }
                        
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .animation(.easeInOut, value: selectedTab)
                     
                .navigationBarHidden(true)
                customTabBar
                    .frame(height: 0)
        }
//        .ignoresSafeArea(edges: .bottom)
    }

    
    // MARK: - Quick Actions
    private var quickActions: some View {
        HStack(spacing: 16) {
            quickActionCard(title: "Map", icon: "map.fill", color: .purple, tab: 4)
            quickActionCard(title: "Adventures", icon: "map.fill", color: .green, tab: 0)
            quickActionCard(title: "Academy", icon: "book.fill", color: .blue, tab: 1)
            quickActionCard(title: "Tracker", icon: "figure.walk", color: .orange, tab: 2)
        }
        .padding(.horizontal)
    }
    
    private func quickActionCard(title: String, icon: String, color: Color, tab: Int) -> some View {
        Button(action: { withAnimation { selectedTab = tab } }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.custom("Montserrat-Bold", size: 34))
                    .foregroundColor(.white)
                Text(title)
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(color.gradient)
            .cornerRadius(16)
            .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Custom TabBar
    private var customTabBar: some View {
        HStack {
            tabBarButton(icon: "map", tab: 4) 
            tabBarButton(icon: "academy", tab: 0)
            tabBarButton(icon: "course", tab: 1)
            tabBarButton(icon: "figure", tab: 2)
            tabBarButton(icon: "person", tab: 3)
        }
        .padding()
        .background(.ultraThinMaterial)
        .overlay {
            Capsule().stroke(Color.blue, lineWidth: 3)
        }
        .clipShape(Capsule())
        .shadow(radius: 10)
        .padding(.horizontal, 10)
        .padding(.bottom, 75)
    
    }
    
    private func tabBarButton(icon: String, tab: Int) -> some View {
        Button(action: { withAnimation { selectedTab = tab } }) {
            Image(icon)
                .resizable()
                .font(.system(size: 20, weight: .bold))
                .frame(width: 30, height: 35)
                .foregroundColor(selectedTab == tab ? .blue : .secondary)
                .padding()
                .background(
                    ZStack {
                        if selectedTab == tab {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .matchedGeometryEffect(id: "tab", in: animation)
                        }
                    }
                )
        }
    }
}


// MARK: - Profile View

struct CertificateCard: View {
    let certificate: Certificate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: certificate.relatedToQuiz ? "checkmark.circle.fill" : "book.fill")
                    .foregroundColor(certificate.relatedToQuiz ? .green : .blue)
                
                VStack(alignment: .leading) {
                    Text(certificate.courseTitle ?? "Unknown")
                        .font(.custom("Montserrat-Bold", size: 17))
                        .foregroundColor(.blue.opacity(0.6))
                    Text(certificate.relatedToQuiz ? "Quiz Certificate" : "Course Certificate")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(certificate.grade)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(gradeColor)
                    Text(certificate.issueDate, style: .date)
                        .font(.custom("Montserrat-Bold", size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            if certificate.relatedToQuiz, let score = certificate.score, let total = certificate.totalQuestions {
                Text("Score: \(score)/\(total) (\(Int(Double(score)/Double(total)*100))%)")
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            Image(.cell)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .cornerRadius(12)
        )
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var gradeColor: Color {
        switch certificate.grade {
        case "A": return .green
        case "B": return .blue
        case "C": return .orange
        case "D": return .red
        default: return .red
        }
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension Certificate {
    var shareText: String {
        "🎉 I completed the course! The certificate has been issued. \(issueDate.formatted(date: .long, time: .omitted)) с assessment: \(grade)"
    }
}
