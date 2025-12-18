//
//  DataAnonymizer.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//  Privacy-preserving data anonymization
//

import Foundation
import CryptoKit

struct DataAnonymizer {

    // MARK: - Anonymization

    func anonymize(_ rawEmployee: RawEmployee) -> Employee {
        Employee(
            anonymousId: generateAnonymousId(from: rawEmployee.realId),
            teamId: rawEmployee.teamId,
            departmentId: rawEmployee.departmentId,
            role: Employee.GeneralizedRole.generalize(rawEmployee.role).rawValue,
            tenureMonths: rawEmployee.tenureMonths
        )
    }

    // MARK: - K-Anonymity Enforcement

    func enforceKAnonymity<T>(_ data: [T], groupSize: Int = AppConstants.minimumTeamSize) -> [T] {
        guard data.count >= groupSize else {
            return [] // Suppress if group too small
        }
        return data
    }

    func canDisplay(teamSize: Int) -> Bool {
        return teamSize >= AppConstants.minimumTeamSize
    }

    // MARK: - Private Helpers

    private func generateAnonymousId(from realId: String) -> UUID {
        // One-way hash to consistent anonymous ID
        let inputData = Data(realId.utf8)
        let hashed = SHA256.hash(data: inputData)

        // Use first 16 bytes for UUID
        let bytes = Array(hashed.prefix(16))
        let uuid = UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))

        return uuid
    }
}

// MARK: - Raw Employee (Not stored, only for transformation)

struct RawEmployee {
    let realId: String  // Email or employee ID (never stored)
    let teamId: UUID
    let departmentId: UUID
    let role: String
    let tenureMonths: Int
}
