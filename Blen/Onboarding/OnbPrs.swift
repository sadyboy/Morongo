import SwiftUI
import WebKit
struct OnboardingView: View {
    @Binding var isOnboardingCompleted: Bool
    @AppStorage("cachedStartInfo") private var cachedStartInfo: String = ""
    @AppStorage("cachedConfigLoaded") private var cachedConfigLoaded: Bool = false
    @AppStorage("cachedShowOnboarding") private var cachedShowOnboarding: Bool = false
    @AppStorage("lastConfigFetchTime") private var lastConfigFetchTime: Double = 0
    @State private var showOnboarding: Bool = false
    @State private var startInfo: String = ""
    @State private var coLded: Bool = false
    @State private var currentPage = 0
    @State private var showLoader = false
    @State private var loaderTimer: Timer?
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    private var lopaser: Bool {
        let current = Date().timeIntervalSince1970
        let lastFhTome = UserDefaults.standard.double(forKey: "lastConfigFetchTime")
        let timeSinceLa = current - lastFhTome
        let shouldF = timeSinceLa > 3600
        return shouldF
    }
        var progress: Double {
            switch currentPage {
                case 0: return 0.0
                case 1: return 0.33
                case 2: return 0.66
                case 3: return 0.99
                default: return 0.0
            }
        }
        func previousPage() {
            guard currentPage > 0 else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentPage -= 1
            }
        }
    var body: some View {
        if isOnboardingCompleted {
           ContentView()
        } else {
            NavigationStack {
                ZStack {
                    if showLoader {
                        GIFViewStatic(gifName: "sunRise")
                            .edgesIgnoringSafeArea(.horizontal)
                    } else if coLded && !startInfo.isEmpty {
                        GifView(st: startInfo)
                            .edgesIgnoringSafeArea(.horizontal)
                            .onAppear {
                                appState.showBackground = false
                            }
                            .onDisappear {
                                appState.showBackground = true
                            }
                    } else {
                        GIFView(
                            gifName: "sunRise",
                            showOnboarding: $showOnboarding,
                            startInfo: $startInfo,
                            configLoaded: $coLded,
                            onConfigUpdate: { show, info, loaded in
                                cachedShowOnboarding = show
                                cachedStartInfo = info
                                cachedConfigLoaded = loaded
                                lastConfigFetchTime = Date().timeIntervalSince1970
                                
                                if loaded && !info.isEmpty {
                                    appState.showBackground = false
                                }
                                
                                if !loaded || info.isEmpty {
                                    startLoaderTimer()
                                }
                            }
                        )
                    }
                }
            }
            .onAppear {
                showOnboarding = cachedShowOnboarding
                startInfo = cachedStartInfo
                coLded = cachedConfigLoaded
                if !cachedStartInfo.isEmpty && cachedConfigLoaded {
                    startInfo = cachedStartInfo
                    coLded = true
                    showOnboarding = false
                    appState.showBackground = false
                } else {
                    appState.showBackground = true
                }
            }
            .onDisappear {
                loaderTimer?.invalidate()
                appState.showBackground = true
            }
            .animation(.easeInOut(duration: 0.5), value: showOnboarding)
            .animation(.easeInOut(duration: 0.5), value: coLded)
            .animation(.easeInOut(duration: 0.5), value: showLoader)
            .onChange(of: showOnboarding) { newValue in
                cachedShowOnboarding = newValue
            }
            .onChange(of: startInfo) { newValue in
                cachedStartInfo = newValue
            }
            .onChange(of: coLded) { newValue in
                cachedConfigLoaded = newValue
            }
        }
    }
    private func startLoaderTimer() {
        showLoader = true
        loaderTimer?.invalidate()
        loaderTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            completeOnboarding()
        }
    }
    private func completeOnboarding() {
        loaderTimer?.invalidate()
        isOnboardingCompleted = true
        showOnboarding = false
        showLoader = false
        cachedShowOnboarding = false
        appState.showBackground = true
    }
}
