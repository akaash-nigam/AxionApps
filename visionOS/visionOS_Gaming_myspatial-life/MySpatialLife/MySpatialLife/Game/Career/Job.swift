import Foundation

/// Represents a job/career for a character
struct Job: Codable, Identifiable {
    let id: UUID
    let careerPath: CareerPath
    var level: Int
    var performance: Float  // 0.0 - 1.0
    var daysWorked: Int

    var salary: Int {
        careerPath.salaryForLevel(level)
    }

    var title: String {
        careerPath.titleForLevel(level)
    }

    var workHoursPerWeek: Int {
        careerPath.hoursPerWeek
    }

    init(
        id: UUID = UUID(),
        careerPath: CareerPath,
        level: Int = 1,
        performance: Float = 0.5,
        daysWorked: Int = 0
    ) {
        self.id = id
        self.careerPath = careerPath
        self.level = min(level, careerPath.maxLevel)
        self.performance = max(0.0, min(1.0, performance))
        self.daysWorked = daysWorked
    }

    /// Attempt to get promoted
    mutating func tryPromotion() -> Bool {
        guard level < careerPath.maxLevel else { return false }
        guard performance > careerPath.promotionThreshold else { return false }

        level += 1
        performance = 0.5  // Reset performance for new level
        return true
    }

    /// Work for a day (updates performance)
    mutating func workDay(quality: Float) {
        daysWorked += 1

        // Quality affects performance
        let performanceChange = (quality - 0.5) * 0.1
        performance = max(0.0, min(1.0, performance + performanceChange))
    }

    /// Get fired
    func getFired() {
        // Job is removed, handled by caller
    }
}

/// Career paths available in the game
enum CareerPath: String, Codable, CaseIterable {
    case culinary
    case tech
    case medical
    case business
    case creative
    case education
    case athletic
    case science

    var maxLevel: Int {
        switch self {
        case .culinary, .tech, .medical, .business:
            return 10
        case .creative, .education, .athletic, .science:
            return 8
        }
    }

    var hoursPerWeek: Int {
        switch self {
        case .business, .medical, .tech:
            return 50  // Demanding careers
        case .culinary, .creative, .science:
            return 40  // Standard
        case .education, .athletic:
            return 35  // More flexible
        }
    }

    var promotionThreshold: Float {
        0.7  // Need 70% performance to promote
    }

    func titleForLevel(_ level: Int) -> String {
        switch self {
        case .culinary:
            return [
                "Dishwasher", "Line Cook", "Sous Chef", "Head Chef",
                "Executive Chef", "Restaurant Manager", "Culinary Director",
                "Celebrity Chef", "Restaurant Owner", "Culinary Empire Owner"
            ][min(level - 1, 9)]

        case .tech:
            return [
                "Junior Developer", "Developer", "Senior Developer", "Team Lead",
                "Engineering Manager", "Director of Engineering", "VP of Engineering",
                "CTO", "Tech Founder", "Tech CEO"
            ][min(level - 1, 9)]

        case .medical:
            return [
                "Medical Student", "Intern", "Resident", "Doctor",
                "Senior Doctor", "Specialist", "Chief of Medicine",
                "Hospital Director", "Medical Research Lead", "Surgeon General"
            ][min(level - 1, 9)]

        case .business:
            return [
                "Intern", "Assistant", "Associate", "Manager",
                "Senior Manager", "Director", "VP",
                "SVP", "C-Suite Executive", "CEO"
            ][min(level - 1, 9)]

        case .creative:
            return [
                "Freelancer", "Junior Artist", "Artist", "Senior Artist",
                "Lead Artist", "Art Director", "Creative Director",
                "Famous Artist"
            ][min(level - 1, 7)]

        case .education:
            return [
                "Teacher's Aide", "Teacher", "Senior Teacher", "Department Head",
                "Vice Principal", "Principal", "Superintendent",
                "Education Director"
            ][min(level - 1, 7)]

        case .athletic:
            return [
                "Amateur", "Semi-Pro", "Professional", "All-Star",
                "Team Captain", "MVP", "Hall of Famer",
                "Legend"
            ][min(level - 1, 7)]

        case .science:
            return [
                "Lab Assistant", "Researcher", "Senior Researcher", "Lead Scientist",
                "Principal Investigator", "Research Director", "Chief Scientist",
                "Nobel Laureate"
            ][min(level - 1, 7)]
        }
    }

    func salaryForLevel(_ level: Int) -> Int {
        switch self {
        case .tech, .business, .medical:
            // High-paying careers
            return [
                30000, 50000, 75000, 100000, 150000,
                200000, 300000, 500000, 750000, 1000000
            ][min(level - 1, 9)]

        case .culinary, .creative, .science:
            // Medium-paying careers
            return [
                25000, 40000, 60000, 85000, 120000,
                180000, 250000, 350000, 500000, 750000
            ][min(level - 1, 9)]

        case .education, .athletic:
            // Variable-paying careers
            return [
                28000, 45000, 65000, 90000, 130000,
                200000, 400000, 1000000
            ][min(level - 1, 7)]
        }
    }

    /// Skills that benefit this career
    var relevantSkills: [Skill] {
        switch self {
        case .culinary:
            return [.cooking, .charisma]
        case .tech:
            return [.programming, .logic]
        case .medical:
            return [.logic, .science, .charisma]
        case .business:
            return [.charisma, .logic]
        case .creative:
            return [.painting, .writing, .music]
        case .education:
            return [.charisma, .logic]
        case .athletic:
            return [.fitness, .sports]
        case .science:
            return [.science, .logic]
        }
    }
}
