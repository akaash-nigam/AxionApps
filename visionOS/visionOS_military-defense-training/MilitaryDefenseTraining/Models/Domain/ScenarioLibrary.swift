//
//  ScenarioLibrary.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation

extension Scenario {
    // MARK: - Predefined Scenarios

    static let hostageRescue = Scenario(
        name: "Hostage Rescue",
        type: .hostageRescue,
        difficulty: .expert,
        durationMinutes: 30,
        scenarioDescription: "Infiltrate enemy compound and extract hostages with minimal casualties",
        objectives: [
            "Breach compound perimeter",
            "Neutralize guards silently",
            "Locate and secure hostages",
            "Exfiltrate to extraction point"
        ],
        enemyCount: 25,
        environment: .urban,
        classification: .secret,
        isDownloaded: true
    )

    static let nightOperation = Scenario(
        name: "Night Raid",
        type: .urbanAssault,
        difficulty: .hard,
        durationMinutes: 40,
        scenarioDescription: "Conduct nighttime assault on enemy position using night vision",
        objectives: [
            "Infiltrate under cover of darkness",
            "Eliminate HVT",
            "Destroy weapons cache",
            "Extract before sunrise"
        ],
        enemyCount: 30,
        environment: .desert,
        classification: .confidential,
        isDownloaded: true
    )

    static let reconMission = Scenario(
        name: "Reconnaissance",
        type: .reconnaissance,
        difficulty: .medium,
        durationMinutes: 25,
        scenarioDescription: "Observe and report enemy movements without being detected",
        objectives: [
            "Reach observation point",
            "Identify enemy units",
            "Document enemy positions",
            "Exfiltrate undetected"
        ],
        enemyCount: 15,
        environment: .mountain,
        classification: .secret,
        isDownloaded: true
    )

    static let convoyAmbush = Scenario(
        name: "Convoy Escort",
        type: .convoyEscort,
        difficulty: .hard,
        durationMinutes: 35,
        scenarioDescription: "Protect supply convoy from ambush through hostile territory",
        objectives: [
            "Escort convoy to checkpoint Alpha",
            "Eliminate ambush threats",
            "Maintain convoy integrity",
            "Reach destination with minimal losses"
        ],
        enemyCount: 35,
        environment: .desert,
        classification: .cui,
        isDownloaded: true
    )

    static let defensivePosition = Scenario(
        name: "Hold The Line",
        type: .defensivePosition,
        difficulty: .hard,
        durationMinutes: 45,
        scenarioDescription: "Defend outpost against waves of enemy attacks",
        objectives: [
            "Fortify defensive positions",
            "Repel first wave",
            "Repel second wave",
            "Hold position until reinforcements arrive"
        ],
        enemyCount: 50,
        environment: .desert,
        classification: .confidential,
        isDownloaded: true
    )

    static let mountainInfiltration = Scenario(
        name: "Mountain Pass",
        type: .mountainOperations,
        difficulty: .expert,
        durationMinutes: 50,
        scenarioDescription: "Navigate treacherous mountain terrain and eliminate enemy stronghold",
        objectives: [
            "Climb to high ground",
            "Neutralize lookout posts",
            "Assault main compound",
            "Secure strategic position"
        ],
        enemyCount: 28,
        environment: .mountain,
        classification: .secret,
        isDownloaded: true
    )

    static let maritimeAssault = Scenario(
        name: "Beach Landing",
        type: .maritimeAssault,
        difficulty: .expert,
        durationMinutes: 35,
        scenarioDescription: "Amphibious assault on fortified beach position",
        objectives: [
            "Secure beachhead",
            "Clear bunkers",
            "Advance inland",
            "Establish perimeter"
        ],
        enemyCount: 40,
        environment: .maritime,
        classification: .secret,
        isDownloaded: true
    )

    // MARK: - Training Scenarios

    static let basicCQB = Scenario(
        name: "CQB Basics",
        type: .buildingClearance,
        difficulty: .easy,
        durationMinutes: 15,
        scenarioDescription: "Learn close quarters battle fundamentals",
        objectives: [
            "Clear first room",
            "Clear second room",
            "Clear hallway",
            "Complete building clearance"
        ],
        enemyCount: 6,
        environment: .urban,
        classification: .unclassified,
        isDownloaded: true
    )

    static let marksmanship = Scenario(
        name: "Marksmanship Range",
        type: .reconnaissance,
        difficulty: .easy,
        durationMinutes: 20,
        scenarioDescription: "Improve accuracy with various weapon systems",
        objectives: [
            "Hit 10 static targets",
            "Hit 10 moving targets",
            "Hit 5 long-range targets",
            "Qualify expert"
        ],
        enemyCount: 0,
        environment: .desert,
        classification: .unclassified,
        isDownloaded: true
    )

    // MARK: - Scenario Collections

    static let allScenarios: [Scenario] = [
        hostageRescue,
        nightOperation,
        reconMission,
        convoyAmbush,
        defensivePosition,
        mountainInfiltration,
        maritimeAssault,
        basicCQB,
        marksmanship
    ]

    static let combatScenarios: [Scenario] = [
        hostageRescue,
        nightOperation,
        convoyAmbush,
        defensivePosition,
        maritimeAssault
    ]

    static let trainingScenarios: [Scenario] = [
        basicCQB,
        marksmanship,
        reconMission
    ]
}
