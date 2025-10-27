import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var userProgress: UserProgress
    @Published var adventures: [Adventure]
    @Published var courses: [Course]
    @Published var quizzes: [Quiz]
    
    private let userDefaultsKey = "userProgress"
    private let adventuresKey = "adventures"
    private let coursesKey = "courses"
    private let quizzesKey = "quizzes"
    
    private init() {
        self.userProgress = Self.loadUserProgress()
        self.adventures = Self.loadAdventures()
        self.courses = Self.loadCourses()
        self.quizzes = Self.loadQuizzes()
    }
    
    // MARK: - UserProgress
    private static func loadUserProgress() -> UserProgress {
        if let data = UserDefaults.standard.data(forKey: "userProgress"),
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
    
    func saveUserProgress() {
        if let data = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            objectWillChange.send()
        }
    }
    
    private static func createDefaultGoals() -> [Goal] {
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
    
    private static func createDefaultMilestones() -> [Milestone] {
        return [
            Milestone(
                id: UUID(),
                title: "Novice Traveler",
                description: "Walk 10 km",
                type: .totalDistance,
                threshold: 10,
                reward: 100,
                isAchieved: false,
                achievedDate: nil
            ),
            Milestone(
                id: UUID(),
                title: "Active Explorer",
                description: "Spend 5 hours in activities",
                type: .totalDuration,
                threshold: 18000,
                reward: 150,
                isAchieved: false,
                achievedDate: nil
            )
        ]
    }
    
    // MARK: - Certificate Management
    func issueCertificate(for courseId: UUID?, courseTitle: String?, grade: String, relatedToQuiz: Bool = false, score: Int? = nil, totalQuestions: Int? = nil) -> Certificate {
        let certificate = Certificate(
            id: UUID(),
            courseId: courseId,
            userId: UUID(),
            issueDate: Date(),
            grade: grade,
            relatedToQuiz: relatedToQuiz,
            score: score,
            totalQuestions: totalQuestions,
            courseTitle: courseTitle
        )
        
        userProgress.certificates.append(certificate)
        saveUserProgress()
        
        return certificate
    }
    
    // MARK: - Quiz Management
    func submitQuiz(_ quiz: Quiz, score: Int) {
        if let index = quizzes.firstIndex(where: { $0.id == quiz.id }) {
            var updatedQuiz = quiz
            updatedQuiz.userScore = score
            updatedQuiz.completionDate = Date()
            quizzes[index] = updatedQuiz
            saveQuizzes()
        }
        
        userProgress.quizScores[quiz.id] = score
        let scorePercentage = Double(score) / Double(quiz.questions.count) * 100
        if scorePercentage >= Double(quiz.requiredScore) {
            let courseTitle = courses.first { $0.id == quiz.relatedCourseId }?.title ?? quiz.title
            _ = issueCertificate(
                for: quiz.relatedCourseId,
                courseTitle: courseTitle,
                grade: calculateGrade(score: scorePercentage),
                relatedToQuiz: true,
                score: score,
                totalQuestions: quiz.questions.count
            )
        }

        awardQuizPoints(score: score, difficulty: quiz.difficulty)
        saveUserProgress()
    }
    
    private func calculateGrade(score: Double) -> String {
        switch score {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
    
    private func awardQuizPoints(score: Int, difficulty: Adventure.Difficulty) {
        let basePoints = 50
        let difficultyMultiplier: Double
        switch difficulty {
        case .beginner: difficultyMultiplier = 1.0
        case .intermediate: difficultyMultiplier = 1.5
        case .advanced: difficultyMultiplier = 2.0
        case .expert: difficultyMultiplier = 2.5
        }
        
        let scoreMultiplier = Double(score) / 100.0
        let totalPoints = Int(Double(basePoints) * difficultyMultiplier * scoreMultiplier)
        userProgress.totalPoints += totalPoints

        updateLevel()
    }
    
    private func updateLevel() {
        userProgress.level = userProgress.totalPoints / 100 + 1
    }
    
    // MARK: - Adventures
    static func loadAdventures() -> [Adventure] {
        return [
            Adventure(
                id: UUID(),
                title: "Mount San Jacinto Peak Trail",
                category: .hiking,
                difficulty: .advanced,
                duration: "5-7 hours",
                distance: 11.0,
                description: "Challenge yourself with this stunning peak trail offering 360-degree views of Southern California. This trail near Morongo Valley provides an unforgettable hiking experience.",
                location: "San Jacinto Mountains",
                coordinates: Adventure.Coordinates(latitude: 33.8147, longitude: -116.6794),
                tips: [
                    "Start early to avoid afternoon heat",
                    "Bring at least 3 liters of water",
                    "Check weather conditions before hiking",
                    "Wear proper hiking boots"
                ],
                equipment: ["Hiking boots", "Trekking poles", "Sun protection", "First aid kit"],
                bestSeason: "October - May",
                imageNames: ["mountain_trail"],
                rating: 4.8,
                reviews: 245
            ),
            Adventure(
                id: UUID(),
                title: "Desert Hot Springs Rock Climbing",
                category: .climbing,
                difficulty: .intermediate,
                duration: "3-4 hours",
                distance: nil,
                description: "Experience world-class rock climbing just minutes from Morongo. Perfect granite formations with routes for all skill levels.",
                location: "Desert Hot Springs",
                coordinates: Adventure.Coordinates(latitude: 33.9614, longitude: -116.5017),
                tips: [
                    "Best climbing conditions in morning",
                    "Bring climbing chalk",
                    "Check local climbing regulations",
                    "Consider hiring a guide for first visit"
                ],
                equipment: ["Climbing harness", "Dynamic rope", "Carabiners", "Helmet", "Climbing shoes"],
                bestSeason: "November - March",
                imageNames: ["rock_climbing"],
                rating: 4.6,
                reviews: 178
            ),
            Adventure(
                id: UUID(),
                title: "Whitewater Preserve Mountain Biking",
                category: .biking,
                difficulty: .intermediate,
                duration: "2-3 hours",
                distance: 15.5,
                description: "Thrilling mountain biking trails through diverse desert terrain. Experience the rush of technical descents and scenic climbs near Morongo.",
                location: "Whitewater Preserve",
                coordinates: Adventure.Coordinates(latitude: 33.9742, longitude: -116.6475),
                tips: [
                    "Check bike before riding",
                    "Wear protective gear",
                    "Ride within your limits",
                    "Carry spare tube and tools"
                ],
                equipment: ["Mountain bike", "Helmet", "Gloves", "Hydration pack"],
                bestSeason: "October - April",
                imageNames: ["mountain_biking"],
                rating: 4.7,
                reviews: 156
            ),
            Adventure(
                id: UUID(),
                title: "Big Bear Lake Wakeboarding",
                category: .water,
                difficulty: .beginner,
                duration: "2-4 hours",
                distance: nil,
                description: "Learn wakeboarding on the pristine waters of Big Bear Lake. Professional instructors and equipment available. Great weekend adventure from Morongo area.",
                location: "Big Bear Lake",
                coordinates: Adventure.Coordinates(latitude: 34.2439, longitude: -116.9114),
                tips: [
                    "Book lessons in advance",
                    "Wear sunscreen",
                    "Start with beginner board",
                    "Listen to instructor carefully"
                ],
                equipment: ["Wakeboard", "Life vest", "Wetsuit", "Tow rope"],
                bestSeason: "June - September",
                imageNames: ["wakeboarding"],
                rating: 4.5,
                reviews: 203
            ),
            Adventure(
                id: UUID(),
                title: "Palm Springs Parasailing Adventure",
                category: .air,
                difficulty: .beginner,
                duration: "1-2 hours",
                distance: nil,
                description: "Soar above the Coachella Valley with breathtaking views of the desert landscape. Safe and thrilling experience for all ages near Morongo.",
                location: "Palm Springs",
                coordinates: Adventure.Coordinates(latitude: 33.8303, longitude: -116.5453),
                tips: [
                    "Wear comfortable clothes",
                    "Bring camera with strap",
                    "Book early morning flights",
                    "Check wind conditions"
                ],
                equipment: ["All equipment provided"],
                bestSeason: "Year-round",
                imageNames: ["parasailing"],
                rating: 4.9,
                reviews: 312
            ),
            Adventure(
                id: UUID(),
                title: "Joshua Tree Bouldering",
                category: .climbing,
                difficulty: .expert,
                duration: "Full day",
                distance: nil,
                description: "World-renowned bouldering destination with thousands of problems. Test your skills on unique rock formations in this desert wonderland.",
                location: "Joshua Tree National Park",
                coordinates: Adventure.Coordinates(latitude: 33.8734, longitude: -115.9010),
                tips: [
                    "Bring crash pads",
                    "Climb with spotters",
                    "Respect the environment",
                    "Stay hydrated"
                ],
                equipment: ["Climbing shoes", "Chalk bag", "Crash pads", "Brush"],
                bestSeason: "October - April",
                imageNames: ["bouldering"],
                rating: 4.8,
                reviews: 467
            )
        ]
    }
    
    // MARK: - Courses
    private static func loadCourses() -> [Course] {
        var courses: [Course] = []
        
        // Part 1: Safety and Survival Courses
        courses.append(contentsOf: loadSafetyCourses())
        
        // Part 2: Navigation and First Aid Courses
        courses.append(contentsOf: loadNavigationFirstAidCourses())
        
        // Part 3: Environment and Weather Courses
        courses.append(contentsOf: loadEnvironmentWeatherCourses())
        
        // Part 4: Sports Courses (Air, Skiing, Water)
        courses.append(contentsOf: loadSportsCourses())
        
        // Part 5: New Specialized Courses
        courses.append(contentsOf: loadSpecializedCourses())
        
        // Part 6: Photography & Documentation Courses
        courses.append(contentsOf: loadPhotographyCourses())
        
        return courses
    }
    
    // MARK: - Course Content Methods
    
    // Safety Courses
    private static func loadSafetyCourses() -> [Course] {
        return [
            Course(
                id: UUID(),
                title: "Wilderness Survival Art",
                description: "Transform from beginner to confident traveler. Master skills that save lives in extreme situations.",
                category: .hiking,
                difficulty: .beginner,
                duration: "4 weeks",
                modules: [
                    Course.Module(
                        id: UUID(),
                        title: "Safety Fundamentals",
                        description: "Fundamental principles of safety in nature",
                        lessons: [
                            Course.Lesson(
                                id: UUID(),
                                title: "Survival Psychology Rules",
                                description: "Essential mental principles for survival situations",
                                type: .text,
                                duration: 900,
                                content: survivalPsychologyContent(),
                                isCompleted: false
                            ),
                            Course.Lesson(
                                id: UUID(),
                                title: "Emergency Shelter Building",
                                description: "Quick shelter construction techniques",
                                type: .video,
                                duration: 720,
                                content: "shelter_building_video",
                                isCompleted: false
                            ),
                            Course.Lesson(
                                id: UUID(),
                                title: "Fire Starting Mastery",
                                description: "Multiple fire starting methods in all conditions",
                                type: .interactive,
                                duration: 600,
                                content: fireStartingContent(),
                                isCompleted: false
                            )
                        ],
                        isCompleted: false
                    ),
                    Course.Module(
                        id: UUID(),
                        title: "Advanced Survival Techniques",
                        description: "Professional survival skills for extended stays",
                        lessons: [
                            Course.Lesson(
                                id: UUID(),
                                title: "Water Purification Methods",
                                description: "Making water safe to drink in wilderness",
                                type: .text,
                                duration: 800,
                                content: waterPurificationContent(),
                                isCompleted: false
                            ),
                            Course.Lesson(
                                id: UUID(),
                                title: "Emergency Signaling",
                                description: "How to signal for rescue effectively",
                                type: .interactive,
                                duration: 450,
                                content: signalingContent(),
                                isCompleted: false
                            )
                        ],
                        isCompleted: false
                    )
                ],
                imageURL: "survival_course_cover",
                instructor: "Max Forest",
                rating: 4.9,
                reviews: 234,
                Access: "Free",
                features: ["Completion Certificate", "Interactive Simulations", "Preparation Checklists"],
                imageName: "survivalArt"
            ),
            
            Course(
                id: UUID(),
                title: "Urban Survival Preparedness",
                description: "Essential skills for surviving emergencies in urban environments and natural disasters.",
                category: .hiking,
                difficulty: .beginner,
                duration: "3 weeks",
                modules: [
                    Course.Module(
                        id: UUID(),
                        title: "Urban Emergency Protocols",
                        description: "Survival strategies for city environments",
                        lessons: [
                            Course.Lesson(
                                id: UUID(),
                                title: "Emergency Evacuation Planning",
                                description: "Creating effective evacuation plans",
                                type: .text,
                                duration: 680,
                                content: evacuationPlanningContent(),
                                isCompleted: false
                            ),
                            Course.Lesson(
                                id: UUID(),
                                title: "Urban Water Sources",
                                description: "Finding and purifying water in cities",
                                type: .interactive,
                                duration: 550,
                                content: urbanWaterContent(),
                                isCompleted: false
                            )
                        ],
                        isCompleted: false
                    )
                ],
                imageURL: "urban_survival_cover",
                instructor: "Alex Crisis",
                rating: 4.7,
                reviews: 189,
                Access: "Free",
                features: ["Emergency Checklists", "Urban Survival Kit", "Evacuation Plans"],
                imageName: "urbanSurvival"
            )
        ]
    }
    
    // Navigation & First Aid Courses
    private static func loadNavigationFirstAidCourses() -> [Course] {
        return [
            Course(
                id: UUID(),
                title: "Advanced Navigation Mastery",
                description: "Master celestial navigation, GPS technology and advanced orienteering techniques.",
                category: .hiking,
                difficulty: .advanced,
                duration: "5 weeks",
                modules: [
                    Course.Module(
                        id: UUID(),
                        title: "Celestial Navigation",
                        description: "Navigate using stars, sun and natural indicators",
                        lessons: [
                            Course.Lesson(
                                id: UUID(),
                                title: "Star Navigation Principles",
                                description: "Using constellations for direction finding",
                                type: .text,
                                duration: 880,
                                content: starNavigationContent(),
                                isCompleted: false
                            ),
                            Course.Lesson(
                                id: UUID(),
                                title: "Solar Navigation Techniques",
                                description: "Using sun position for navigation",
                                type: .interactive,
                                duration: 720,
                                content: solarNavigationContent(),
                                isCompleted: false
                            )
                        ],
                        isCompleted: false
                    )
                ],
                imageURL: "navigation_course_cover",
                instructor: "Captain Orion",
                rating: 4.8,
                reviews: 156,
                Access: "Free",
                features: ["Star Chart Kit", "GPS Simulation", "Advanced Techniques"],
                imageName: "navigationMastery"
            ),
            
            Course(
                id: UUID(),
                title: "Wilderness First Responder",
                description: "Professional-level first aid training for remote environments and extended care situations.",
                category: .hiking,
                difficulty: .advanced,
                duration: "8 weeks",
                modules: [
                    Course.Module(
                        id: UUID(),
                        title: "Extended Care Protocols",
                        description: "Long-term patient management in remote settings",
                        lessons: [
                            Course.Lesson(
                                id: UUID(),
                                title: "Extended Wilderness Care",
                                description: "Managing patients during prolonged rescues",
                                type: .text,
                                duration: 1100,
                                content: extendedCareContent(),
                                isCompleted: false
                            )
                        ],
                        isCompleted: false
                    )
                ],
                imageURL: "first_aid_course_cover",
                instructor: "Dr. Wilderness",
                rating: 4.9,
                reviews: 289,
                Access: "Free",
                features: ["WFR Certification", "Rescue Scenarios", "Medical Kit Planning"],
                imageName: "wildernessFirstResponders"
            )
        ]
    }
    
    // Environment & Weather Courses
    private static func loadEnvironmentWeatherCourses() -> [Course] {
        return [
            Course(
                id: UUID(),
                title: "Advanced Environmental Stewardship",
                description: "Deep dive into ecosystem conservation, wildlife protection and sustainable practices.",
                category: .hiking,
                difficulty: .intermediate,
                duration: "6 weeks",
                modules: [
                    Course.Module(
                        id: UUID(),
                        title: "Ecosystem Conservation",
                        description: "Advanced techniques for environmental protection",
                        lessons: [
                            Course.Lesson(
                                id: UUID(),
                                title: "Advanced Conservation Principles",
                                description: "Professional-level environmental protection",
                                type: .text,
                                duration: 950,
                                content: conservationContent(),
                                isCompleted: false
                            )
                        ],
                        isCompleted: false
                    )
                ],
                imageURL: "environment_course_cover",
                instructor: "Dr. Greenfield",
                rating: 4.7,
                reviews: 178,
                Access: "Free",
                features: ["Conservation Certification", "Field Projects", "Expert Community"],
                imageName: "environmentalStewardship"
            ),
            
            Course(
                id: UUID(),
                title: "Advanced Weather Prediction",
                description: "Master meteorological patterns, storm tracking and extreme weather preparedness.",
                category: .hiking,
                difficulty: .expert,
                duration: "7 weeks",
                modules: [
                    Course.Module(
                        id: UUID(),
                        title: "Storm Prediction Systems",
                        description: "Advanced techniques for severe weather forecasting",
                        lessons: [
                            Course.Lesson(
                                id: UUID(),
                                title: "Severe Weather Analysis",
                                description: "Professional storm prediction methods",
                                type: .text,
                                duration: 1200,
                                content: weatherAnalysisContent(),
                                isCompleted: false
                            )
                        ],
                        isCompleted: false
                    )
                ],
                imageURL: "weather_course_cover",
                instructor: "Storm Chaser Mike",
                rating: 4.8,
                reviews: 203,
                Access: "Free",
                features: ["Storm Tracking", "Weather Instruments", "Safety Protocols"],
                imageName: "weatherPrediction"
            )
        ]
    }
    
    // Sports Courses
    private static func loadSportsCourses() -> [Course] {
        return [
            Course(
                id: UUID(),
                title: "Paragliding Mastery",
                description: "From beginner launches to advanced thermal flying. Become a confident paraglider pilot.",
                category: .air,
                difficulty: .intermediate,
                duration: "10 weeks",
                modules: [
                    Course.Module(
                        id: UUID(),
                        title: "Advanced Flight Techniques",
                        description: "Mastering thermals and cross-country flying",
                        lessons: [
                            Course.Lesson(
                                id: UUID(),
                                title: "Thermal Flying Mastery",
                                description: "Advanced techniques for staying airborne",
                                type: .text,
                                duration: 1050,
                                content: thermalFlyingContent(),
                                isCompleted: false
                            )
                        ],
                        isCompleted: false
                    )
                ],
                imageURL: "air_sports_course_cover",
                instructor: "Sky Master Elena",
                rating: 4.9,
                reviews: 167,
                Access: "Free",
                features: ["Flight Simulator", "Pilot Certification", "Weather Analysis"],
                imageName: "paraglidingMastery"
            ),
            
            Course(
                id: UUID(),
                title: "Backcountry Skiing Expedition",
                description: "Master backcountry techniques, avalanche safety and winter wilderness survival.",
                category: .skiing,
                difficulty: .advanced,
                duration: "8 weeks",
                modules: [
                    Course.Module(
                        id: UUID(),
                        title: "Avalanche Safety and Rescue",
                        description: "Comprehensive avalanche education and rescue protocols",
                        lessons: [
                            Course.Lesson(
                                id: UUID(),
                                title: "Avalanche Rescue Protocol",
                                description: "Professional rescue techniques and equipment use",
                                type: .text,
                                duration: 1300,
                                content: avalancheRescueContent(),
                                isCompleted: false
                            )
                        ],
                        isCompleted: false
                    )
                ],
                imageURL: "skiing_course_cover",
                instructor: "Mountain Guide Hans",
                rating: 4.8,
                reviews: 198,
                Access: "Free",
                features: ["Avalanche Certification", "Rescue Training", "Winter Survival"],
                imageName: "backcountrySkiingExpedition"
            )
        ]
    }
    
    // Specialized Courses
    private static func loadSpecializedCourses() -> [Course] {
        return [
            Course(
                id: UUID(),
                title: "Rock Climbing Technique Mastery",
                description: "Advanced climbing techniques, movement efficiency, and mental training for serious climbers.",
                category: .climbing,
                difficulty: .intermediate,
                duration: "6 weeks",
                modules: [
                    Course.Module(
                        id: UUID(),
                        title: "Advanced Movement Techniques",
                        description: "Master efficient climbing movement",
                        lessons: [
                            Course.Lesson(
                                id: UUID(),
                                title: "Dynamic Movement Principles",
                                description: "Mastering dynamic climbing techniques",
                                type: .text,
                                duration: 850,
                                content: dynamicMovementContent(),
                                isCompleted: false
                            )
                        ],
                        isCompleted: false
                    )
                ],
                imageURL: "climbing_technique_cover",
                instructor: "Vertical Master Leo",
                rating: 4.8,
                reviews: 223,
                Access: "Free",
                features: ["Technique Analysis", "Training Plans", "Movement Drills"],
                imageName: "climbingMastery"
            )
        ]
    }
    
    // Photography Courses
    private static func loadPhotographyCourses() -> [Course] {
        return [
            Course(
                id: UUID(),
                title: "Adventure Photography",
                description: "Capture stunning outdoor images. Master composition, lighting, and storytelling in adventure photography.",
                category: .hiking,
                difficulty: .beginner,
                duration: "4 weeks",
                modules: [
                    Course.Module(
                        id: UUID(),
                        title: "Outdoor Photography Fundamentals",
                        description: "Essential techniques for outdoor photography",
                        lessons: [
                            Course.Lesson(
                                id: UUID(),
                                title: "Natural Light Mastery",
                                description: "Using natural light in outdoor photography",
                                type: .text,
                                duration: 750,
                                content: naturalLightContent(),
                                isCompleted: false
                            )
                        ],
                        isCompleted: false
                    )
                ],
                imageURL: "photography_course_cover",
                instructor: "Lens Master Sarah",
                rating: 4.9,
                reviews: 278,
                Access: "Free",
                features: ["Photo Assignments", "Editing Techniques", "Portfolio Building"],
                imageName: "adventurePhotography"
            )
        ]
    }
    
    // MARK: - Content Methods
    
    private static func survivalPsychologyContent() -> String {
        return """
        # Survival Psychology Rules
        
        ## 1. Stay Calm Principle
        - Stop and breathe deeply before making decisions
        - Assess the situation objectively
        - Avoid panic-driven actions
        
        ## 2. Positive Mindset Rules
        - Focus on solutions, not problems
        - Set small achievable goals
        - Maintain hope and determination
        
        ## 3. Decision Making Protocol
        - Gather all available information
        - Consider consequences of each action
        - Choose the safest option first
        """
    }
    
    private static func fireStartingContent() -> String {
        return """
        # Fire Starting Mastery
        
        ## 1. Primitive Methods
        - **Bow Drill Technique**: Create fire using friction
        - **Hand Drill**: Simpler but more physically demanding
        - **Fire Plow**: Effective in certain wood types
        
        ## 2. Modern Tools
        - **Ferrocerium Rods**: Reliable in all conditions
        - **Waterproof Matches**: Essential for wet environments
        - **Lighters**: Most convenient but can fail
        
        ## 3. Fire Structure
        - **Teepee**: Fast ignition, good for cooking
        - **Log Cabin**: Long-lasting, stable
        - **Lean-to**: Wind-resistant design
        """
    }
    
    private static func waterPurificationContent() -> String {
        return """
        # Water Purification Methods
        
        ## 1. Boiling
        - Most reliable method
        - Boil for 1 minute (3 minutes at high altitude)
        - Kills all pathogens
        
        ## 2. Filtration
        - **Portable Filters**: Remove bacteria and protozoa
        - **DIY Filters**: Using sand, charcoal, and cloth
        - **Microbiological Safety**: Check filter ratings
        
        ## 3. Chemical Treatment
        - **Iodine Tablets**: Effective but alters taste
        - **Chlorine Dioxide**: Better taste, broader protection
        - **Wait Times**: Follow manufacturer instructions
        """
    }
    
    private static func signalingContent() -> String {
        return """
        # Emergency Signaling Methods
        
        ## 1. Visual Signals
        - **Signal Mirror**: Most effective daytime signal
        - **Smoke Signals**: Green vegetation for white smoke
        - **Ground Signals**: Create large symbols visible from air
        
        ## 2. Auditory Signals
        - **Whistle**: Carry a survival whistle
        - **Gunshots**: Three shots in rapid succession
        - **Voice**: Yell in groups of three
        
        ## 3. Electronic Signals
        - **PLB/EPIRB**: Satellite emergency beacons
        - **Cell Phone**: Emergency calls when service available
        """
    }
    
    private static func evacuationPlanningContent() -> String {
        return """
        # Emergency Evacuation Planning
        
        ## 1. Risk Assessment
        - **Identify Threats**: Natural disasters in your area
        - **Vulnerability Analysis**: Home and workplace risks
        - **Escape Routes**: Primary and secondary paths
        
        ## 2. Communication Plan
        - **Family Contacts**: Designated out-of-area contact
        - **Meeting Points**: Primary and secondary locations
        - **Emergency Alerts**: Sign up for local warning systems
        """
    }
    
    private static func urbanWaterContent() -> String {
        return """
        # Urban Water Sources & Purification
        
        ## 1. Emergency Water Sources
        - **Water Heaters**: 40-80 gallons of clean water
        - **Toilet Tanks**: Not bowls, only clean tank water
        - **Canned Goods**: Liquid in canned vegetables/fruits
        
        ## 2. Collection Methods
        - **Rainwater**: Clean collection from roofs
        - **Swimming Pools**: For non-drinking uses initially
        - **Water Mains**: Know how to shut off and drain
        """
    }
    
    private static func starNavigationContent() -> String {
        return """
        # Star Navigation Principles
        
        ## 1. Polaris (North Star) Navigation
        - Locate Polaris using Big Dipper pointer stars
        - Polaris indicates true north direction
        - Accuracy within 1 degree of true north
        
        ## 2. Southern Cross Navigation
        - Crux constellation for southern hemisphere
        - Extend the long axis 4.5 times for south direction
        - Use with Pointers for verification
        """
    }
    
    private static func solarNavigationContent() -> String {
        return """
        # Solar Navigation Techniques
        
        ## 1. Shadow Stick Method
        - Place stick vertically in ground
        - Mark shadow tip every 15 minutes
        - Line through marks shows east-west direction
        
        ## 2. Watch Method
        - **Northern Hemisphere**: Point hour hand at sun
        - **Southern Hemisphere**: Point 12 at sun
        """
    }
    
    private static func extendedCareContent() -> String {
        return """
        # Extended Wilderness Care Protocols
        
        ## 1. Patient Monitoring System
        - Vital signs tracking every 15 minutes
        - Neurological assessment checks
        - Hydration and nutrition management
        
        ## 2. Environmental Protection
        - Hypothermia prevention protocols
        - Shelter improvisation techniques
        - Weather protection strategies
        """
    }
    
    private static func conservationContent() -> String {
        return """
        # Advanced Conservation Principles
        
        ## 1. Habitat Restoration
        - Native species reintroduction
        - Erosion control techniques
        - Water source protection
        
        ## 2. Wildlife Corridor Management
        - Migration route preservation
        - Human-wildlife conflict reduction
        - Habitat connectivity planning
        """
    }
    
    private static func weatherAnalysisContent() -> String {
        return """
        # Severe Weather Analysis
        
        ## 1. Thunderstorm Development
        - Cumulus stage identification
        - Mature stage characteristics
        - Dissipating stage recognition
        
        ## 2. Tornado Prediction Signs
        - Wall cloud formation
        - Funnel cloud development
        - Environmental precursors
        """
    }
    
    private static func thermalFlyingContent() -> String {
        return """
        # Thermal Flying Mastery
        
        ## 1. Thermal Identification
        - Cloud street recognition
        - Bird behavior observation
        - Ground feature indicators
        
        ## 2. Core Centering Techniques
        - Speed-to-fly theory
        - Turn radius optimization
        - Weight shift coordination
        """
    }
    
    private static func avalancheRescueContent() -> String {
        return """
        # Avalanche Rescue Protocol
        
        ## 1. Transceiver Search
        - Initial signal search pattern
        - Fine search techniques
        - Pinpoint probe methods
        
        ## 2. Multiple Burial Scenarios
        - Multiple signal management
        - Strategic digging order
        - Team coordination protocols
        """
    }
    
    private static func dynamicMovementContent() -> String {
        return """
        # Dynamic Movement Principles
        
        ## 1. Momentum Utilization
        - **Deadpoint Moves**: Precise momentum control
        - **Dynamic Lunges**: Reaching distant holds
        - **Pogo Moves**: Using leg power for upward motion
        
        ## 2. Body Positioning
        - **Center of Gravity**: Optimal positioning
        - **Flagging**: Balance and stability
        - **Backstepping**: Hip engagement for reach
        """
    }
    
    private static func naturalLightContent() -> String {
        return """
        # Natural Light Mastery
        
        ## 1. Golden Hour Photography
        - **Morning Light**: Soft, warm tones
        - **Evening Light**: Dramatic, long shadows
        - **Positioning**: Sun at your back for beginners
        
        ## 2. Midday Challenges
        - **Harsh Light**: Use shadows creatively
        - **Overcast Advantage**: Natural softbox effect
        - **Reflectors**: Bouncing light into shadows
        """
    }
    
    // MARK: - Quizzes
    private static func loadQuizzes() -> [Quiz] {
        var quizzes: [Quiz] = []
        
        for category in Quiz.QuizCategory.allCases {
            for difficulty in Adventure.Difficulty.allCases {
                let quiz = QuizDataService.shared.generateQuiz(
                    category: category,
                    difficulty: difficulty,
                    questionCount: 10
                )
                quizzes.append(quiz)
            }
        }

        let courses = loadCourses()
        return quizzes.map { quiz in
            var updatedQuiz = quiz
            
            if let course = courses.first(where: { course in
                course.category.rawValue.lowercased().contains(quiz.category.rawValue.lowercased()) ||
                quiz.category.rawValue.lowercased().contains(course.category.rawValue.lowercased())
            }) {
                updatedQuiz.relatedCourseId = course.id
            }
            
            return updatedQuiz
        }
    }
    
    private func saveQuizzes() {
        if let data = try? JSONEncoder().encode(quizzes) {
            UserDefaults.standard.set(data, forKey: quizzesKey)
        }
    }
}

// MARK: - Course Extensions
extension Course {
    var progressPercentage: Double {
        let totalLessons = modules.flatMap { $0.lessons }.count
        guard totalLessons > 0 else { return 0 }
        let completedLessons = modules.flatMap { $0.lessons }.filter { $0.isCompleted }.count
        return Double(completedLessons) / Double(totalLessons) * 100
    }
    
    var totalDuration: TimeInterval {
        return TimeInterval(modules.flatMap { $0.lessons }.reduce(0) { $0 + $1.duration })
    }
    
    var formattedTotalDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = Int(totalDuration) / 60 % 60
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - Interactive Lesson Types
extension Course {
    enum LessonType: String, Codable {
        case text = "text"
        case video = "video"
        case interactive = "interactive"
        case quiz = "quiz"
        case practical = "practical"
        
        var icon: String {
            switch self {
            case .text: return "doc.text"
            case .video: return "play.rectangle"
            case .interactive: return "hand.tap"
            case .quiz: return "questionmark.circle"
            case .practical: return "figure.walk"
            }
        }
        
        var color: String {
            switch self {
            case .text: return "blue"
            case .video: return "red"
            case .interactive: return "green"
            case .quiz: return "orange"
            case .practical: return "purple"
            }
        }
    }
}
