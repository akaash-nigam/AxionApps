//
//  DepartmentDetailView.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import SwiftUI

struct DepartmentDetailView: View {
    let departmentID: Department.ID

    @Environment(\.appState) private var appState
    @Environment(\.services) private var services
    @Environment(\.openWindow) private var openWindow

    @State private var department: Department?
    @State private var employees: [Employee] = []
    @State private var kpis: [KPI] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                if let department {
                    VStack(spacing: 24) {
                        // Overview
                        overviewSection(department: department)

                        // KPIs
                        kpiSection

                        // Team
                        teamSection

                        // Actions
                        actionButtons
                    }
                    .padding(24)
                } else {
                    ProgressView("Loading...")
                }
            }
            .background(.ultraThinMaterial)
            .navigationTitle(department?.name ?? "Department")
            .task {
                await loadDepartmentData()
            }
        }
    }

    private func overviewSection(department: Department) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)

            Grid(alignment: .leading) {
                GridRow {
                    Text("Headcount:")
                        .foregroundStyle(.secondary)
                    Text("\(department.headcount)")
                }
                GridRow {
                    Text("Budget:")
                        .foregroundStyle(.secondary)
                    Text("$\(department.budget.allocated)")
                }
                GridRow {
                    Text("Utilization:")
                        .foregroundStyle(.secondary)
                    Text("\(department.budget.utilizationPercent, specifier: "%.0f")%")
                }
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var kpiSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Metrics")
                .font(.headline)

            ForEach(kpis) { kpi in
                KPICard(kpi: kpi)
            }
        }
    }

    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Team Members")
                .font(.headline)

            ForEach(employees) { employee in
                EmployeeRow(employee: employee)
            }
        }
    }

    private var actionButtons: some View {
        HStack {
            Button("View in 3D") {
                openWindow(id: "department-volume", value: departmentID)
            }
            .buttonStyle(.borderedProminent)

            Button("Generate Report") {
                // Generate report
            }
            .buttonStyle(.bordered)
        }
    }

    private func loadDepartmentData() async {
        do {
            let dept = try await services.repository.fetchDepartment(id: departmentID)
            department = dept

            let fetchedKPIs = try await services.repository.fetchKPIs(for: departmentID)
            kpis = fetchedKPIs

            let fetchedEmployees = try await services.repository.fetchEmployees(for: departmentID)
            employees = fetchedEmployees
        } catch {
            print("Error loading department: \(error)")
        }
    }
}

struct EmployeeRow: View {
    let employee: Employee

    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: employee.availability.color))
                .frame(width: 12, height: 12)

            VStack(alignment: .leading) {
                Text(employee.name)
                    .font(.body)
                Text(employee.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
