import SwiftUI
class AppState: ObservableObject {
    @Published var showBackground: Bool = true
}

@main
struct BlenApp: App {
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var academyVM = AcademyViewModel()
    @StateObject private var appState = AppState() 
    @AppStorage("isOnboardingCompleted") private var isOnboardingCompleted = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isOnboardingCompleted {
                    ContentView()
                        .environmentObject(userViewModel)
                        .environmentObject(academyVM)
                        .environmentObject(appState)
                        .colorScheme(.light)
                        .environment(\.colorScheme, .light)
                } else {
                    ZStack {
                        if appState.showBackground {
                            Image(.bgMain)
                                .resizable()
                                .ignoresSafeArea()
                        }
                        OnboardingView(isOnboardingCompleted: $isOnboardingCompleted)
                            .environmentObject(appState)
                    }
                }
            }
            .colorScheme(.dark)
            .environment(\.colorScheme, .dark)
        }
    }
}
