import SwiftUI
import MapKit


struct TrackerMapView: UIViewRepresentable {
    var route: [SportActivity.LocationPoint]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = context.coordinator  
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        
        let coordinates = route.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        guard coordinates.count > 1 else { return }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        
        let rect = polyline.boundingMapRect
        let edgeInset = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
        mapView.setVisibleMapRect(rect, edgePadding: edgeInset, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}



// MARK: - Main Tracker View
struct TrackerView: View {
    @StateObject private var viewModel = TrackerViewModel()
    @State private var showingNewGoal = false
    @State private var showingChallenges = false
    @State private var selectedPeriod: Goal.Period = .daily
    @State private var selectedActivity: SportActivity? = nil
    var body: some View {
        //        NavigationView {
        ZStack {
            Image(.bgMain)
                .resizable()
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    // Activity Tracking Section
                    if viewModel.isTracking {
                        activeTrackingView
                    } else {
                        startTrackingView
                    }
                    // Stats Section
                    statsSection
                    // Goals Section
                    goalsSection
                    // Challenges Section
                    challengesSection
                    // Recent Activities
                    recentActivitiesSection
                }
                .padding()
            }
            .navigationTitle("Sports Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewGoal = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewGoal) {
                NewGoalView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingChallenges) {
                ChallengesView(viewModel: viewModel)
            }
        }
    }

    
     private var activeTrackingView: some View {
        VStack(spacing: 16) {
            if let activity = viewModel.currentActivity {
                // Activity Type and Duration
                HStack {
                    Label(activity.type.rawValue, systemImage: activity.type.icon)
                        .font(.custom("Montserrat-Bold", size: 17))
                    Spacer()
                    Text(formatDuration(activity.duration))
                        .font(.custom("Montserrat-Bold", size: 22))
                        .monospacedDigit()
                }
                
                // Stats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatBox(title: "Distance",
                            value: String(format: "%.2f", activity.distance ?? 0),
                            unit: "km",
                            icon: "figure.walk")

                    StatBox(title: "Steps",
                            value: "\(activity.steps ?? viewModel.steps)",
                            unit: "steps",
                            icon: "shoeprints.fill")

                    StatBox(title: "Pace",
                            value: calculatePace(distance: activity.distance, duration: activity.duration),
                            unit: "min/km",
                            icon: "speedometer")

                    StatBox(title: "Calories",
                            value: "\(activity.calories)",
                            unit: "kcal",
                            icon: "flame.fill")
                }
                
                // Heart Rate
                if let heartRate = activity.heartRate {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(heartRate.average) bpm")
                            .font(.custom("Montserrat-Bold", size: 17))
                    }
                }
                
                TrackerMapView(route: viewModel.routeLocations)
                    .frame(height: 250)
                    .cornerRadius(12)
                
                // Control Buttons
                HStack(spacing: 30) {
                    Button(action: { viewModel.pauseActivity() }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.orange)
                    }
                    
                    Button(action: { viewModel.stopActivity() }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
//        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }

    
    private var startTrackingView: some View {
        VStack(spacing: 16) {
            // Activity Type Picker
            Picker("Activity Type", selection: $viewModel.selectedActivityType) {
                ForEach(SportActivity.ActivityType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            // Difficulty Picker
            Picker("Difficulty", selection: $viewModel.selectedDifficulty) {
                ForEach(Adventure.Difficulty.allCases, id: \.self) { difficulty in
                    Text(difficulty.rawValue)
                        .tag(difficulty)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Start Button
            Button(action: { viewModel.startActivity() }) {
                Label("Start Activity", systemImage: "play.circle.fill")
                    .font(.custom("Montserrat-Bold", size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(
            Image(.bgCell)
                .resizable()
        )
        .cornerRadius(16)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Statistics").foregroundColor(.blue)
                    .font(.custom("Montserrat-Bold", size: 22))
                    .fontWeight(.bold)
                
                Spacer()
                
                Picker("Period", selection: $selectedPeriod) {
                    Text("Daily").tag(Goal.Period.daily)
                    Text("Weekly").tag(Goal.Period.weekly)
                    Text("Monthly").tag(Goal.Period.monthly)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            let stats = viewModel.getStats(for: selectedPeriod)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatBox(
                    title: "Distance",
                    value: String(format: "%.1f", stats.totalDistance),
                    unit: "km",
                    icon: "figure.walk"
                )
                
                StatBox(
                    title: "Duration",
                    value: formatDuration(stats.totalDuration),
                    unit: "",
                    icon: "clock.fill"
                )
                
                StatBox(
                    title: "Calories",
                    value: "\(stats.totalCalories)",
                    unit: "kcal",
                    icon: "flame.fill"
                )
            }
        }
        .padding()
        .background(
            Image(.bgCell)
                .resizable()
        )
        .cornerRadius(16)
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goals")
                .font(.custom("Montserrat-Bold", size: 22))
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            ForEach(viewModel.userProgress.goals) { goal in
                GoalCard(goal: goal)
            }
        }
        .padding()
        .background(Image("otherBg")
            .resizable()
        )
        .cornerRadius(16)
    }
    
    private var challengesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Active Challenges")
                    .font(.custom("Montserrat-Bold", size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
                
                Button("See All") {
                    showingChallenges = true
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.userProgress.activeChallenges) { challenge in
                        ChallengeCard(challenge: challenge, currentUserId: viewModel.currentUserId)
                    }
                }
            }
        }
        .padding()
        .background(Image(.cellImg).resizable())
        .cornerRadius(16)
    }
    
    private var recentActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activities")
                .font(.custom("Montserrat-Bold", size: 22))
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .offset(y: -20)
            
            List {
                ForEach(viewModel.userProgress.activities.prefix(5)) { activity in
                    ActivityRow(activity: activity)
                        .onTapGesture {
                            selectedActivity = activity
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let activity = viewModel.userProgress.activities[index]
                        viewModel.deleteActivity(activity)
                    }
                }
                .listRowBackground(Color.clear)
            }
            .frame(height: 200)
        }
       
        .fullScreenCover(item: $selectedActivity) { activity in
                   ActivityDetailView(activity: activity)
               }
        .scrollContentBackground(.hidden)
        .padding()
        .background(
            Image("otherBg")
                .resizable()
        )
        .cornerRadius(16)
    }

    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func calculatePace(distance: Double?, duration: TimeInterval) -> String {
        guard let distance = distance, distance > 0 else { return "--:--" }
        
        let paceSeconds = duration / (distance * 60)
        let minutes = Int(paceSeconds)
        let seconds = Int((paceSeconds - Double(minutes)) * 60)
        
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Helper Views

struct StatBox: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.custom("Montserrat-Bold", size: 22))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .monospacedDigit()
            
            Text(unit)
                .font(.custom("Montserrat-Bold", size: 12))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.custom("Montserrat-Bold", size: 12))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.5))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 2)
        })
        .cornerRadius(12)
    }
}

