import SwiftUI

struct QuizListView: View {
    @EnvironmentObject var viewModel: AcademyViewModel
    @State private var selectedCategory: Quiz.QuizCategory?
    @State private var selectedDifficulty: Adventure.Difficulty?
    @State private var searchText = ""
    @State private var quizCategory: Quiz? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Search and Filters
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search quizzes...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(Quiz.QuizCategory.allCases, id: \.self) { category in
                                FilterChip(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category,
                                    color: category.color,
                                    action: {
                                        selectedCategory = selectedCategory == category ? nil : category
                                    }
                                )
                            }
                        }
                    }
                    
                    // Difficulty Filter
                    HStack {
                        ForEach(Adventure.Difficulty.allCases, id: \.self) { difficulty in
                            Button(action: {
                                selectedDifficulty = selectedDifficulty == difficulty ? nil : difficulty
                            }) {
                                Text(difficulty.rawValue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedDifficulty == difficulty ? Color(difficulty.color) : Color.secondary)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                .background(
                    Image(.cellImg)
                        .resizable()
                )
                .cornerRadius(16)
                
                // Quiz List
                LazyVStack(spacing: 16) {
                    ForEach(filteredQuizzes) { quiz in
//                        NavigationLink(destination: QuizDetailView(quiz: quiz)) {
                            QuizCard(quiz: quiz)
                            .onTapGesture {
                                quizCategory = quiz
                            }
//                        }
//                        .buttonStyle(PlainButtonStyle())
                    }
                    
                }
                .fullScreenCover(item: $quizCategory) { quizCategory in
                    QuizDetailView(quiz: quizCategory)
                }
            }
            .padding()
        }
        .navigationTitle("Knowledge Quizzes")
    }
    
    private var filteredQuizzes: [Quiz] {
        viewModel.quizzes.filter { quiz in
            var matches = true
            
            if let category = selectedCategory {
                matches = matches && quiz.category == category
            }
            
            if let difficulty = selectedDifficulty {
                matches = matches && quiz.difficulty == difficulty
            }
            
            if !searchText.isEmpty {
                matches = matches && (
                    quiz.title.lowercased().contains(searchText.lowercased()) ||
                    quiz.description.lowercased().contains(searchText.lowercased())
                )
            }
            
            return matches
        }
    }
}

