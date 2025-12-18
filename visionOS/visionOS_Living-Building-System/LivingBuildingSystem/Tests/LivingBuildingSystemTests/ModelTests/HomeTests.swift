import XCTest
@testable import LivingBuildingSystem

final class HomeTests: XCTestCase {

    // MARK: - Initialization Tests

    func testHomeInitialization() {
        let home = Home(name: "Test Home")

        XCTAssertNotNil(home.id)
        XCTAssertEqual(home.name, "Test Home")
        XCTAssertNil(home.address)
        XCTAssertNotNil(home.createdAt)
        XCTAssertNotNil(home.updatedAt)
        XCTAssertEqual(home.timezone, .current)
        XCTAssertTrue(home.rooms.isEmpty)
        XCTAssertTrue(home.users.isEmpty)
    }

    func testHomeInitializationWithAddress() {
        let home = Home(name: "My Home", address: "123 Main St")

        XCTAssertEqual(home.name, "My Home")
        XCTAssertEqual(home.address, "123 Main St")
    }

    // MARK: - Relationship Tests

    func testAddRoomToHome() {
        let home = Home(name: "Test Home")
        let room = Room(name: "Living Room", roomType: .livingRoom)

        home.rooms.append(room)
        room.home = home

        XCTAssertEqual(home.rooms.count, 1)
        XCTAssertEqual(home.rooms.first?.name, "Living Room")
        XCTAssertEqual(room.home?.name, "Test Home")
    }

    func testAddMultipleRooms() {
        let home = Home(name: "Test Home")

        let livingRoom = Room(name: "Living Room", roomType: .livingRoom)
        let kitchen = Room(name: "Kitchen", roomType: .kitchen)
        let bedroom = Room(name: "Bedroom", roomType: .bedroom)

        home.rooms = [livingRoom, kitchen, bedroom]

        XCTAssertEqual(home.rooms.count, 3)
        XCTAssertTrue(home.rooms.contains { $0.name == "Living Room" })
        XCTAssertTrue(home.rooms.contains { $0.name == "Kitchen" })
        XCTAssertTrue(home.rooms.contains { $0.name == "Bedroom" })
    }

    func testAddUserToHome() {
        let home = Home(name: "Test Home")
        let user = User(name: "John Doe", role: .owner)

        home.users.append(user)
        user.home = home

        XCTAssertEqual(home.users.count, 1)
        XCTAssertEqual(home.users.first?.name, "John Doe")
        XCTAssertEqual(user.home?.name, "Test Home")
    }

    func testAddMultipleUsers() {
        let home = Home(name: "Test Home")

        let owner = User(name: "Owner", role: .owner)
        let admin = User(name: "Admin", role: .admin)
        let member = User(name: "Member", role: .member)

        home.users = [owner, admin, member]

        XCTAssertEqual(home.users.count, 3)
        XCTAssertTrue(home.users.contains { $0.role == .owner })
        XCTAssertTrue(home.users.contains { $0.role == .admin })
        XCTAssertTrue(home.users.contains { $0.role == .member })
    }

    // MARK: - Energy Configuration Tests

    func testHomeWithEnergyConfiguration() {
        let home = Home(name: "Test Home")
        let config = EnergyConfiguration()

        home.energyConfiguration = config

        XCTAssertNotNil(home.energyConfiguration)
        XCTAssertEqual(home.energyConfiguration?.electricityRatePerKWh, 0.15)
    }

    // MARK: - Timestamp Tests

    func testCreatedAtTimestamp() {
        let beforeCreation = Date()
        let home = Home(name: "Test Home")
        let afterCreation = Date()

        XCTAssertGreaterThanOrEqual(home.createdAt, beforeCreation)
        XCTAssertLessThanOrEqual(home.createdAt, afterCreation)
    }

    func testUpdatedAtTimestamp() {
        let home = Home(name: "Test Home")

        XCTAssertEqual(home.createdAt.timeIntervalSince1970,
                       home.updatedAt.timeIntervalSince1970,
                       accuracy: 0.001)
    }

    // MARK: - Timezone Tests

    func testDefaultTimezone() {
        let home = Home(name: "Test Home")

        XCTAssertEqual(home.timezone, .current)
    }

    func testCustomTimezone() {
        let home = Home(name: "Test Home")
        home.timezone = TimeZone(identifier: "America/New_York")!

        XCTAssertEqual(home.timezone.identifier, "America/New_York")
    }

    // MARK: - Preview Data Tests

    func testPreviewData() {
        let preview = Home.preview

        XCTAssertNotNil(preview.id)
        XCTAssertEqual(preview.name, "My Home")
        XCTAssertEqual(preview.address, "123 Main St")
        XCTAssertEqual(preview.rooms.count, 3)

        let roomTypes = Set(preview.rooms.map { $0.roomType })
        XCTAssertTrue(roomTypes.contains(.kitchen))
        XCTAssertTrue(roomTypes.contains(.livingRoom))
        XCTAssertTrue(roomTypes.contains(.bedroom))
    }

    // MARK: - Complex Scenario Tests

    func testFullHomeSetup() {
        let home = Home(name: "Smart Home", address: "456 Tech Lane")

        // Add rooms
        let livingRoom = Room(name: "Living Room", roomType: .livingRoom)
        let kitchen = Room(name: "Kitchen", roomType: .kitchen)
        home.rooms = [livingRoom, kitchen]

        // Add devices to rooms
        let light = SmartDevice(name: "Ceiling Light", deviceType: .light)
        livingRoom.devices.append(light)

        let thermostat = SmartDevice(name: "Smart Thermostat", deviceType: .thermostat)
        kitchen.devices.append(thermostat)

        // Add users
        let owner = User(name: "Owner", role: .owner)
        home.users.append(owner)

        // Add energy configuration
        let energyConfig = EnergyConfiguration()
        energyConfig.hasSmartMeter = true
        home.energyConfiguration = energyConfig

        // Verify
        XCTAssertEqual(home.rooms.count, 2)
        XCTAssertEqual(home.users.count, 1)
        XCTAssertNotNil(home.energyConfiguration)
        XCTAssertEqual(livingRoom.devices.count, 1)
        XCTAssertEqual(kitchen.devices.count, 1)
        XCTAssertTrue(home.energyConfiguration!.hasSmartMeter)
    }

    // MARK: - Edge Cases

    func testEmptyHomeName() {
        let home = Home(name: "")

        XCTAssertEqual(home.name, "")
        XCTAssertNotNil(home.id)
    }

    func testVeryLongHomeName() {
        let longName = String(repeating: "A", count: 1000)
        let home = Home(name: longName)

        XCTAssertEqual(home.name.count, 1000)
    }

    func testSpecialCharactersInName() {
        let home = Home(name: "🏠 My Smart Home! @#$%")

        XCTAssertEqual(home.name, "🏠 My Smart Home! @#$%")
    }

    func testUnicodeAddress() {
        let home = Home(name: "Home", address: "北京市朝阳区")

        XCTAssertEqual(home.address, "北京市朝阳区")
    }
}
