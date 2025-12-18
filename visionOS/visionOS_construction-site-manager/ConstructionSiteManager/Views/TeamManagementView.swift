import SwiftUI
import SwiftData

/// Team management view for organizing construction team members, roles, and assignments
/// Supports team member CRUD, role assignments, and contact management
struct TeamManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sites: [Site]

    @State private var selectedSite: Site?
    @State private var selectedRole: TeamRole?
    @State private var searchText = ""
    @State private var showingAddMember = false
    @State private var showingMemberDetail: TeamMember?
    @State private var sortOrder: SortOrder = .name

    enum SortOrder: String, CaseIterable {
        case name = "Name"
        case role = "Role"
        case company = "Company"
        case status = "Status"
    }

    var body: some View {
        NavigationSplitView {
            siteList
        } detail: {
            if let site = selectedSite {
                teamDetail(for: site)
            } else {
                emptyState
            }
        }
        .searchable(text: $searchText, prompt: "Search team members...")
        .sheet(isPresented: $showingAddMember) {
            if let site = selectedSite {
                AddTeamMemberSheet(site: site)
            }
        }
        .sheet(item: $showingMemberDetail) { member in
            TeamMemberDetailSheet(member: member)
        }
    }

    // MARK: - Site List

    private var siteList: some View {
        List(sites, selection: $selectedSite) { site in
            SiteTeamRow(site: site)
                .tag(site)
        }
        .navigationTitle("Sites")
    }

    // MARK: - Team Detail

    @ViewBuilder
    private func teamDetail(for site: Site) -> View {
        ScrollView {
            VStack(spacing: 24) {
                // Team overview
                teamOverviewCard(for: site)

                // Role filter and sort
                filtersSection

                // Role distribution
                roleDistribution(for: site)

                // Team member list
                teamMemberList(for: site)

                // Add member button
                addMemberButton
            }
            .padding()
        }
        .navigationTitle(site.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: exportTeamRoster) {
                        Label("Export Team Roster", systemImage: "doc.text")
                    }

                    Button(action: sendTeamNotification) {
                        Label("Send Team Notification", systemImage: "bell")
                    }

                    Divider()

                    Button(action: refreshTeamData) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    // MARK: - Team Overview Card

    private func teamOverviewCard(for site: Site) -> some View {
        let members = site.team
        let activeMembers = members.filter { $0.isActive }
        let companies = Set(members.map { $0.company })

        return VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Team Overview")
                        .font(.headline)
                    Text(site.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "person.3.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
            }

            // Statistics
            HStack(spacing: 20) {
                TeamStatBadge(
                    label: "Total Members",
                    value: members.count,
                    icon: "person.fill",
                    color: .blue
                )

                TeamStatBadge(
                    label: "Active",
                    value: activeMembers.count,
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                TeamStatBadge(
                    label: "Companies",
                    value: companies.count,
                    icon: "building.2.fill",
                    color: .purple
                )
            }

            // Active projects
            HStack {
                Text("Active Projects:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(site.projects.filter { $0.status == .active }.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Filters Section

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filters & Sorting")
                .font(.headline)

            HStack {
                // Role filter
                Menu {
                    Button("All Roles") {
                        selectedRole = nil
                    }
                    Divider()
                    ForEach(TeamRole.allCases, id: \.self) { role in
                        Button(action: { selectedRole = role }) {
                            Label(role.displayName, systemImage: "circle.fill")
                                .foregroundStyle(role.color)
                        }
                    }
                } label: {
                    Label(selectedRole?.displayName ?? "All Roles",
                          systemImage: "person.crop.circle.badge.checkmark")
                }
                .buttonStyle(.bordered)

                Spacer()

                // Sort order
                Menu {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Button(action: { sortOrder = order }) {
                            Label(order.rawValue, systemImage: sortOrder == order ? "checkmark" : "")
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
                .buttonStyle(.bordered)
            }

            if selectedRole != nil {
                Button(action: { selectedRole = nil }) {
                    Label("Clear Filter", systemImage: "xmark.circle")
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Role Distribution

    private func roleDistribution(for site: Site) -> some View {
        let members = site.team

        return VStack(alignment: .leading, spacing: 12) {
            Text("Team Composition")
                .font(.headline)

            ForEach(TeamRole.allCases, id: \.self) { role in
                let count = members.filter { $0.role == role }.count
                let percentage = members.isEmpty ? 0.0 : Double(count) / Double(members.count)

                HStack {
                    Circle()
                        .fill(role.color)
                        .frame(width: 12, height: 12)

                    Text(role.displayName)
                        .font(.subheadline)

                    Spacer()

                    Text("\(count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(String(format: "%.0f%%", percentage * 100))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 50, alignment: .trailing)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.quaternary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(role.color)
                            .frame(width: geometry.size.width * percentage)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Team Member List

    private func teamMemberList(for site: Site) -> some View {
        let members = filteredAndSortedMembers(from: site)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Team Members")
                    .font(.headline)

                Spacer()

                Text("\(members.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if members.isEmpty {
                Text("No team members match the current filters")
                    .foregroundStyle(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(members) { member in
                    TeamMemberRow(member: member)
                        .onTapGesture {
                            showingMemberDetail = member
                        }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Add Member Button

    private var addMemberButton: some View {
        Button(action: { showingAddMember = true }) {
            Label("Add Team Member", systemImage: "person.badge.plus")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "No Site Selected",
            systemImage: "person.3",
            description: Text("Select a site from the list to manage team members")
        )
    }

    // MARK: - Helper Functions

    private func filteredAndSortedMembers(from site: Site) -> [TeamMember] {
        var members = site.team

        // Apply role filter
        if let role = selectedRole {
            members = members.filter { $0.role == role }
        }

        // Apply search filter
        if !searchText.isEmpty {
            members = members.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText) ||
                $0.company.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply sorting
        switch sortOrder {
        case .name:
            members.sort { $0.name < $1.name }
        case .role:
            members.sort { $0.role.rawValue < $1.role.rawValue }
        case .company:
            members.sort { $0.company < $1.company }
        case .status:
            members.sort { $0.isActive && !$1.isActive }
        }

        return members
    }

    private func exportTeamRoster() {
        // TODO: Generate and export team roster PDF
    }

    private func sendTeamNotification() {
        // TODO: Send notification to all team members
    }

    private func refreshTeamData() {
        // TODO: Refresh team data from server
    }
}

// MARK: - Supporting Views

struct SiteTeamRow: View {
    let site: Site

    var body: some View {
        let teamCount = site.team.count

        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(site.name)
                    .font(.headline)

                Text("\(teamCount) team member\(teamCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct TeamStatBadge: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)

            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TeamMemberRow: View {
    let member: TeamMember

    var body: some View {
        HStack(spacing: 12) {
            // Avatar placeholder
            Circle()
                .fill(member.role.color.gradient)
                .frame(width: 50, height: 50)
                .overlay {
                    Text(member.initials)
                        .font(.headline)
                        .foregroundStyle(.white)
                }

            // Member info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(member.name)
                        .font(.headline)

                    if !member.isActive {
                        Text("Inactive")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.red.opacity(0.2), in: Capsule())
                            .foregroundStyle(.red)
                    }
                }

                Text(member.role.displayName)
                    .font(.subheadline)
                    .foregroundStyle(member.role.color)

                Text(member.company)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !member.email.isEmpty {
                    Label(member.email, systemImage: "envelope")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if !member.phoneNumber.isEmpty {
                    Button(action: { /* Call */ }) {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(.blue)
                    }
                }

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct AddTeamMemberSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let site: Site

    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var company = ""
    @State private var role: TeamRole = .foreman
    @State private var isActive = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("Full Name", text: $name)
                        .autocorrectionDisabled()

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    TextField("Phone Number", text: $phoneNumber)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }

                Section("Work Information") {
                    TextField("Company", text: $company)

                    Picker("Role", selection: $role) {
                        ForEach(TeamRole.allCases, id: \.self) { role in
                            Label(role.displayName, systemImage: "circle.fill")
                                .foregroundStyle(role.color)
                                .tag(role)
                        }
                    }

                    Toggle("Active", isOn: $isActive)
                }

                Section {
                    Button(action: addMember) {
                        Text("Add Team Member")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.blue)
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Add Team Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !company.isEmpty
    }

    private func addMember() {
        let member = TeamMember(
            name: name,
            email: email,
            phone: phoneNumber,
            role: role,
            company: company,
            isActive: isActive
        )

        // Add to site's team
        site.team.append(member)

        try? modelContext.save()
        dismiss()
    }
}

struct TeamMemberDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var member: TeamMember

    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar and name
                    VStack(spacing: 12) {
                        Circle()
                            .fill(member.role.color.gradient)
                            .frame(width: 100, height: 100)
                            .overlay {
                                Text(member.initials)
                                    .font(.largeTitle)
                                    .foregroundStyle(.white)
                            }

                        Text(member.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(member.role.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundStyle(member.role.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(member.role.color.opacity(0.2), in: Capsule())

                        Toggle("Active Status", isOn: $member.isActive)
                            .labelsHidden()
                    }
                    .frame(maxWidth: .infinity)

                    // Contact information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Contact Information")
                            .font(.headline)

                        DetailRow(icon: "envelope.fill", label: "Email", value: member.email)
                        DetailRow(icon: "phone.fill", label: "Phone", value: member.phoneNumber)
                        DetailRow(icon: "building.2.fill", label: "Company", value: member.company)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

                    // Edit mode
                    if isEditing {
                        Form {
                            TextField("Name", text: $member.name)
                            TextField("Email", text: $member.email)
                            TextField("Phone", text: $member.phoneNumber)
                            TextField("Company", text: $member.company)

                            Picker("Role", selection: $member.role) {
                                ForEach(TeamRole.allCases, id: \.self) { role in
                                    Text(role.displayName).tag(role)
                                }
                            }
                        }
                        .frame(height: 300)
                        .scrollContentBackground(.hidden)
                    }

                    // Actions
                    VStack(spacing: 12) {
                        Button(action: { /* Send email */ }) {
                            Label("Send Email", systemImage: "envelope")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button(action: { /* Call */ }) {
                            Label("Call", systemImage: "phone")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button(role: .destructive, action: removeMember) {
                            Label("Remove from Team", systemImage: "person.badge.minus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Team Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            try? modelContext.save()
                        }
                        isEditing.toggle()
                    }
                }
            }
        }
    }

    private func removeMember() {
        modelContext.delete(member)
        try? modelContext.save()
        dismiss()
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value.isEmpty ? "Not provided" : value)
                    .font(.subheadline)
                    .foregroundStyle(value.isEmpty ? .secondary : .primary)
            }

            Spacer()
        }
    }
}

// MARK: - Extensions

extension TeamMember {
    var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "?"
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Site.self, Project.self, TeamMember.self, configurations: config)

        let site = Site(
            name: "Downtown Construction Site",
            address: Address(
                street: "123 Construction Way",
                city: "San Francisco",
                state: "CA",
                zipCode: "94105",
                country: "USA"
            ),
            gpsLatitude: 37.7749,
            gpsLongitude: -122.4194
        )

        let project = Project(name: "Building A", projectType: .commercial, scheduledEndDate: Date().addingTimeInterval(86400 * 365))

        let members = [
            TeamMember(name: "John Smith", email: "john@example.com", phone: "555-0100", role: .projectManager, company: "ABC Construction"),
            TeamMember(name: "Sarah Johnson", email: "sarah@example.com", phone: "555-0101", role: .engineer, company: "ABC Construction"),
            TeamMember(name: "Mike Chen", email: "mike@example.com", phone: "555-0102", role: .safetyOfficer, company: "Safety First Inc"),
            TeamMember(name: "Emily Davis", email: "emily@example.com", phone: "555-0103", role: .architect, company: "Design Studio"),
            TeamMember(name: "Robert Brown", email: "robert@example.com", phone: "555-0104", role: .foreman, company: "BuildCo")
        ]

        // Add team members to site (Site has a team relationship)
        members.forEach { site.team.append($0) }
        site.projects.append(project)
        container.mainContext.insert(site)

        return container
    }()

    TeamManagementView()
        .modelContainer(container)
}
