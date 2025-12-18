import XCTest
@testable import LivingBuildingSystem

final class SmartDeviceTests: XCTestCase {

    // MARK: - Initialization Tests

    func testDeviceInitialization() {
        let device = SmartDevice(name: "Living Room Light", deviceType: .light)

        XCTAssertNotNil(device.id)
        XCTAssertEqual(device.name, "Living Room Light")
        XCTAssertEqual(device.deviceType, .light)
        XCTAssertNil(device.manufacturer)
        XCTAssertNil(device.model)
        XCTAssertTrue(device.isReachable)
        XCTAssertNil(device.lastSeen)
        XCTAssertNil(device.batteryLevel)
        XCTAssertNotNil(device.createdAt)
        XCTAssertNotNil(device.updatedAt)
        XCTAssertTrue(device.capabilities.isEmpty)
    }

    // MARK: - Device Type Tests

    func testAllDeviceTypes() {
        let types: [DeviceType] = [
            .light, .switch_, .outlet, .thermostat, .lock,
            .camera, .speaker, .blind, .garageDoor, .sprinkler,
            .vacuum, .sensor, .fan, .airPurifier, .humidifier, .dehumidifier
        ]

        for type in types {
            let device = SmartDevice(name: "Test", deviceType: type)
            XCTAssertEqual(device.deviceType, type)
        }
    }

    // MARK: - Reachability Tests

    func testDeviceReachable() {
        let device = SmartDevice(name: "Test Device", deviceType: .light)

        XCTAssertTrue(device.isReachable)
    }

    func testDeviceUnreachable() {
        let device = SmartDevice(name: "Test Device", deviceType: .light)
        device.isReachable = false

        XCTAssertFalse(device.isReachable)
    }

    func testLastSeenTimestamp() {
        let device = SmartDevice(name: "Test Device", deviceType: .sensor)
        let lastSeen = Date()
        device.lastSeen = lastSeen

        XCTAssertEqual(device.lastSeen, lastSeen)
    }

    // MARK: - Battery Tests

    func testBatteryLevel() {
        let device = SmartDevice(name: "Battery Device", deviceType: .sensor)
        device.batteryLevel = 0.85

        XCTAssertEqual(device.batteryLevel, 0.85)
    }

    func testLowBattery() {
        let device = SmartDevice(name: "Low Battery Device", deviceType: .sensor)
        device.batteryLevel = 0.10

        XCTAssertLessThan(device.batteryLevel!, 0.20)
    }

    func testFullBattery() {
        let device = SmartDevice(name: "Full Battery Device", deviceType: .sensor)
        device.batteryLevel = 1.0

        XCTAssertEqual(device.batteryLevel, 1.0)
    }

    func testNoBatteryDevice() {
        let device = SmartDevice(name: "Wired Device", deviceType: .light)

        XCTAssertNil(device.batteryLevel)
    }

    // MARK: - Manufacturer and Model Tests

    func testSetManufacturer() {
        let device = SmartDevice(name: "Smart Bulb", deviceType: .light)
        device.manufacturer = "Philips"
        device.model = "Hue White A19"

        XCTAssertEqual(device.manufacturer, "Philips")
        XCTAssertEqual(device.model, "Hue White A19")
    }

    // MARK: - HomeKit Integration Tests

    func testHomeKitIdentifier() {
        let device = SmartDevice(name: "HomeKit Device", deviceType: .light)
        device.homeKitIdentifier = "HK-12345-ABCDE"

        XCTAssertEqual(device.homeKitIdentifier, "HK-12345-ABCDE")
    }

    func testMatterIdentifier() {
        let device = SmartDevice(name: "Matter Device", deviceType: .thermostat)
        device.matterIdentifier = "MTR-67890-FGHIJ"

        XCTAssertEqual(device.matterIdentifier, "MTR-67890-FGHIJ")
    }

    func testDualProtocolDevice() {
        let device = SmartDevice(name: "Hybrid Device", deviceType: .outlet)
        device.homeKitIdentifier = "HK-123"
        device.matterIdentifier = "MTR-456"

        XCTAssertNotNil(device.homeKitIdentifier)
        XCTAssertNotNil(device.matterIdentifier)
    }

    // MARK: - Room Relationship Tests

