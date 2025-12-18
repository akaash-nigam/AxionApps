import SwiftUI

struct EmployeeProfileView: View {
    let employeeID: UUID
    @Environment(AppState.self) private var appState
    @State private var employee: Employee?
    @State private var selectedTab: ProfileTab = .overview

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let employee = employee {
                    // Header
                    ProfileHeaderView(employee: employee)

                    // Metrics
                    ProfileMetricsView(employee: employee)

                    // Tabs
                    Picker("Tab", selection: $selectedTab) {
                        ForEach(ProfileTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Tab Content
                    Group {
                        switch selectedTab {
                        case .overview:
                            OverviewTabView(employee: employee)
                        case .performance:
                            PerformanceTabView(employee: employee)
                        case .goals:
                            GoalsTabView(employee: employee)
                        case .skills:
                            SkillsTabView(employee: employee)
                        }
                    }
                    .padding()
                } else {
                    ProgressView()
                }
            }
        }
        .navigationTitle(employee?.fullName ?? "Employee Profile")
        .task {
            await loadEmployee()
        }
    }

    private func loadEmployee() async {
        do {
            employee = try await appState.hrService.getEmployee(id: employeeID)
        } catch {
            print("Error loading employee: \(error)")
        }
    }
}

// MARK: - Profile Tabs
enum ProfileTab: String, CaseIterable {
    case overview = "Overview"
    case performance = "Performance"
    case goals = "Goals"
    case skills = "Skills"
}

// MARK: - Profile Header
struct ProfileHeaderView: View {
    let employee: Employee

    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(.blue.gradient)
                .frame(width: 100, height: 100)
                .overlay {
                    Text(employee.firstName.prefix(1))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                }

            // Name & Title
            VStack(spacing: 4) {
                Text(employee.fullName)
                    .font(.title)
                    .fontWeight(.bold)

                Text(employee.title)
                    .font(.title3)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label(employee.departmentName, systemImage: "building.2")
                    Label(employee.location, systemImage: "mappin")
                }
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            }

            // Quick Actions
            HStack(spacing: 12) {
                Button {
                    // Message
                } label: {
                    Label("Message", systemImage: "message.fill")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    // Schedule 1:1
                } label: {
                    Label("Schedule 1:1", systemImage: "calendar")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Profile Metrics
struct ProfileMetricsView: View {
    let employee: Employee

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricCard(
                title: "Performance",
                value: "\(Int(employee.performanceRating))%",
                icon: "chart.bar.fill",
                color: .blue
            )

            MetricCard(
                title: "Engagement",
                value: "\(Int(employee.engagementScore))%",
                icon: "heart.fill",
                color: .green
            )

            MetricCard(
                title: "Potential",
                value: "\(Int(employee.potentialScore))%",
                icon: "star.fill",
                color: .yellow
            )
        }
        .padding(.horizontal)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Overview Tab
struct OverviewTabView: View {
    let employee: Employee

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoSection(title: "Details") {
                InfoRow(label: "Employee ID", value: employee.employeeNumber)
                InfoRow(label: "Email", value: employee.email)
                InfoRow(label: "Hire Date", value: employee.hireDate.formatted(date: .abbreviated, time: .omitted))
                InfoRow(label: "Tenure", value: String(format: "%.1f years", employee.tenureYears))
                InfoRow(label: "Level", value: employee.level.rawValue)
            }
        }
    }
}

// MARK: - Performance Tab
struct PerformanceTabView: View {
    let employee: Employee

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoSection(title: "Performance Metrics") {
                Text("Performance data would be displayed here")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Goals Tab
struct GoalsTabView: View {
    let employee: Employee

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoSection(title: "Goals") {
                Text("Goals would be displayed here")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Skills Tab
struct SkillsTabView: View {
    let employee: Employee

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoSection(title: "Skills") {
                Text("Skills would be displayed here")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Helper Views
struct InfoSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        EmployeeProfileView(employeeID: UUID())
    }
    .environment(AppState())
}