struct QuizCard: View {
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: quiz.category.icon)
                    .font(.custom("Montserrat-Bold", size: 22))
                    .foregroundColor(quiz.category.color)
                
                Text(quiz.title)
                    .font(.custom("Montserrat-Bold", size: 17))
                
                Spacer()
                
                if let score = quiz.userScore {
                    Text("\(score)/\(quiz.questions.count)")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .padding(6)
                        .background(quiz.isPassed ? Color.green : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            Text(quiz.description)
               .font(.custom("Montserrat-Bold", size: 15))
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                // Category
                Label(quiz.category.rawValue, systemImage: quiz.category.icon)
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Difficulty
                DifficultyBadge(difficulty: quiz.difficulty)
            }
            
            if let completionDate = quiz.completionDate {
                Text("Completed: \(completionDate, style: .date)")
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            Image(.cellImg)
                .resizable()
        )
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

 struct QuizDetailView: View {
    let quiz: Quiz
    @EnvironmentObject var viewModel: AcademyViewModel
    @State private var showingQuiz = false
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
                     .padding(.horizontal)
                     // Header
                     VStack(spacing: 12) {
                         Image(systemName: quiz.category.icon)
                             .font(.system(size: 60))
                             .foregroundColor(quiz.category.color)
                         
                         Text(quiz.title)
                             .font(.title)
                             .fontWeight(.bold)
                             .multilineTextAlignment(.center)
                         
                         Text(quiz.description)
                             .font(.custom("Montserrat-Bold", size: 17))
                             .foregroundColor(.secondary)
                             .multilineTextAlignment(.center)
                     }
                     .padding()
                     
                     // Info Cards
                     HStack(spacing: 16) {
                         InfoCard(
                            title: "Questions",
                            value: "\(quiz.questions.count)",
                            icon: "list.bullet"
                         )
                         
                         InfoCard(
                            title: "Required Score",
                            value: "\(quiz.requiredScore)%",
                            icon: "checkmark.circle"
                         )
                         
                         if let score = quiz.userScore {
                             InfoCard(
                                title: "Your Score",
                                value: "\(score)/\(quiz.questions.count)",
                                icon: "star.fill"
                             )
                         }
                     }
                     .padding(.horizontal)
                     
                     // Category and Difficulty
                     HStack {
                         VStack(alignment: .leading) {
                             Text("Category")
                                 .font(.custom("Montserrat-Bold", size: 12))
                                 .foregroundColor(.secondary)
                             Label(quiz.category.rawValue, systemImage: quiz.category.icon)
                                 .font(.custom("Montserrat-Bold", size: 17))
                         }
                         
                         Spacer()
                         
                         VStack(alignment: .trailing) {
                             Text("Difficulty")
                                 .font(.custom("Montserrat-Bold", size: 12))
                                 .foregroundColor(.secondary)
                             DifficultyBadge(difficulty: quiz.difficulty)
                         }
                     }
                     .padding()
                     .background(
                        Image(.cellImg)
                            .resizable()
                     )
                     .cornerRadius(12)
                     .padding(.horizontal)
                     
                     // Related Content
                     if quiz.relatedCourseId != nil || quiz.relatedAdventureId != nil {
                         VStack(alignment: .leading, spacing: 12) {
                             Text("Related Content")
                                 .font(.custom("Montserrat-Bold", size: 17))
                             
                             if let courseId = quiz.relatedCourseId,
                                let course = viewModel.courses.first(where: { $0.id == courseId }) {
                                 NavigationLink(destination: CourseDetailView(course: course)) {
                                     HStack {
                                         Image(systemName: "book.fill")
                                             .foregroundColor(.blue)
                                         Text(course.title)
                                             .foregroundColor(.primary)
                                         Spacer()
                                         Image(systemName: "chevron.right")
                                             .foregroundColor(.secondary)
                                     }
                                     .padding()
                                     .background(Color(UIColor.systemBackground))
                                     .cornerRadius(8)
                                 }
                                 .buttonStyle(PlainButtonStyle())
                             }
                             
                             if let adventureId = quiz.relatedAdventureId,
                                let adventure = viewModel.adventures.first(where: { $0.id == adventureId }) {
                                 NavigationLink(destination: AdventureDetailView(adventure: adventure)) {
                                     HStack {
                                         Image(systemName: "map.fill")
                                             .foregroundColor(.green)
                                         Text(adventure.title)
                                             .foregroundColor(.primary)
                                         Spacer()
                                         Image(systemName: "chevron.right")
                                             .foregroundColor(.secondary)
                                     }
                                     .padding()
                                     .background(Color(UIColor.systemBackground))
                                     .cornerRadius(8)
                                 }
                                 .buttonStyle(PlainButtonStyle())
                             }
                         }
                         .padding()
                         .background(Color(UIColor.secondarySystemBackground))
                         .cornerRadius(12)
                         .padding(.horizontal)
                     }
                     
                     // Start/Results Button
                     Button(action: { showingQuiz = true }) {
                         HStack {
                             Image(systemName: quiz.userScore == nil ? "play.fill" : "arrow.clockwise")
                             Text(quiz.userScore == nil ? "Start Quiz" : "Retake Quiz")
                         }
                         .frame(maxWidth: .infinity)
                         .padding()
                         .background(quiz.category.color)
                         .foregroundColor(.white)
                         .overlay(content: {
                             RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 2)
                         })
                         .cornerRadius(12)
                     }
                     .padding(.horizontal)
                     
                     if let userScore = quiz.userScore, let completionDate = quiz.completionDate {
                         VStack(spacing: 12) {
                             Text("Previous Attempt")
                                 .font(.custom("Montserrat-Bold", size: 17))
                             
                             HStack {
                                 VStack(alignment: .leading) {
                                     Text("Score")
                                         .font(.custom("Montserrat-Bold", size: 12))
                                         .foregroundColor(.secondary)
                                     Text("\(userScore)/\(quiz.questions.count)")
                                         .font(.custom("Montserrat-Bold", size: 22))
                                         .fontWeight(.bold)
                                         .foregroundColor(quiz.isPassed ? .green : .red)
                                 }
                                 
                                 Spacer()
                                 
                                 VStack(alignment: .trailing) {
                                     Text("Date")
                                         .font(.custom("Montserrat-Bold", size: 12))
                                         .foregroundColor(.secondary)
                                     Text(completionDate, style: .date)
                                         .font(.custom("Montserrat-Bold", size: 15))
                                 }
                                 
                                 Spacer()
                                 
                                 VStack(alignment: .trailing) {
                                     Text("Result")
                                         .font(.custom("Montserrat-Bold", size: 12))
                                         .foregroundColor(.secondary)
                                     Text(quiz.isPassed ? "Passed" : "Failed")
                                         .font(.custom("Montserrat-Bold", size: 15))
                                         .fontWeight(.semibold)
                                         .foregroundColor(quiz.isPassed ? .green : .red)
                                 }
                             }
                         }
                         .padding()
                         .background(Color(UIColor.secondarySystemBackground))
                         .cornerRadius(12)
                         .padding(.horizontal)
                     }
                 }
                 .padding(.vertical)
             }
             .navigationBarTitleDisplayMode(.inline)
             .fullScreenCover(isPresented: $showingQuiz) {
                 QuizSessionView(quiz: quiz, viewModel: viewModel)
             }
         }
     }
}

