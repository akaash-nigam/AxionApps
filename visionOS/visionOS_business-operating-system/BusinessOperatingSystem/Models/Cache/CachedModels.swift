//
//  CachedModels.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation
import SwiftData

// MARK: - Cache Configuration

enum CacheConfiguration {
    static let defaultMaxAge: TimeInterval = 3600  // 1 hour
    static let shortMaxAge: TimeInterval = 300     // 5 minutes
    static let longMaxAge: TimeInterval = 86400    // 24 hours
}

// MARK: - Cached Organization

@Model
final class CachedOrganization {
    @Attribute(.unique) var id: UUID
    var name: String
    var lastSyncedAt: Date
    var data: Data  // JSON encoded organization

    @Relationship(deleteRule: .cascade)
    var departments: [CachedDepartment]

    init(id: UUID, name: String, data: Data) {
        self.id = id
        self.name = name
        self.lastSyncedAt = Date()
        self.data = data
        self.departments = []
    }

    var isExpired: Bool {
        isExpired(maxAge: CacheConfiguration.defaultMaxAge)
    }

    func isExpired(maxAge: TimeInterval) -> Bool {
        Date().timeIntervalSince(lastSyncedAt) > maxAge
    }

    func decode() -> Organization? {
        try? JSONDecoder().decode(Organization.self, from: data)
    }

    func update(with organization: Organization) throws {
        self.name = organization.name
        self.data = try JSONEncoder().encode(organization)
        self.lastSyncedAt = Date()
    }
}

// MARK: - Cached Department

@Model
final class CachedDepartment {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: String
    var headcount: Int
    var budgetAllocated: Decimal
    var budgetSpent: Decimal
    var lastSyncedAt: Date
    var data: Data

    @Relationship(inverse: \CachedOrganization.departments)
    var organization: CachedOrganization?

    init(id: UUID, name: String, type: String, data: Data) {
        self.id = id
        self.name = name
        self.type = type
        self.headcount = 0
        self.budgetAllocated = 0
        self.budgetSpent = 0
        self.lastSyncedAt = Date()
        self.data = data
    }

    convenience init(from department: Department) throws {
        let data = try JSONEncoder().encode(department)
        self.init(id: department.id, name: department.name, type: department.type.rawValue, data: data)
        self.headcount = department.headcount
        self.budgetAllocated = department.budget.allocated
        self.budgetSpent = department.budget.spent
    }

    var isExpired: Bool {
        Date().timeIntervalSince(lastSyncedAt) > CacheConfiguration.defaultMaxAge
    }

    func decode() -> Department? {
        try? JSONDecoder().decode(Department.self, from: data)
    }

    func update(with department: Department) throws {
        self.name = department.name
        self.type = department.type.rawValue
        self.headcount = department.headcount
        self.budgetAllocated = department.budget.allocated
        self.budgetSpent = department.budget.spent
        self.data = try JSONEncoder().encode(department)
        self.lastSyncedAt = Date()
    }
}

// MARK: - Cached KPI

@Model
final class CachedKPI {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    var value: Decimal
    var target: Decimal
    var lastSyncedAt: Date
    var data: Data

    init(id: UUID, name: String, category: String, data: Data) {
        self.id = id
        self.name = name
        self.category = category
        self.value = 0
        self.target = 0
        self.lastSyncedAt = Date()
        self.data = data
    }

    convenience init(from kpi: KPI) throws {
        let data = try JSONEncoder().encode(kpi)
        self.init(id: kpi.id, name: kpi.name, category: kpi.category.rawValue, data: data)
        self.value = kpi.value
        self.target = kpi.target
    }

    var isExpired: Bool {
        // KPIs expire more quickly since they change frequently
        Date().timeIntervalSince(lastSyncedAt) > CacheConfiguration.shortMaxAge
    }

    func decode() -> KPI? {
        try? JSONDecoder().decode(KPI.self, from: data)
    }

    func update(with kpi: KPI) throws {
        self.name = kpi.name
        self.category = kpi.category.rawValue
        self.value = kpi.value
        self.target = kpi.target
        self.data = try JSONEncoder().encode(kpi)
        self.lastSyncedAt = Date()
    }
}

// MARK: - Cached Employee

@Model
final class CachedEmployee {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String
    var title: String
    var departmentID: UUID
    var lastSyncedAt: Date
    var data: Data

    init(id: UUID, name: String, email: String, data: Data) {
        self.id = id
        self.name = name
        self.email = email
        self.title = ""
        self.departmentID = UUID()
        self.lastSyncedAt = Date()
        self.data = data
    }

    convenience init(from employee: Employee) throws {
        let data = try JSONEncoder().encode(employee)
        self.init(id: employee.id, name: employee.name, email: employee.email, data: data)
        self.title = employee.title
        self.departmentID = employee.department
    }

    var isExpired: Bool {
        Date().timeIntervalSince(lastSyncedAt) > CacheConfiguration.longMaxAge
    }

    func decode() -> Employee? {
        try? JSONDecoder().decode(Employee.self, from: data)
    }

    func update(with employee: Employee) throws {
        self.name = employee.name
        self.email = employee.email
        self.title = employee.title
        self.departmentID = employee.department
        self.data = try JSONEncoder().encode(employee)
        self.lastSyncedAt = Date()
    }
}

// MARK: - Cache Manager

actor CacheManager {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func clearExpiredCache() async throws {
        // Clear expired organizations
        let orgDescriptor = FetchDescriptor<CachedOrganization>()
        let organizations = try modelContext.fetch(orgDescriptor)
        for org in organizations where org.isExpired {
            modelContext.delete(org)
        }

        // Clear expired departments
        let deptDescriptor = FetchDescriptor<CachedDepartment>()
        let departments = try modelContext.fetch(deptDescriptor)
        for dept in departments where dept.isExpired {
            modelContext.delete(dept)
        }

        // Clear expired KPIs
        let kpiDescriptor = FetchDescriptor<CachedKPI>()
        let kpis = try modelContext.fetch(kpiDescriptor)
        for kpi in kpis where kpi.isExpired {
            modelContext.delete(kpi)
        }

        try modelContext.save()
    }

    func clearAllCache() async throws {
        try modelContext.delete(model: CachedOrganization.self)
        try modelContext.delete(model: CachedDepartment.self)
        try modelContext.delete(model: CachedKPI.self)
        try modelContext.delete(model: CachedEmployee.self)
        try modelContext.save()
    }
}
