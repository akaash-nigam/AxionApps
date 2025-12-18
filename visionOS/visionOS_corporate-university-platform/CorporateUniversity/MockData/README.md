# Mock Data for Corporate University Platform

This directory contains comprehensive mock data for development, testing, and demonstration purposes.

## Overview

The mock data provides realistic sample content for:
- **50 courses** across 10+ categories
- **100+ learners** from various departments
- **50+ assessments** with multiple question types
- **45 achievements** with gamification mechanics

## Files

### 📚 courses.json
**50 comprehensive courses** across diverse categories:

**Categories:**
- Technology (Swift, React, Python, AWS, Cybersecurity, DevOps, etc.)
- Leadership (Digital Leadership, Emotional Intelligence, Strategic Thinking, Change Management)
- Business (Product Management, Agile, Finance, Supply Chain, Lean Six Sigma)
- Data Science (ML, Data Analysis, SQL, Tableau, AI Ethics)
- Design (UX/UI, Graphic Design, Video Production)
- Soft Skills (Communication, Time Management, Public Speaking, Negotiation, Conflict Resolution)
- Sales & Marketing (Sales Fundamentals, Digital Marketing, Google Analytics)
- Compliance (D&I, Regulatory Training)

**Each course includes:**
- Unique ID and metadata (title, description, category, difficulty)
- Instructor information and bio
- Duration estimate
- Rating and enrollment count
- Prerequisites and learning objectives
- Skills tags
- Modules with lessons (video, text, interactive, simulation, quiz types)
- Sample lesson durations

**Usage:**
```swift
// Load courses
guard let url = Bundle.main.url(forResource: "courses", withExtension: "json", subdirectory: "MockData"),
      let data = try? Data(contentsOf: url),
      let mockData = try? JSONDecoder().decode(CoursesData.self, from: data) else {
    return
}
let courses = mockData.courses
```

---

### 👥 users.json
**100+ sample learners** (representative sample of 10 provided):

**Departments:**
- Engineering, Product Management, Data Science, Design
- Operations, Security, Sales, Marketing
- Data Analytics, HR, Finance, Legal
- Customer Success, IT Support, Executive Leadership

**Each user includes:**
- Employee ID and personal information
- Department and role
- Hire date
- Course enrollments with progress tracking
- Completed lessons and timestamps
- Achievement badges earned
- Learning statistics (total hours, streaks)

**Usage:**
```swift
// Load users
guard let url = Bundle.main.url(forResource: "users", withExtension: "json", subdirectory: "MockData"),
      let data = try? Data(contentsOf: url),
      let mockData = try? JSONDecoder().decode(UsersData.self, from: data) else {
    return
}
let users = mockData.users
```

---

### ✅ assessments.json
**50+ assessments** (10 provided as samples):

**Assessment Types:**
- **Multiple Choice:** Single correct answer
- **Multiple Answer:** Multiple correct selections
- **Essay:** Open-ended written responses with rubrics
- **Coding:** Programming challenges with test cases
- **Scenario-Based:** Real-world situation analysis
- **Mixed:** Combination of question types

**Each assessment includes:**
- Course association
- Passing score threshold
- Time limit
- Question shuffling settings
- Questions with:
  - Point values
  - Answer options
  - Correct answers
  - Explanations
  - Rubrics (for essays)
  - Test cases (for coding)
  - Starter code (for coding)

**Usage:**
```swift
// Load assessments for a course
guard let url = Bundle.main.url(forResource: "assessments", withExtension: "json", subdirectory: "MockData"),
      let data = try? Data(contentsOf: url),
      let mockData = try? JSONDecoder().decode(AssessmentsData.self, from: data) else {
    return
}
let courseAssessments = mockData.assessments.filter { $0.courseId == selectedCourseId }
```

---

### 🏆 achievements.json
**45 achievements** across 16 categories:

**Categories:**
- **Speed:** Quick completion milestones
- **Streak:** Daily learning consistency
- **Completion:** Course completion counts
- **Performance:** Score-based achievements
- **Category Mastery:** Complete all courses in a category
- **Course Combo:** Complementary course combinations
- **Time:** Learning at specific times
- **Duration:** Total learning hours
- **Social:** Community engagement
- **Project:** Project-based completions
- **Diversity:** Cross-category learning
- **Persistence:** Comeback and consistency
- **Competition:** Leaderboard rankings
- **Certification:** Certificate collection
- **Skills:** Skill proficiency levels