struct QuizSessionView: View {
    let quiz: Quiz
    @ObservedObject var viewModel: AcademyViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var showingExplanation = false
    @State private var answers: [Int?]
    @State private var showingResults = false
    @Environment(\.dismiss) var dismiss
    init(quiz: Quiz, viewModel: AcademyViewModel) {
        self.quiz = quiz
        self.viewModel = viewModel
        _answers = State(initialValue: Array(repeating: nil, count: quiz.questions.count))
    }
    
    var body: some View {
        if showingResults {
            quizResults
        } else {
            quizQuestion
        }
    }
    
    private var quizQuestion: some View {
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
            // Progress
            ProgressView(
                value: Double(min(currentQuestionIndex + 1, quiz.questions.count)),
                total: Double(quiz.questions.count)
            )
            .padding(.horizontal)
            
            Text("Question \(min(currentQuestionIndex + 1, quiz.questions.count)) of \(quiz.questions.count)")
                .font(.custom("Montserrat-Bold", size: 17))
            
            ScrollView {
                VStack(spacing: 20) {
                    if currentQuestionIndex < quiz.questions.count {
                        // Question
                        Text(quiz.questions[currentQuestionIndex].text)
                            .font(.custom("Montserrat-Bold", size: 20))
                            .padding()
                            .background(
                                Image(.cellImg)
                                    .resizable()
                            )
                            .cornerRadius(12)
                        
                        // Options
                        VStack(spacing: 12) {
                            ForEach(quiz.questions[currentQuestionIndex].options.indices, id: \.self) { index in
                                
                                Button(action: { selectAnswer(index) }) {
                                    ZStack(alignment: .leading) {
                                        Image("option\(index+1)")
                                            .resizable()
                                            .frame(height: 100)
                                            .clipped()
                                            .overlay(
                                                Color.black.opacity(selectedAnswer == index ? 0.4 : 0.2)
                                            )
                                            .cornerRadius(12)
                                        
                                        HStack {
                                            Text(quiz.questions[currentQuestionIndex].options[index])
                                                .font(.custom("Montserrat-Bold", size: 17))
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                            
                                            if selectedAnswer == index {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .imageScale(.large)
                                            }
                                        }
                                        .padding()
                                    }
                                }
                            }
                        }


                    }
                }
                .padding()
            }
            
            // Navigation
            HStack {
                if currentQuestionIndex > 0 {
                    Button(action: previousQuestion) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                if currentQuestionIndex < quiz.questions.count - 1 {
                    Button(action: nextQuestion) {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(selectedAnswer != nil ? Color.blue : Color(UIColor.brown))
                        .foregroundColor(selectedAnswer != nil ? .white : .primary)
                        .cornerRadius(12)
                    }
                    .disabled(selectedAnswer == nil)
                } else {
                    Button(action: finishQuiz) {
                        Text("Finish")
                            .padding()
                            .frame(width: 100)
                            .background(selectedAnswer != nil ? Color.green : Color(UIColor.secondarySystemBackground))
                            .foregroundColor(selectedAnswer != nil ? .white : .primary)
                            .cornerRadius(12)
                    }
                    .disabled(selectedAnswer == nil)
                }
            }
            .padding()
        }
        .background(
            Image(.bgMain)
                .resizable()
                .ignoresSafeArea()
        )
        .navigationBarTitle("Quiz", displayMode: .inline)
        .navigationBarItems(trailing: Button("Exit") {
            presentationMode.wrappedValue.dismiss()
        })
    }

    
    private var quizResults: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Score
                VStack {
                    Text("Quiz Completed!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(calculateScore()) correct out of \(quiz.questions.count)")
                        .font(.custom("Montserrat-Bold", size: 17))
                    
                    CircularProgressView(
                        progress: Double(calculateScore()) / Double(quiz.questions.count),
                        color: quiz.isPassed ? .green : .red
                    )
                    .frame(width: 150, height: 150)
                    .padding()
                }
                
