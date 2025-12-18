import XCTest
@testable import LivingBuildingSystem

final class UserTests: XCTestCase {

    // MARK: - Initialization Tests

    func testUserInitialization() {
        let user = User(name: "John Doe")

        XCTAssertNotNil(user.id)
        XCTAssertEqual(user.name, "John Doe")
        XCTAssertEqual(user.role, .member) // Default role
        XCTAssertNil(user.faceIDData)
        XCTAssertNil(user.avatarImage)
        XCTAssertNotNil(user.createdAt)
    }

    func testUserInitializationWithRole() {
        let user = User(name: "Jane Smith", role: .owner)

        XCTAssertEqual(user.name, "Jane Smith")
        XCTAssertEqual(user.role, .owner)
    }

    // MARK: - User Role Tests

    func testAllUserRoles() {
        let roles: [UserRole] = [.owner, .admin, .member, .guest]

        for role in roles {
            let user = User(name: "Test User", role: role)
            XCTAssertEqual(user.role, role)
        }
    }

    func testOwnerRole() {
        let user = User(name: "Owner", role: .owner)

        XCTAssertEqual(user.role, .owner)
        XCTAssertEqual(user.role.rawValue, "owner")
    }

    func testAdminRole() {
        let user = User(name: "Admin", role: .admin)

        XCTAssertEqual(user.role, .admin)
        XCTAssertEqual(user.role.rawValue, "admin")
    }

    func testMemberRole() {
        let user = User(name: "Member", role: .member)

        XCTAssertEqual(user.role, .member)
        XCTAssertEqual(user.role.rawValue, "member")
    }

    func testGuestRole() {
        let user = User(name: "Guest", role: .guest)

        XCTAssertEqual(user.role, .guest)
        XCTAssertEqual(user.role.rawValue, "guest")
    }

    // MARK: - Home Relationship Tests

    func testUserBelongsToHome() {
        let home = Home(name: "Test Home")
        let user = User(name: "Test User")

        home.users.append(user)
        user.home = home

        XCTAssertNotNil(user.home)
        XCTAssertEqual(user.home?.name, "Test Home")
    }

    func testMultipleUsersInHome() {
        let home = Home(name: "Family Home")

        let owner = User(name: "Owner", role: .owner)
        let member1 = User(name: "Member 1", role: .member)
        let member2 = User(name: "Member 2", role: .member)

        home.users = [owner, member1, member2]

        XCTAssertEqual(home.users.count, 3)
        XCTAssertEqual(home.users.filter { $0.role == .owner }.count, 1)
        XCTAssertEqual(home.users.filter { $0.role == .member }.count, 2)
    }

    // MARK: - User Preferences Tests

    func testUserWithPreferences() {
        let user = User(name: "Test User")
        let preferences = UserPreferences()

        user.preferences = preferences
        preferences.user = user

        XCTAssertNotNil(user.preferences)
        XCTAssertEqual(user.preferences?.temperatureUnit, .fahrenheit)
    }

    func testCustomPreferences() {
        let user = User(name: "Test User")
        let preferences = UserPreferences()
        preferences.temperatureUnit = .celsius
        preferences.energyCostRate = 0.20
        preferences.waterCostRate = 0.01

        user.preferences = preferences

        XCTAssertEqual(user.preferences?.temperatureUnit, .celsius)
        XCTAssertEqual(user.preferences?.energyCostRate, 0.20)
        XCTAssertEqual(user.preferences?.waterCostRate, 0.01)
    }

    // MARK: - Face ID Tests

    func testSetFaceIDData() {
        let user = User(name: "Secure User")
        let faceData = Data([1, 2, 3, 4, 5])

        user.faceIDData = faceData

        XCTAssertNotNil(user.faceIDData)
        XCTAssertEqual(user.faceIDData, faceData)
    }

    func testRemoveFaceIDData() {
        let user = User(name: "Test User")
        user.faceIDData = Data([1, 2, 3])

        XCTAssertNotNil(user.faceIDData)

        user.faceIDData = nil

        XCTAssertNil(user.faceIDData)
    }

    // MARK: - Avatar Tests

    func testSetAvatarImage() {
        let user = User(name: "Test User")
        let avatarData = Data(repeating: 0xFF, count: 1000)

        user.avatarImage = avatarData

        XCTAssertNotNil(user.avatarImage)
        XCTAssertEqual(user.avatarImage?.count, 1000)
    }