struct GoalCard: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: goal.type.icon)
                    .foregroundColor(.blue)
                Text("\(goal.target, specifier: "%.1f") \(goal.type.unit)")
                    .font(.custom("Montserrat-Bold", size: 17))
                Spacer()
                Text(goal.period.rawValue)
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: goal.progress, total: goal.target)
                .accentColor(goal.isCompleted ? .green : .blue)
            
            Text("\(Int(goal.progress * 100 / goal.target))% completed")
                .font(.custom("Montserrat-Bold", size: 12))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 2)
        })
        .cornerRadius(12)
    }
}

 struct ChallengeCard: View {
    let challenge: Challenge
    let currentUserId: UUID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(challenge.title)
                .font(.custom("Montserrat-Bold", size: 17))
            
            Text(challenge.description)
                 .font(.custom("Montserrat-Bold", size: 17))
                .foregroundColor(.secondary)
            
            if let entry = challenge.leaderboard.first(where: { $0.userId == currentUserId }) {
                ProgressView(value: entry.progress, total: challenge.target)
                
                HStack {
                    Text("\(Int((entry.progress / challenge.target) * 100))%")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Rank: \(entry.rank)/\(challenge.participants.count)")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                Text("\(challenge.reward) points")
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(minWidth: 250, maxWidth: 320)
        .background(
            Image(.cellImg)
                .resizable()
        )
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}


struct ActivityRow: View {
    let activity: SportActivity
    
    var body: some View {
        HStack {
            Image(systemName: activity.type.icon)
                .font(.custom("Montserrat-Bold", size: 22))
                .foregroundColor(activity.type.color)
                .frame(width: 44, height: 44)
                .background(activity.type.color.opacity(0.2))
                .cornerRadius(22)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.type.rawValue)
                    .font(.custom("Montserrat-Bold", size: 17))
                    .foregroundColor(.black)
                
                Text(activity.startTime, style: .date)
                    .font(.custom("Montserrat-Bold", size: 12))
              
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let distance = activity.distance {
                    Text(String(format: "%.1f km", distance))
                         .font(.custom("Montserrat-Bold", size: 17))
                         .foregroundColor(.blue)
                }
                
                Text(formatDuration(activity.duration))
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            Image(.cellImg)
                .resizable()
        )
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

import SwiftUI
import MapKit

struct ActivityDetailView: View {
    let activity: SportActivity
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Image(.bgMain)
                .resizable()
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    Button {
                        dismiss.callAsFunction()
                    } label: {
                        Image(.backBtn)
                            .resizable()
                            .frame(width: 44, height: 44)
                        Spacer()
                    }
                    .padding()
                    ActivityRow(activity: activity)
                    
                    Divider()
                    
                    if let route = activity.route, !route.isEmpty {
                        RouteMapOverlay(route: route)
                            .frame(height: 300)
                            .cornerRadius(12)
                    } else {
                        Text("No route data available")
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    if let steps = activity.steps {
                        HStack {
                            Image(systemName: "shoeprints.fill")
                                .foregroundColor(.blue)
                            Text("\(steps) steps")
                                .font(.custom("Montserrat-Bold", size: 17))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Activity Details")
    }
}

import MapKit



struct RouteMapOverlay: UIViewRepresentable {
    let route: [SportActivity.LocationPoint]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        updateRoute(on: mapView)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)
        updateRoute(on: uiView)
    }

    private func updateRoute(on mapView: MKMapView) {
        let coords = route.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
        guard !coords.isEmpty else { return }

        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        mapView.addOverlay(polyline)

        if let first = coords.first {
            let startPin = MKPointAnnotation()
            startPin.coordinate = first
            startPin.title = "Start"
            mapView.addAnnotation(startPin)
        }

        if let last = coords.last {
            let endPin = MKPointAnnotation()
            endPin.coordinate = last
            endPin.title = "Finish"
            mapView.addAnnotation(endPin)
        }

        mapView.setVisibleMapRect(
            polyline.boundingMapRect,
            edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40),
            animated: true
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            if annotation.title == "Start" {
                view.markerTintColor = .green
            } else if annotation.title == "Finish" {
                view.markerTintColor = .red
            }
            return view
        }
    }
}




// MARK: - New Goal View
struct NewGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TrackerViewModel
    
    @State private var selectedType: Goal.GoalType = .distance
    @State private var selectedPeriod: Goal.Period = .daily
    @State private var target: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Type")) {
                    Picker("Type", selection: $selectedType) {
                        Text("Distance").tag(Goal.GoalType.distance)
                        Text("Duration").tag(Goal.GoalType.duration)
                        Text("Calories").tag(Goal.GoalType.calories)
                        Text("Frequency").tag(Goal.GoalType.frequency)
                    }
                }
                
                Section(header: Text("Period")) {
                    Picker("Period", selection: $selectedPeriod) {
                        Text("Daily").tag(Goal.Period.daily)
                        Text("Weekly").tag(Goal.Period.weekly)
                        Text("Monthly").tag(Goal.Period.monthly)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Target")) {
                    TextField("Enter target", text: $target)
                        .keyboardType(.decimalPad)
                    
                    Text("Unit: \(selectedType.unit)")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveGoal()
                }
                .disabled(target.isEmpty)
            )
        }
    }
    
    private func saveGoal() {
        guard let targetValue = Double(target) else { return }
        
        let goal = Goal(
            id: UUID(),
            type: selectedType,
            target: targetValue,
            period: selectedPeriod,
            startDate: Date(),
            progress: 0,
            isCompleted: false
        )
        
        viewModel.addGoal(goal)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Challenges View
struct ChallengesView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TrackerViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Active Challenges")) {
                    ForEach(viewModel.userProgress.activeChallenges) { challenge in
                        ChallengeRow(challenge: challenge)
                    }
                }
                
                Section(header: Text("Available Challenges")) {
                    ForEach(viewModel.userProgress.activeChallenges) { challenge in
                        ChallengeRow(challenge: challenge)
                            .swipeActions {
                                Button("Join") {
                                    viewModel.joinChallenge(challenge)
                                }
                                .tint(.green)
                            }
                    }
                }
                
                Section(header: Text("Completed Challenges")) {
                    ForEach(viewModel.userProgress.completedChallenges) { challenge in
                        ChallengeRow(challenge: challenge)
                    }
                }
            }
            .navigationTitle("Challenges")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ChallengeRow: View {
    let challenge: Challenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(challenge.title)
                .font(.custom("Montserrat-Bold", size: 17))
            
            Text(challenge.description)
                 .font(.custom("Montserrat-Bold", size: 17))
                .foregroundColor(.secondary)
            
            if let userEntry = challenge.leaderboard.first {
                ProgressView(value: userEntry.progress, total: challenge.target)
                
                HStack {
                    Text("\(Int(userEntry.progress * 100 / challenge.target))%")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Rank: \(userEntry.rank)/\(challenge.participants.count)")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

