import Testing
import Foundation
@testable import CityBuilderTabletop

/// Unit tests for GameState
@Suite("GameState Tests")
struct GameStateTests {

    @Test("GameState initializes with empty city")
    func testInitialization() {
        let gameState = GameState()

        #expect(gameState.cityData.buildings.isEmpty)
        #expect(gameState.cityData.citizens.isEmpty)
        #expect(gameState.gameTime == 0)
    }

    @Test("GameState initializes with provided city data")
    func testInitializationWithCityData() {
        let cityData = CityData(name: "Test City")
        let gameState = GameState(cityData: cityData)

        #expect(gameState.cityData.name == "Test City")
    }

    @Test("GameState updates game time correctly")
    func testGameTimeUpdate() {
        let gameState = GameState()

        let initialTime = gameState.gameTime

        gameState.updateTime(deltaTime: 1.0, speedMultiplier: 1.0)

        #expect(gameState.gameTime == initialTime + 1.0)
    }

    @Test("GameState respects speed multiplier")
    func testGameTimeSpeedMultiplier() {
        let gameState = GameState()

        gameState.updateTime(deltaTime: 1.0, speedMultiplier: 2.0)

        #expect(gameState.gameTime == 2.0)
    }

    @Test("GameState adds buildings correctly")
    func testAddBuilding() {
        let gameState = GameState()

        let building = Building(
            type: .residential(.smallHouse),
            position: SIMD3(0, 0, 0)
        )

        gameState.addBuilding(building)

        #expect(gameState.cityData.buildings.count == 1)
        #expect(gameState.cityData.buildings.first?.id == building.id)
    }

    @Test("GameState removes buildings correctly")
    func testRemoveBuilding() {
        let gameState = GameState()

        let building = Building(
            type: .residential(.smallHouse),
            position: SIMD3(0, 0, 0)
        )

        gameState.addBuilding(building)
        #expect(gameState.cityData.buildings.count == 1)

        gameState.removeBuilding(id: building.id)
        #expect(gameState.cityData.buildings.isEmpty)
    }

    @Test("GameState adds roads correctly")
    func testAddRoad() {
        let gameState = GameState()

        let road = Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(0.1, 0, 0)
        ])

        gameState.addRoad(road)

        #expect(gameState.cityData.roads.count == 1)
        #expect(gameState.cityData.roads.first?.id == road.id)
    }

    @Test("GameState removes roads correctly")
    func testRemoveRoad() {
        let gameState = GameState()

        let road = Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(0.1, 0, 0)
        ])

        gameState.addRoad(road)
        #expect(gameState.cityData.roads.count == 1)

        gameState.removeRoad(id: road.id)
        #expect(gameState.cityData.roads.isEmpty)
    }

    @Test("GameState adds zones correctly")
    func testAddZone() {
        let gameState = GameState()

        let zone = Zone(
            zoneType: .residential,
            area: [SIMD2(0, 0), SIMD2(0.1, 0), SIMD2(0.1, 0.1), SIMD2(0, 0.1)]
        )

        gameState.addZone(zone)

        #expect(gameState.cityData.zones.count == 1)
        #expect(gameState.cityData.zones.first?.id == zone.id)
    }

    @Test("GameState removes zones correctly")
    func testRemoveZone() {
        let gameState = GameState()

        let zone = Zone(
            zoneType: .residential,
            area: [SIMD2(0, 0), SIMD2(0.1, 0), SIMD2(0.1, 0.1), SIMD2(0, 0.1)]
        )

        gameState.addZone(zone)
        #expect(gameState.cityData.zones.count == 1)

        gameState.removeZone(id: zone.id)
        #expect(gameState.cityData.zones.isEmpty)
    }

    @Test("GameState adds citizens correctly")
    func testAddCitizen() {
        let gameState = GameState()

        let citizen = Citizen(name: "Test Citizen", age: 30)

        gameState.addCitizen(citizen)

        #expect(gameState.cityData.citizens.count == 1)
        #expect(gameState.cityData.citizens.first?.id == citizen.id)
    }

    @Test("GameState removes citizens correctly")
    func testRemoveCitizen() {
        let gameState = GameState()

        let citizen = Citizen(name: "Test Citizen", age: 30)

        gameState.addCitizen(citizen)
        #expect(gameState.cityData.citizens.count == 1)

        gameState.removeCitizen(id: citizen.id)
        #expect(gameState.cityData.citizens.isEmpty)
    }

    @Test("GameState updates statistics when adding citizens")
    func testUpdateStatisticsOnAddCitizen() {
        let gameState = GameState()

        let citizen1 = Citizen(name: "Alice", age: 30, happiness: 0.8)
        let citizen2 = Citizen(name: "Bob", age: 25, happiness: 0.6)

        gameState.addCitizen(citizen1)
        gameState.addCitizen(citizen2)

        #expect(gameState.cityData.statistics.population == 2)
        #expect(gameState.cityData.statistics.averageHappiness == 0.7)
    }

    @Test("GameState adds vehicles correctly")
    func testAddVehicle() {
        let gameState = GameState()

        let vehicle = Vehicle(vehicleType: .car)

        gameState.addVehicle(vehicle)

        #expect(gameState.cityData.vehicles.count == 1)
        #expect(gameState.cityData.vehicles.first?.id == vehicle.id)
    }

    @Test("GameState removes vehicles correctly")
    func testRemoveVehicle() {
        let gameState = GameState()

        let vehicle = Vehicle(vehicleType: .car)

        gameState.addVehicle(vehicle)
        #expect(gameState.cityData.vehicles.count == 1)

        gameState.removeVehicle(id: vehicle.id)
        #expect(gameState.cityData.vehicles.isEmpty)
    }

    @Test("GameState updates economy correctly")
    func testUpdateEconomy() {
        let gameState = GameState()

        let initialTreasury = gameState.cityData.economy.treasury

        gameState.updateEconomy(income: 1000, expenses: 300)

        #expect(gameState.cityData.economy.income == 1000)
        #expect(gameState.cityData.economy.expenses == 300)
        #expect(gameState.cityData.economy.treasury == initialTreasury + 700)
    }

    @Test("GameState checks affordability correctly")
    func testCanAfford() {
        let gameState = GameState()

        // Should be able to afford (starting treasury is 50000)
        #expect(gameState.canAfford(1000))

        // Should not be able to afford
        #expect(!gameState.canAfford(100000))
    }

    @Test("GameState spending works correctly")
    func testSpend() {
        let gameState = GameState()

        let initialTreasury = gameState.cityData.economy.treasury

        let success = gameState.spend(1000)

        #expect(success)
        #expect(gameState.cityData.economy.treasury == initialTreasury - 1000)
    }

    @Test("GameState prevents spending more than available")
    func testSpendInsufficientFunds() {
        let gameState = GameState()

        let initialTreasury = gameState.cityData.economy.treasury

        let success = gameState.spend(100000)

        #expect(!success)
        #expect(gameState.cityData.economy.treasury == initialTreasury)
    }

    @Test("GameState adds funds correctly")
    func testAddFunds() {
        let gameState = GameState()

        let initialTreasury = gameState.cityData.economy.treasury

        gameState.addFunds(5000)

        #expect(gameState.cityData.economy.treasury == initialTreasury + 5000)
    }
}

