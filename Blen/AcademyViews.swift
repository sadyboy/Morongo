import SwiftUI


struct CustomSegmentedPicker: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<2, id: \.self) { index in
                tabButton(for: index)
            }
        }
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
        )
    }
    
    private func tabButton(for index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
            tabButtonContent(for: index)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func tabButtonContent(for index: Int) -> some View {
        VStack(spacing: 8) {
            tabTitle(for: index)
            
            if selectedTab == index {
                selectionIndicator
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(backgroundColor(for: index))
    }
    
    private func tabTitle(for index: Int) -> some View {
        Text(index == 0 ? "Courses" : "Quizzes")
            .font(.custom("Montserrat-Bold", size: 16))
            .foregroundColor(textColor(for: index))
    }
    
    private var selectionIndicator: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(height: 3)
            .cornerRadius(1.5)
    }
    
    private func backgroundColor(for index: Int) -> some View {
        Group {
            if selectedTab == index {
                Color.blue.cornerRadius(12)
            } else {
                Color.clear
            }
        }
    }
    
    private func textColor(for index: Int) -> Color {
        selectedTab == index ? .white : .primary
    }
}
struct AcademyView: View {
    @EnvironmentObject private var viewModel: AcademyViewModel
    @State private var showingProfile = false
    @StateObject private var userVM = UserViewModel()
    @State private var selectedTab = 0
    @State private var selectedCourse: Course? = nil
    var body: some View {
//        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Custom Tab Picker
                CustomSegmentedPicker(selectedTab: $selectedTab)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                if selectedTab == 0 {
                    // Courses View
                    VStack(spacing: 0) {
                        // Search Bar
                        searchBar
                        
                        // Category Filter
                        //                        categoryFilter
                        
                        // Course List
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredCourses) { course in
                                        CourseCardView(course: course, viewModel: viewModel)
                                            .onTapGesture {
                                                selectedCourse = course
                                            }
                                }
                            }
                            .padding()
                        }
                        .fullScreenCover(item: $selectedCourse) { course in
                            CourseDetailView(course: course)
                        }
                    }
                } else {
                    // Quizzes View
                    QuizListView()
                }
            }

//            .background(Color(UIColor.systemGroupedBackground))
//        }
        .environmentObject(viewModel)
    }
    
    // MARK: - Custom Segmented Picker
    
    
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
                    Text("Level \(viewModel.userProgress.level)")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color.clear)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search courses...", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil,
                    action: { viewModel.selectedCategory = nil }
                )
                
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

struct CourseCardView: View {
    let course: Course
    @ObservedObject var viewModel: AcademyViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            ZStack(alignment: .bottomLeading) {
                    Image(course.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .offset(y: 25)
//                        .clipped()
                
                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 100)
                
                VStack(alignment: .leading, spacing: 6) {
                    // Progress bar
                    ProgressView(value: progress)
                        .tint(.cyan)
                        .frame(maxWidth: 150)
                }
                .padding()
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(course.title)
                    .font(.custom("Montserrat-Bold", size: 18))
                    .foregroundColor(.black.opacity(0.7))
                    .lineLimit(1)
                Text(course.instructor)
                    .font(.custom("Montserrat-Regular", size: 14))
                    .foregroundColor(.brown.opacity(0.85))
                
                HStack {
                    DifficultyBadge(difficulty: course.difficulty)
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                        Text(String(format: "%.1f", course.rating))
                            .font(.custom("Montserrat-Bold", size: 12))
                            .foregroundColor(.black)
                        Text("(\(course.reviews))")
                            .foregroundColor(.black)
                            .font(.custom("Montserrat-Regular", size: 12))
                    }
                }
                
