import XCTest
@testable import LivingBuildingSystem

final class RoomTests: XCTestCase {

    // MARK: - Initialization Tests

    func testRoomInitialization() {
        let room = Room(name: "Living Room", roomType: .livingRoom)

        XCTAssertNotNil(room.id)
        XCTAssertEqual(room.name, "Living Room")
        XCTAssertEqual(room.roomType, .livingRoom)
        XCTAssertEqual(room.floorLevel, 0)
        XCTAssertNil(room.squareFootage)
        XCTAssertNotNil(room.createdAt)
        XCTAssertNotNil(room.updatedAt)
        XCTAssertTrue(room.devices.isEmpty)
        XCTAssertTrue(room.anchors.isEmpty)
    }

    func testRoomInitializationWithFloorLevel() {
        let room = Room(name: "Bedroom", roomType: .bedroom, floorLevel: 2)

        XCTAssertEqual(room.floorLevel, 2)
    }

    // MARK: - Room Type Tests

    func testAllRoomTypes() {
        let types: [RoomType] = [
            .kitchen, .livingRoom, .bedroom, .bathroom,
            .office, .entryway, .hallway, .garage,
            .basement, .attic, .laundryRoom, .diningRoom, .other
        ]

        for type in types {
            let room = Room(name: "Test", roomType: type)
            XCTAssertEqual(room.roomType, type)
        }
    }

    // MARK: - Device Relationship Tests

    func testAddDeviceToRoom() {
        let room = Room(name: "Kitchen", roomType: .kitchen)
        let device = SmartDevice(name: "Smart Light", deviceType: .light)

        room.devices.append(device)
        device.room = room

        XCTAssertEqual(room.devices.count, 1)
        XCTAssertEqual(room.devices.first?.name, "Smart Light")
        XCTAssertEqual(device.room?.name, "Kitchen")
    }

    func testAddMultipleDevices() {
        let room = Room(name: "Living Room", roomType: .livingRoom)

        let light = SmartDevice(name: "Ceiling Light", deviceType: .light)
        let thermostat = SmartDevice(name: "Thermostat", deviceType: .thermostat)
        let speaker = SmartDevice(name: "Smart Speaker", deviceType: .speaker)

        room.devices = [light, thermostat, speaker]

        XCTAssertEqual(room.devices.count, 3)
        XCTAssertTrue(room.devices.contains { $0.deviceType == .light })
        XCTAssertTrue(room.devices.contains { $0.deviceType == .thermostat })
        XCTAssertTrue(room.devices.contains { $0.deviceType == .speaker })
    }

    func testRemoveDeviceFromRoom() {
        let room = Room(name: "Bedroom", roomType: .bedroom)
        let device = SmartDevice(name: "Lamp", deviceType: .light)

        room.devices.append(device)
        XCTAssertEqual(room.devices.count, 1)

        room.devices.removeAll { $0.id == device.id }
        XCTAssertEqual(room.devices.count, 0)
    }

    // MARK: - Spatial Anchor Tests

    func testAddAnchorToRoom() {
        let room = Room(name: "Living Room", roomType: .livingRoom)
        let position = SIMD3<Float>(1.0, 0.5, 2.0)
        let rotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
        let anchor = RoomAnchor(anchorType: .wallDisplay, position: position, rotation: rotation)

        room.anchors.append(anchor)
        anchor.room = room

        XCTAssertEqual(room.anchors.count, 1)
        XCTAssertEqual(room.anchors.first?.anchorType, .wallDisplay)
    }

    func testMultipleSpatialAnchors() {
        let room = Room(name: "Kitchen", roomType: .kitchen)

        let anchor1 = RoomAnchor(
            anchorType: .wallDisplay,
            position: SIMD3<Float>(1, 1, 1),
            rotation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
        )

        let anchor2 = RoomAnchor(
            anchorType: .deviceLocation,
            position: SIMD3<Float>(2, 0.5, 2),
            rotation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
        )

        room.anchors = [anchor1, anchor2]

        XCTAssertEqual(room.anchors.count, 2)
        XCTAssertTrue(room.anchors.contains { $0.anchorType == .wallDisplay })
        XCTAssertTrue(room.anchors.contains { $0.anchorType == .deviceLocation })
    }

    // MARK: - Square Footage Tests

    func testSetSquareFootage() {
        let room = Room(name: "Bedroom", roomType: .bedroom)
        room.squareFootage = 150.5

        XCTAssertEqual(room.squareFootage, 150.5)
    }

    func testVerySmallRoom() {
        let room = Room(name: "Closet", roomType: .other)
        room.squareFootage = 10.0

        XCTAssertEqual(room.squareFootage, 10.0)
    }

    func testVeryLargeRoom() {
        let room = Room(name: "Great Hall", roomType: .livingRoom)
        room.squareFootage = 5000.0

        XCTAssertEqual(room.squareFootage, 5000.0)
    }