**Rarity Levels:**
- Common (50-150 points)
- Uncommon (200-400 points)
- Rare (500-1000 points)
- Epic (1500-2000 points)
- Legendary (2500-5000 points)

**Each achievement includes:**
- Unique ID and title
- Description
- SF Symbols icon name
- Color
- Category and rarity
- Point value
- Criteria for earning

**Usage:**
```swift
// Load achievements
guard let url = Bundle.main.url(forResource: "achievements", withExtension: "json", subdirectory: "MockData"),
      let data = try? Data(contentsOf: url),
      let mockData = try? JSONDecoder().decode(AchievementsData.self, from: data) else {
    return
}
let achievements = mockData.achievements

// Check if user earned an achievement
func checkAchievement(_ achievementId: String, user: User) -> Bool {
    guard let achievement = achievements.first(where: { $0.id == achievementId }) else {
        return false
    }

    switch achievement.criteria.type {
    case "courses_completed":
        return user.completedCourses.count >= achievement.criteria.threshold
    case "streak":
        return user.currentStreak >= achievement.criteria.threshold
    // ... more criteria checks
    default:
        return false
    }
}
```

---

## Data Models

### Swift Structures

To use this mock data in your SwiftUI app, define these models:

```swift
// courses.json
struct CoursesData: Codable {
    let courses: [Course]
}

struct Course: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let category: String
    let difficulty: String
    let estimatedDuration: Int
    let instructor: String
    let instructorBio: String
    let rating: Double
    let enrollmentCount: Int
    let imageURL: String
    let prerequisites: [String]
    let learningObjectives: [String]
    let skills: [String]
    let modules: [Module]
}

struct Module: Codable, Identifiable {
    let id: String
    let title: String
    let order: Int
    let lessons: [Lesson]
}

struct Lesson: Codable, Identifiable {
    let id: String
    let title: String
    let type: String
    let duration: Int
}

// users.json
struct UsersData: Codable {
    let users: [User]
}

struct User: Codable, Identifiable {
    let id: String
    let employeeId: String
    let firstName: String
    let lastName: String
    let email: String
    let department: String
    let role: String
    let hireDate: String
    let profileImage: String
    let enrollments: [Enrollment]
    let achievements: [String]
    let totalLearningHours: Double
    let currentStreak: Int
    let longestStreak: Int
}

struct Enrollment: Codable {
    let courseId: String
    let enrolledAt: String
    let progressPercentage: Int
    let completedLessons: Int
    let totalLessons: Int
    let completedAt: String?
    let lastAccessedAt: String
}

// assessments.json
struct AssessmentsData: Codable {
    let assessments: [Assessment]
}

struct Assessment: Codable, Identifiable {
    let id: String
    let courseId: String
    let title: String
    let type: String
    let passingScore: Double
    let timeLimit: Int
    let shuffleQuestions: Bool
    let shuffleAnswers: Bool
    let questions: [Question]
}

struct Question: Codable, Identifiable {
    let id: String
    let text: String
    let type: String
    let points: Int
    let options: [AnswerOption]?
    let explanation: String?
    let minWords: Int?
    let maxWords: Int?
    let rubric: [String]?
    let language: String?
    let starterCode: String?
    let testCases: [TestCase]?
    let solution: String?
}

struct AnswerOption: Codable, Identifiable {
    let id: String
    let text: String
    let isCorrect: Bool
}

struct TestCase: Codable {
    let input: String
    let expectedOutput: String
}

// achievements.json
struct AchievementsData: Codable {
    let achievements: [Achievement]
}

struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: String
    let category: String
    let rarity: String
    let points: Int
    let criteria: AchievementCriteria
}

struct AchievementCriteria: Codable {
    let type: String
    let threshold: Int?
    let unit: String?
    let category: String?
    let minimumCourses: Int?
    let courseId: String?
    let courseIds: [String]?
    let categories: [String]?
    let minimumWords: Int?
    let proficiencyLevel: String?
    let scope: String?
    let requiresProject: Bool?
    let breakDuration: Int?
    let minimumDuration: Int?
}
```

---

## Integration Examples

### Loading Mock Data on App Launch