                HStack {
                    Label(course.duration, systemImage: "clock")
                        .font(.custom("Montserrat-Regular", size: 12))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text(course.Access)
                        .font(.custom("Montserrat-Bold", size: 14))
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
    private var progress: Double {
        viewModel.getCourseProgress(course)
    }
}


// MARK: - Course Detail View
struct CourseDetailView: View {
    let course: Course
    @EnvironmentObject var viewModel: AcademyViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color.blue.opacity(0.3)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Hero Image
                    courseHeader
                        .ignoresSafeArea(edges: .top)
                        .offset(y: -50)
                    VStack(alignment: .leading, spacing: 20) {
                        // Course Info
                        courseInfo
                        // Modules
                        modulesSection
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var courseHeader: some View {
        ZStack(alignment: .bottomLeading) {
            Image(course.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .clipped()
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 10,
                        bottomTrailingRadius: 10,
                        topTrailingRadius: 0
                    )
                )

            VStack(alignment: .leading, spacing: 8) {
                 Button {
                     dismiss.callAsFunction()
                 } label: {
                     Image(.backBtn)
                         .resizable()
                         .frame(width: 44, height: 44)
                     Spacer()
                 }
                 .offset(y: 35)
                Spacer()
                 .padding()
                Text(course.title)
                    .font(.custom("Montserrat-Bold", size: 28))
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                    .lineLimit(2)
                HStack(spacing: 12) {
                    DifficultyBadge(difficulty: course.difficulty)
                    
                    Label(course.instructor, systemImage: "person.fill")
                        .font(.custom("Montserrat-Bold", size: 15))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                HStack(spacing: 16) {
                    Label("\(String(format: "%.1f", course.rating)) (\(course.reviews))",
                          systemImage: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.custom("Montserrat-Bold", size: 14))
                    
                    Label(course.duration, systemImage: "clock.fill")
                        .foregroundColor(.white)
                        .font(.custom("Montserrat-Bold", size: 14))
                }
                
//                Text(course.Access)
//                    .font(.custom("Montserrat-Bold", size: 20))
//                    .foregroundColor(.cyan)
//                    .padding(.top, 4)
            }
            .padding()
        }
        .ignoresSafeArea(edges: .top)
    }

    
    private var courseInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About this Course")
                .foregroundColor(.white)
                .font(.custom("Montserrat-Bold", size: 22))
                .fontWeight(.bold)
            
            Text(course.description)
                .font(.custom("Montserrat-Bold", size: 17))
                .foregroundColor(.secondary)
            
            HStack {
                InfoCard(title: "Duration", value: course.duration, icon: "clock.fill")
                InfoCard(title: "Rating", value: String(format: "%.1f", course.rating), icon: "star.fill")
                InfoCard(title: "Access", value: course.Access, icon: "book.fill")
            }
            
            // Overall Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Course Progress")
                        .foregroundColor(.white)
                        .font(.custom("Montserrat-Bold", size: 17))
                    Spacer()
                    Text("\(Int(viewModel.getCourseProgress(course) * 100))%")
                        .font(.custom("Montserrat-Bold", size: 17))
                        .foregroundColor(course.category.color)
                }
                
                ProgressView(value: viewModel.getCourseProgress(course))
                    .tint(course.category.color)
            }
            .padding()
            .cornerRadius(12)
        }
    }
    
    private var modulesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Course Content")
                .font(.custom("Montserrat-Bold", size: 22))
                .foregroundColor(.white)
                .fontWeight(.bold)
            ForEach(course.modules) { module in
                ModuleView(module: module, course: course)
            }
        }
    }
}

// MARK: - Module View
struct ModuleView: View {
    let module: Course.Module
    let course: Course
    @EnvironmentObject var viewModel: AcademyViewModel
    @State private var isExpanded = false
    @State private var showHint = false
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(module.title)
                            .font(.custom("Montserrat-Bold", size: 17))
                        Text(module.description)
                            .font(.custom("Montserrat-Bold", size: 12))
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut, value: isExpanded)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(module.lessons) { lesson in
                        LessonRowView(lesson: lesson, course: course)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(.secondary)
                            .opacity(0.8)
                            .scaleEffect(1.2)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isExpanded)
                            .offset(y: -23)
                        Text("Tap a lesson to open it")
                            .font(.custom("Montserrat-Bold", size: 12))
                            .foregroundColor(.secondary)
                            .offset(y: -23)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
                }
                .padding(.leading)
                .transition(.opacity.combined(with: .slide))
                .animation(.easeInOut, value: isExpanded)
            }
        }
        
        .padding()
        .background(
            Image(.cellImg)
                .resizable()
                .scaledToFill()
        )
        .contentShape(Rectangle())
        .cornerRadius(12)
    }
}

// MARK: - Updated Lesson Row View
struct LessonRowView: View {
    let lesson: Course.Lesson
    let course: Course
    @EnvironmentObject var viewModel: AcademyViewModel
    
    @State private var showLesson = false
    
    var body: some View {
        HStack {
            Image(systemName: lesson.type.icon)
                .foregroundColor(viewModel.isLessonCompleted(lesson) ? .green : .blue)
            
            VStack(alignment: .leading) {
                Text(lesson.title)
                     .font(.custom("Montserrat-Bold", size: 17))
                    .foregroundColor(.primary)
                
                Text(lesson.description)
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if viewModel.isLessonCompleted(lesson) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                VStack(alignment: .trailing) {
                    Text("\(lesson.duration / 60) min")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "chevron.right")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) 
        .onTapGesture {
            showLesson = true
        }
        .sheet(isPresented: $showLesson) {
            LessonContentView(lesson: lesson)
                .presentationDetents([.medium, .large])
        }
    }
}