    // MARK: - Floor Level Tests

    func testBasementRoom() {
        let room = Room(name: "Storage", roomType: .basement, floorLevel: -1)

        XCTAssertEqual(room.floorLevel, -1)
    }

    func testPenthouseRoom() {
        let room = Room(name: "Penthouse Lounge", roomType: .livingRoom, floorLevel: 30)

        XCTAssertEqual(room.floorLevel, 30)
    }

    // MARK: - Home Relationship Tests

    func testRoomBelongsToHome() {
        let home = Home(name: "Test Home")
        let room = Room(name: "Kitchen", roomType: .kitchen)

        home.rooms.append(room)
        room.home = home

        XCTAssertNotNil(room.home)
        XCTAssertEqual(room.home?.name, "Test Home")
    }

    // MARK: - Timestamp Tests

    func testCreatedAtTimestamp() {
        let beforeCreation = Date()
        let room = Room(name: "Test Room", roomType: .other)
        let afterCreation = Date()

        XCTAssertGreaterThanOrEqual(room.createdAt, beforeCreation)
        XCTAssertLessThanOrEqual(room.createdAt, afterCreation)
    }

    func testUpdatedAtTimestamp() {
        let room = Room(name: "Test Room", roomType: .other)

        XCTAssertEqual(room.createdAt.timeIntervalSince1970,
                       room.updatedAt.timeIntervalSince1970,
                       accuracy: 0.001)
    }

    // MARK: - Complex Scenario Tests

    func testFullRoomSetup() {
        let room = Room(name: "Smart Living Room", roomType: .livingRoom, floorLevel: 1)
        room.squareFootage = 250.0

        // Add devices
        let light1 = SmartDevice(name: "Ceiling Light 1", deviceType: .light)
        let light2 = SmartDevice(name: "Floor Lamp", deviceType: .light)
        let thermostat = SmartDevice(name: "Wall Thermostat", deviceType: .thermostat)
        room.devices = [light1, light2, thermostat]

        // Add spatial anchors
        let anchor = RoomAnchor(
            anchorType: .wallDisplay,
            position: SIMD3<Float>(1, 1.5, 2),
            rotation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
        )
        room.anchors.append(anchor)

        // Verify
        XCTAssertEqual(room.devices.count, 3)
        XCTAssertEqual(room.anchors.count, 1)
        XCTAssertEqual(room.squareFootage, 250.0)
        XCTAssertEqual(room.floorLevel, 1)

        // Count lights
        let lightCount = room.devices.filter { $0.deviceType == .light }.count
        XCTAssertEqual(lightCount, 2)
    }

    // MARK: - Edge Cases

    func testEmptyRoomName() {
        let room = Room(name: "", roomType: .other)

        XCTAssertEqual(room.name, "")
        XCTAssertNotNil(room.id)
    }

    func testVeryLongRoomName() {
        let longName = String(repeating: "A", count: 500)
        let room = Room(name: longName, roomType: .other)

        XCTAssertEqual(room.name.count, 500)
    }

    func testSpecialCharactersInRoomName() {
        let room = Room(name: "🏠 Master Bedroom & Bath #1", roomType: .bedroom)

        XCTAssertEqual(room.name, "🏠 Master Bedroom & Bath #1")
    }

    func testZeroSquareFootage() {
        let room = Room(name: "Test", roomType: .other)
        room.squareFootage = 0.0

        XCTAssertEqual(room.squareFootage, 0.0)
    }

    func testNegativeFloorLevel() {
        let room = Room(name: "Sub-basement", roomType: .basement, floorLevel: -3)

        XCTAssertEqual(room.floorLevel, -3)
    }

    // MARK: - Device Filtering Tests

    func testFilterDevicesByType() {
        let room = Room(name: "Kitchen", roomType: .kitchen)

        let light1 = SmartDevice(name: "Light 1", deviceType: .light)
        let light2 = SmartDevice(name: "Light 2", deviceType: .light)
        let outlet = SmartDevice(name: "Outlet", deviceType: .outlet)

        room.devices = [light1, light2, outlet]

        let lights = room.devices.filter { $0.deviceType == .light }
        XCTAssertEqual(lights.count, 2)

        let outlets = room.devices.filter { $0.deviceType == .outlet }
        XCTAssertEqual(outlets.count, 1)
    }

    func testFindDeviceByName() {
        let room = Room(name: "Bedroom", roomType: .bedroom)

        let targetDevice = SmartDevice(name: "Main Light", deviceType: .light)
        let otherDevice = SmartDevice(name: "Lamp", deviceType: .light)

        room.devices = [targetDevice, otherDevice]

        let found = room.devices.first { $0.name == "Main Light" }
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.id, targetDevice.id)
    }
}