    func testDeviceInRoom() {
        let room = Room(name: "Kitchen", roomType: .kitchen)
        let device = SmartDevice(name: "Kitchen Light", deviceType: .light)

        room.devices.append(device)
        device.room = room

        XCTAssertNotNil(device.room)
        XCTAssertEqual(device.room?.name, "Kitchen")
    }

    // MARK: - Device State Tests

    func testDeviceWithState() {
        let device = SmartDevice(name: "Smart Light", deviceType: .light)
        let state = DeviceState()
        state.isOn = true
        state.brightness = 0.8

        device.currentState = state
        state.device = device

        XCTAssertNotNil(device.currentState)
        XCTAssertEqual(device.currentState?.isOn, true)
        XCTAssertEqual(device.currentState?.brightness, 0.8)
    }

    // MARK: - Capabilities Tests

    func testAddSingleCapability() {
        let device = SmartDevice(name: "Smart Light", deviceType: .light)
        device.capabilities = [.onOff]

        XCTAssertEqual(device.capabilities.count, 1)
        XCTAssertTrue(device.capabilities.contains(.onOff))
    }

    func testAddMultipleCapabilities() {
        let device = SmartDevice(name: "Advanced Light", deviceType: .light)
        device.capabilities = [.onOff, .brightness, .colorTemperature, .rgbColor]

        XCTAssertEqual(device.capabilities.count, 4)
        XCTAssertTrue(device.capabilities.contains(.onOff))
        XCTAssertTrue(device.capabilities.contains(.brightness))
        XCTAssertTrue(device.capabilities.contains(.colorTemperature))
        XCTAssertTrue(device.capabilities.contains(.rgbColor))
    }

    func testThermostatCapabilities() {
        let device = SmartDevice(name: "Smart Thermostat", deviceType: .thermostat)
        device.capabilities = [.temperature, .targetTemperature, .humidity]

        XCTAssertTrue(device.capabilities.contains(.temperature))
        XCTAssertTrue(device.capabilities.contains(.targetTemperature))
        XCTAssertTrue(device.capabilities.contains(.humidity))
    }

    func testLockCapabilities() {
        let device = SmartDevice(name: "Smart Lock", deviceType: .lock)
        device.capabilities = [.lock]

        XCTAssertTrue(device.capabilities.contains(.lock))
    }

    func testSensorCapabilities() {
        let device = SmartDevice(name: "Multi-Sensor", deviceType: .sensor)
        device.capabilities = [.temperature, .humidity, .motionDetection, .contactSensor]

        XCTAssertEqual(device.capabilities.count, 4)
    }

    // MARK: - Device Groups Tests

    func testDeviceInGroup() {
        let device = SmartDevice(name: "Light", deviceType: .light)
        let group = DeviceGroup(name: "Living Room Lights", groupType: .room)

        group.devices.append(device)
        device.groups.append(group)

        XCTAssertEqual(device.groups.count, 1)
        XCTAssertEqual(device.groups.first?.name, "Living Room Lights")
    }

    func testDeviceInMultipleGroups() {
        let device = SmartDevice(name: "Light", deviceType: .light)

        let roomGroup = DeviceGroup(name: "Bedroom Devices", groupType: .room)
        let typeGroup = DeviceGroup(name: "All Lights", groupType: .type)
        let customGroup = DeviceGroup(name: "Evening Scene", groupType: .custom)

        device.groups = [roomGroup, typeGroup, customGroup]

        XCTAssertEqual(device.groups.count, 3)
    }

    // MARK: - Complex Scenario Tests

    func testFullDeviceSetup() {
        let device = SmartDevice(name: "Philips Hue Color", deviceType: .light)
        device.manufacturer = "Philips"
        device.model = "Hue Color A19"
        device.homeKitIdentifier = "HK-PHI-001"
        device.isReachable = true
        device.capabilities = [.onOff, .brightness, .colorTemperature, .rgbColor]

        let state = DeviceState()
        state.isOn = true
        state.brightness = 0.75
        state.colorTemperature = 4000
        device.currentState = state

        let room = Room(name: "Living Room", roomType: .livingRoom)
        device.room = room

        // Verify
        XCTAssertEqual(device.name, "Philips Hue Color")
        XCTAssertEqual(device.manufacturer, "Philips")
        XCTAssertEqual(device.capabilities.count, 4)
        XCTAssertTrue(device.isReachable)
        XCTAssertNotNil(device.currentState)
        XCTAssertEqual(device.currentState?.brightness, 0.75)
        XCTAssertNotNil(device.room)
    }