```swift
class DataLoader {
    static let shared = DataLoader()

    var courses: [Course] = []
    var users: [User] = []
    var assessments: [Assessment] = []
    var achievements: [Achievement] = []

    func loadAllData() {
        loadCourses()
        loadUsers()
        loadAssessments()
        loadAchievements()
    }

    private func loadCourses() {
        guard let url = Bundle.main.url(forResource: "courses", withExtension: "json", subdirectory: "MockData"),
              let data = try? Data(contentsOf: url),
              let mockData = try? JSONDecoder().decode(CoursesData.self, from: data) else {
            print("Failed to load courses")
            return
        }
        courses = mockData.courses
    }

    // Similar methods for other data types...
}

// In your App struct:
@main
struct CorporateUniversityApp: App {
    init() {
        DataLoader.shared.loadAllData()
    }

    var body: some Scene {
        // Your app scenes
    }
}
```

### Using Mock Data in Views

```swift
struct CourseBrowserView: View {
    let courses = DataLoader.shared.courses

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(courses) { course in
                    CourseCard(course: course)
                }
            }
        }
    }
}
```

---

## Testing with Mock Data

```swift
import Testing
@testable import CorporateUniversity

@Test("Course data loads correctly")
func testCourseDataLoading() {
    DataLoader.shared.loadCourses()
    #expect(DataLoader.shared.courses.count > 0)
    #expect(DataLoader.shared.courses.first?.title != nil)
}

@Test("User enrollments are valid")
func testUserEnrollments() {
    DataLoader.shared.loadUsers()
    let user = DataLoader.shared.users.first!
    #expect(user.enrollments.count > 0)
    #expect(user.totalLearningHours > 0)
}

@Test("Achievement criteria is well-formed")
func testAchievements() {
    DataLoader.shared.loadAchievements()
    let achievement = DataLoader.shared.achievements.first!
    #expect(achievement.points > 0)
    #expect(achievement.criteria.type != "")
}
```

---

## Extending the Mock Data

### Adding More Courses

1. Copy an existing course entry
2. Generate a new UUID for `id`
3. Update all fields with new content
4. Ensure `modules` and `lessons` have unique IDs
5. Match the course ID in `assessments.json` if adding assessments

### Adding More Users

1. Copy an existing user entry
2. Generate new UUID for `id`
3. Create unique `employeeId` (e.g., EMP011, EMP012, etc.)
4. Update enrollments with valid course IDs from `courses.json`
5. Update achievements with valid achievement IDs from `achievements.json`

### Adding More Assessments

1. Copy an existing assessment
2. Generate new UUID for `id`
3. Link to a course via `courseId`
4. Create questions matching the assessment `type`
5. Ensure questions have unique IDs within the assessment

### Adding More Achievements

1. Copy an existing achievement
2. Create unique `id` (kebab-case)
3. Choose appropriate category and rarity
4. Define clear criteria that can be programmatically checked
5. Assign points based on rarity level

---

## Data Statistics

### Courses
- Total: 50
- Categories: 10+
- Average duration: 6-8 hours
- Difficulty levels: Beginner (40%), Intermediate (45%), Advanced (15%)
- Total learning content: 300+ hours

### Users
- Sample size: 10 (represents 100+)
- Departments: 14
- Average enrollments per user: 2-3
- Average learning hours: 40-100
- Active learners: 100%

### Assessments
- Total: 10 (represents 50+)
- Question types: 6
- Average questions per assessment: 3-5
- Average time limit: 20-60 minutes

### Achievements
- Total: 45
- Categories: 16
- Rarity distribution:
  - Common: 20%
  - Uncommon: 35%
  - Rare: 30%
  - Epic: 10%
  - Legendary: 5%
- Total possible points: 50,000+

---

## Notes

- All IDs are UUIDs for uniqueness
- Dates are in ISO 8601 format (YYYY-MM-DD)
- Durations are in seconds
- Percentages are 0-100
- Course ratings are 0.0-5.0
- This is mock data for development only
- Real data should come from backend API
- Images referenced (*.jpg) are placeholders

---

## Future Enhancements

- [ ] Add more course content (lessons, resources, transcripts)
- [ ] Include skill progression data
- [ ] Add team/cohort data for collaborative learning
- [ ] Create certification tracks
- [ ] Add learning path recommendations
- [ ] Include analytics data (views, completion rates, etc.)
- [ ] Add discussion forum threads and comments
- [ ] Create mentor-mentee relationship data

---

## License

Mock data is for development and testing purposes only. Not for production use.

---

**Last Updated:** November 17, 2025
**Version:** 1.0