/// Unit tests for GameCoordinator
@Suite("GameCoordinator Tests")
struct GameCoordinatorTests {

    @Test("GameCoordinator initializes correctly")
    func testInitialization() {
        let coordinator = GameCoordinator()

        #expect(coordinator.currentPhase == .startup)
        #expect(coordinator.simulationSpeed == .normal)
        #expect(!coordinator.isPaused)
        #expect(coordinator.selectedTool == nil)
    }

    @Test("GameCoordinator starts new city correctly")
    func testStartNewCity() {
        let coordinator = GameCoordinator()

        coordinator.startNewCity(name: "New City")

        #expect(coordinator.gameState.cityData.name == "New City")
        #expect(coordinator.currentPhase == .surfaceDetection)
    }

    @Test("GameCoordinator loads city correctly")
    func testLoadCity() {
        let coordinator = GameCoordinator()

        let cityData = CityData(name: "Loaded City")
        coordinator.loadCity(cityData)

        #expect(coordinator.gameState.cityData.name == "Loaded City")
        #expect(coordinator.currentPhase == .simulation)
    }

    @Test("GameCoordinator transitions phases correctly")
    func testPhaseTransition() {
        let coordinator = GameCoordinator()

        coordinator.transitionToPhase(.cityPlanning)

        #expect(coordinator.currentPhase == .cityPlanning)
    }

    @Test("GameCoordinator toggles pause correctly")
    func testTogglePause() {
        let coordinator = GameCoordinator()

        #expect(!coordinator.isPaused)

        coordinator.togglePause()
        #expect(coordinator.isPaused)

        coordinator.togglePause()
        #expect(!coordinator.isPaused)
    }

    @Test("GameCoordinator sets simulation speed correctly")
    func testSetSimulationSpeed() {
        let coordinator = GameCoordinator()

        coordinator.setSimulationSpeed(.fast)

        #expect(coordinator.simulationSpeed == .fast)
    }

    @Test("GameCoordinator selects tool correctly")
    func testSelectTool() {
        let coordinator = GameCoordinator()

        coordinator.selectTool(.road)

        #expect(coordinator.selectedTool == .road)
    }

    @Test("GameCoordinator deselects tool correctly")
    func testDeselectTool() {
        let coordinator = GameCoordinator()

        coordinator.selectTool(.road)
        #expect(coordinator.selectedTool != nil)

        coordinator.deselectTool()
        #expect(coordinator.selectedTool == nil)
    }
}

/// Unit tests for SimulationSpeed
@Suite("SimulationSpeed Tests")
struct SimulationSpeedTests {

    @Test("SimulationSpeed provides correct multipliers")
    func testSpeedMultipliers() {
        #expect(SimulationSpeed.paused.rawValue == 0.0)
        #expect(SimulationSpeed.slow.rawValue == 0.5)
        #expect(SimulationSpeed.normal.rawValue == 1.0)
        #expect(SimulationSpeed.fast.rawValue == 2.0)
        #expect(SimulationSpeed.ultraFast.rawValue == 5.0)
    }

    @Test("SimulationSpeed provides correct display names")
    func testSpeedDisplayNames() {
        #expect(SimulationSpeed.paused.displayName == "Paused")
        #expect(SimulationSpeed.normal.displayName == "Normal (1x)")
        #expect(SimulationSpeed.fast.displayName == "Fast (2x)")
    }
}
