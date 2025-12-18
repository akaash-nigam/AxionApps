import SwiftUI

struct EmployeeListView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText = ""

    var body: some View {
        @Bindable var orgState = appState.organizationState

        List {
            ForEach(orgState.filteredEmployees) { employee in
                NavigationLink {
                    EmployeeProfileView(employeeID: employee.id)
                } label: {
                    EmployeeRow(employee: employee)
                }
            }
        }
        .searchable(text: $orgState.searchQuery, prompt: "Search employees")
        .navigationTitle("Employees (\(orgState.employeeCount))")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    // Add employee
                } label: {
                    Label("Add Employee", systemImage: "plus")
                }
            }
        }
    }
}

struct EmployeeRow: View {
    let employee: Employee

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(.blue.gradient)
                .frame(width: 44, height: 44)
                .overlay {
                    Text(employee.firstName.prefix(1))
                        .font(.headline)
                        .foregroundStyle(.white)
                }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(employee.fullName)
                    .font(.headline)

                Text(employee.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Label(employee.departmentName, systemImage: "building.2")
                    Label(employee.location, systemImage: "mappin")
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
            }

            Spacer()

            // Badges
            VStack(alignment: .trailing, spacing: 4) {
                if employee.isFlightRisk {
                    Badge(text: "Flight Risk", color: .red)
                }

                if employee.isHighPotential {
                    Badge(text: "High Potential", color: .yellow)
                }

                if employee.isNewHire {
                    Badge(text: "New Hire", color: .green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct Badge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.2), in: Capsule())
            .foregroundStyle(color)
    }
}

#Preview {
    NavigationStack {
        EmployeeListView()
    }
    .environment(AppState())
}