    // MARK: - Preview Data Tests

    func testPreviewLight() {
        let preview = SmartDevice.previewLight

        XCTAssertEqual(preview.deviceType, .light)
        XCTAssertNotNil(preview.currentState)
        XCTAssertEqual(preview.supportsOnOff, true)
        XCTAssertEqual(preview.supportsBrightness, true)
    }

    func testPreviewThermostat() {
        let preview = SmartDevice.previewThermostat

        XCTAssertEqual(preview.deviceType, .thermostat)
        XCTAssertNotNil(preview.currentState)
        XCTAssertEqual(preview.supportsTemperature, true)
    }

    func testPreviewSwitch() {
        let preview = SmartDevice.previewSwitch

        XCTAssertEqual(preview.deviceType, .switch_)
        XCTAssertNotNil(preview.currentState)
    }

    // MARK: - Support Flags Tests

    func testSupportsOnOff() {
        let light = SmartDevice(name: "Light", deviceType: .light)
        light.capabilities = [.onOff]

        XCTAssertTrue(light.supportsOnOff)
    }

    func testSupportsBrightness() {
        let light = SmartDevice(name: "Dimmable Light", deviceType: .light)
        light.capabilities = [.brightness]

        XCTAssertTrue(light.supportsBrightness)
    }

    func testSupportsTemperature() {
        let thermostat = SmartDevice(name: "Thermostat", deviceType: .thermostat)
        thermostat.capabilities = [.temperature, .targetTemperature]

        XCTAssertTrue(thermostat.supportsTemperature)
    }

    func testDoesNotSupportBrightness() {
        let switch_ = SmartDevice(name: "Switch", deviceType: .switch_)
        switch_.capabilities = [.onOff]

        XCTAssertFalse(switch_.supportsBrightness)
    }

    // MARK: - Edge Cases

    func testEmptyDeviceName() {
        let device = SmartDevice(name: "", deviceType: .light)

        XCTAssertEqual(device.name, "")
        XCTAssertNotNil(device.id)
    }

    func testVeryLongDeviceName() {
        let longName = String(repeating: "A", count: 500)
        let device = SmartDevice(name: longName, deviceType: .light)

        XCTAssertEqual(device.name.count, 500)
    }

    func testSpecialCharactersInName() {
        let device = SmartDevice(name: "💡 Living Room Light #1 @Home", deviceType: .light)

        XCTAssertEqual(device.name, "💡 Living Room Light #1 @Home")
    }

    func testBatteryLevelBounds() {
        let device = SmartDevice(name: "Sensor", deviceType: .sensor)

        // Test valid range
        device.batteryLevel = 0.0
        XCTAssertEqual(device.batteryLevel, 0.0)

        device.batteryLevel = 1.0
        XCTAssertEqual(device.batteryLevel, 1.0)

        device.batteryLevel = 0.5
        XCTAssertEqual(device.batteryLevel, 0.5)
    }

    // MARK: - Timestamp Tests

    func testCreatedAtTimestamp() {
        let beforeCreation = Date()
        let device = SmartDevice(name: "Test Device", deviceType: .light)
        let afterCreation = Date()

        XCTAssertGreaterThanOrEqual(device.createdAt, beforeCreation)
        XCTAssertLessThanOrEqual(device.createdAt, afterCreation)
    }

    func testUpdatedAtTimestamp() {
        let device = SmartDevice(name: "Test Device", deviceType: .light)

        XCTAssertEqual(device.createdAt.timeIntervalSince1970,
                       device.updatedAt.timeIntervalSince1970,
                       accuracy: 0.001)
    }

    // MARK: - Device State Consistency Tests

    func testDeviceStateRelationship() {
        let device = SmartDevice(name: "Light", deviceType: .light)
        let state = DeviceState()

        device.currentState = state
        state.device = device

        XCTAssertNotNil(device.currentState)
        XCTAssertEqual(state.device?.id, device.id)
    }

    func testReplaceDeviceState() {
        let device = SmartDevice(name: "Light", deviceType: .light)

        let oldState = DeviceState()
        oldState.isOn = false
        device.currentState = oldState

        XCTAssertEqual(device.currentState?.isOn, false)

        let newState = DeviceState()
        newState.isOn = true
        device.currentState = newState

        XCTAssertEqual(device.currentState?.isOn, true)
    }
}