                // Results
                VStack(alignment: .leading, spacing: 16) {
                    Text("Question Review")
                        .font(.custom("Montserrat-Bold", size: 17))
                        .padding(.horizontal)
                    
                    ForEach(quiz.questions.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: answers[index] == quiz.questions[index].correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(answers[index] == quiz.questions[index].correctAnswer ? .green : .red)
                                
                                Text("Question \(index + 1)")
                                   .font(.custom("Montserrat-Bold", size: 15))
                                    .fontWeight(.bold)
                            }
                            
                            Text(quiz.questions[index].text)
                                .font(.custom("Montserrat-Bold", size: 17))
                            
                            if let answer = answers[index] {
                                Text("Your answer: \(quiz.questions[index].options[answer])")
                                   .font(.custom("Montserrat-Bold", size: 15))
                                    .foregroundColor(answer == quiz.questions[index].correctAnswer ? .green : .red)
                                
                                if answer != quiz.questions[index].correctAnswer {
                                    Text("Correct answer: \(quiz.questions[index].options[quiz.questions[index].correctAnswer])")
                                       .font(.custom("Montserrat-Bold", size: 15))
                                        .foregroundColor(.green)
                                }
                                
                                Text(quiz.questions[index].explanation)
                                    .font(.custom("Montserrat-Bold", size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.submitQuiz(quiz, score: calculateScore())
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save Results")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        currentQuestionIndex = 0
                        selectedAnswer = nil
                        answers = Array(repeating: nil, count: quiz.questions.count)
                        showingResults = false
                    }) {
                        Text("Retake Quiz")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationBarItems(trailing: Button("Exit") {
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    private func selectAnswer(_ index: Int) {
        selectedAnswer = index
        answers[currentQuestionIndex] = index
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < quiz.questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = answers[currentQuestionIndex]
        }
    }
    
    private func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            selectedAnswer = answers[currentQuestionIndex]
        }
    }
    
    private func finishQuiz() {
        showingResults = true
    }
    
    private func calculateScore() -> Int {
        var score = 0
        for (index, answer) in answers.enumerated() {
            if answer == quiz.questions[index].correctAnswer {
                score += 1
            }
        }
        return score
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(color)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            Text(String(format: "%.0f%%", min(progress * 100, 100.0)))
                .font(.title)
                .bold()
        }
    }
}
