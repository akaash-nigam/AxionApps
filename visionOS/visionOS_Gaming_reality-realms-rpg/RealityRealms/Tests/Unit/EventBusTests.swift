//
//  EventBusTests.swift
//  Reality Realms RPG Tests
//
//  Unit tests for EventBus system
//

import XCTest
@testable import RealityRealms

@MainActor
final class EventBusTests: XCTestCase {

    var sut: EventBus!

    override func setUp() async throws {
        try await super.setUp()
        sut = EventBus.shared
        sut.clear()  // Clear any existing subscriptions
    }

    override func tearDown() async throws {
        sut.clear()
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Subscription Tests

    func testSubscribeToEvent() {
        let expectation = expectation(description: "Event received")
        var receivedEvent: LevelUpEvent?

        sut.subscribe(LevelUpEvent.self) { event in
            receivedEvent = event
            expectation.fulfill()
        }

        let testEvent = LevelUpEvent(
            playerID: UUID(),
            newLevel: 5,
            skillPointsGained: 3
        )

        sut.publish(testEvent)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertNotNil(receivedEvent)
        XCTAssertEqual(receivedEvent?.newLevel, 5)
        XCTAssertEqual(receivedEvent?.skillPointsGained, 3)
    }

    func testMultipleSubscribers() {
        let expectation1 = expectation(description: "Subscriber 1 received event")
        let expectation2 = expectation(description: "Subscriber 2 received event")

        var received1 = false
        var received2 = false

        sut.subscribe(LevelUpEvent.self) { _ in
            received1 = true
            expectation1.fulfill()
        }

        sut.subscribe(LevelUpEvent.self) { _ in
            received2 = true
            expectation2.fulfill()
        }

        let testEvent = LevelUpEvent(
            playerID: UUID(),
            newLevel: 5,
            skillPointsGained: 3
        )

        sut.publish(testEvent)

        wait(for: [expectation1, expectation2], timeout: 1.0)

        XCTAssertTrue(received1)
        XCTAssertTrue(received2)
    }

    func testPublishWithoutSubscribers() {
        // Should not crash
        let testEvent = LevelUpEvent(
            playerID: UUID(),
            newLevel: 5,
            skillPointsGained: 3
        )

        sut.publish(testEvent)

        // Test passes if no crash occurs
        XCTAssertTrue(true)
    }

    // MARK: - Different Event Types Tests

    func testDamageDealtEvent() {
        let expectation = expectation(description: "Damage event received")
        var receivedDamage: Int?

        sut.subscribe(DamageDealtEvent.self) { event in
            receivedDamage = event.damage
            expectation.fulfill()
        }

        let event = DamageDealtEvent(
            attackerID: UUID(),
            targetID: UUID(),
            damage: 50,
            damageType: .physical,
            isCritical: true
        )

        sut.publish(event)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(receivedDamage, 50)
    }

    func testQuestCompletedEvent() {
        let expectation = expectation(description: "Quest completed")
        var receivedRewards: [Reward]?

        sut.subscribe(QuestCompletedEvent.self) { event in
            receivedRewards = event.rewards
            expectation.fulfill()
        }

        let rewards: [Reward] = [
            Reward(type: .experience, amount: 100),
            Reward(type: .gold, amount: 50)
        ]

        let event = QuestCompletedEvent(
            questID: UUID(),
            rewards: rewards
        )

        sut.publish(event)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(receivedRewards?.count, 2)
    }

    // MARK: - Clear Tests

    func testClearRemovesAllSubscribers() {
        let expectation = expectation(description: "Event should not be received")
        expectation.isInverted = true

        sut.subscribe(LevelUpEvent.self) { _ in
            expectation.fulfill()
        }

        sut.clear()

        let testEvent = LevelUpEvent(
            playerID: UUID(),
            newLevel: 5,
            skillPointsGained: 3
        )

        sut.publish(testEvent)

        wait(for: [expectation], timeout: 0.5)
    }
}