    func testRemoveAvatarImage() {
        let user = User(name: "Test User")
        user.avatarImage = Data([1, 2, 3])

        XCTAssertNotNil(user.avatarImage)

        user.avatarImage = nil

        XCTAssertNil(user.avatarImage)
    }

    // MARK: - Timestamp Tests

    func testCreatedAtTimestamp() {
        let beforeCreation = Date()
        let user = User(name: "Test User")
        let afterCreation = Date()

        XCTAssertGreaterThanOrEqual(user.createdAt, beforeCreation)
        XCTAssertLessThanOrEqual(user.createdAt, afterCreation)
    }

    // MARK: - Complex Scenario Tests

    func testFullUserSetup() {
        let home = Home(name: "Smart Home")
        let user = User(name: "John Owner", role: .owner)

        // Set up preferences
        let preferences = UserPreferences()
        preferences.temperatureUnit = .fahrenheit
        preferences.energyCostRate = 0.15
        user.preferences = preferences

        // Set avatar
        user.avatarImage = Data(repeating: 0xAB, count: 500)

        // Associate with home
        home.users.append(user)
        user.home = home

        // Verify
        XCTAssertEqual(user.role, .owner)
        XCTAssertNotNil(user.preferences)
        XCTAssertNotNil(user.avatarImage)
        XCTAssertNotNil(user.home)
        XCTAssertEqual(user.home?.name, "Smart Home")
        XCTAssertEqual(user.preferences?.energyCostRate, 0.15)
    }

    // MARK: - Role Permission Scenarios

    func testOwnerHasFullAccess() {
        let user = User(name: "Owner", role: .owner)

        // Owner should have highest privileges
        XCTAssertEqual(user.role, .owner)

        // In real implementation, owner would have all permissions
        let hasFullAccess = user.role == .owner
        XCTAssertTrue(hasFullAccess)
    }

    func testGuestHasLimitedAccess() {
        let user = User(name: "Guest", role: .guest)

        // Guest should have lowest privileges
        XCTAssertEqual(user.role, .guest)

        // In real implementation, guest would have limited permissions
        let hasFullAccess = user.role == .owner || user.role == .admin
        XCTAssertFalse(hasFullAccess)
    }

    // MARK: - Edge Cases

    func testEmptyUserName() {
        let user = User(name: "")

        XCTAssertEqual(user.name, "")
        XCTAssertNotNil(user.id)
    }

    func testVeryLongUserName() {
        let longName = String(repeating: "A", count: 500)
        let user = User(name: longName)

        XCTAssertEqual(user.name.count, 500)
    }

    func testSpecialCharactersInName() {
        let user = User(name: "José María @#$% 👤")

        XCTAssertEqual(user.name, "José María @#$% 👤")
    }

    func testUnicodeUserName() {
        let user = User(name: "山田太郎")

        XCTAssertEqual(user.name, "山田太郎")
    }

    // MARK: - Role Change Tests

    func testChangeUserRole() {
        let user = User(name: "Test User", role: .member)

        XCTAssertEqual(user.role, .member)

        user.role = .admin

        XCTAssertEqual(user.role, .admin)
    }

    func testPromoteToOwner() {
        let user = User(name: "User", role: .member)

        user.role = .owner

        XCTAssertEqual(user.role, .owner)
    }

    func testDemoteToGuest() {
        let user = User(name: "User", role: .admin)

        user.role = .guest

        XCTAssertEqual(user.role, .guest)
    }

    // MARK: - Multiple Homes Scenario

    func testUserCanSwitchHomes() {
        let home1 = Home(name: "Primary Home")
        let home2 = Home(name: "Vacation Home")
        let user = User(name: "User", role: .owner)

        // Associate with first home
        user.home = home1
        XCTAssertEqual(user.home?.name, "Primary Home")

        // Switch to second home
        user.home = home2
        XCTAssertEqual(user.home?.name, "Vacation Home")
    }

    // MARK: - Data Privacy Tests

    func testFaceIDDataIsOptional() {
        let user = User(name: "Privacy User")

        // User without Face ID should work fine
        XCTAssertNil(user.faceIDData)
        XCTAssertNotNil(user.id)
        XCTAssertEqual(user.name, "Privacy User")
    }

    func testAvatarImageIsOptional() {
        let user = User(name: "No Avatar User")

        // User without avatar should work fine
        XCTAssertNil(user.avatarImage)
        XCTAssertNotNil(user.id)
        XCTAssertEqual(user.name, "No Avatar User")
    }
}
