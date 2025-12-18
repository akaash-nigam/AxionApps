//
//  DashboardView.swift
//  SpatialMeetingPlatform
//
//  Main dashboard window for meeting management
//

import SwiftUI

struct DashboardView: View {

    @Environment(AppModel.self) private var appModel
    @State private var showingNewMeeting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection

                    // Quick Actions
                    quickActionsSection

                    // Today's Meetings
                    if !appModel.upcomingMeetings.isEmpty {
                        todaysMeetingsSection
                    } else {
                        emptyStateSection
                    }

                    // Recent Meetings
                    recentMeetingsSection
                }
                .padding(32)
            }
            .navigationTitle("Spatial Meeting Platform")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Schedule Meeting", systemImage: "calendar.badge.plus") {
                            showingNewMeeting = true
                        }
                        Button("Join with Code", systemImage: "number") {
                            // Join with code
                        }
                        Button("Settings", systemImage: "gear") {
                            // Show settings
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingNewMeeting) {
                NewMeetingView()
            }
        }
        .task {
            await loadMeetings()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let user = appModel.currentUser {
                    Text("Welcome back, \(user.displayName)!")
                        .font(.title2)
                        .fontWeight(.semibold)

                    if let organization = user.organization {
                        Text(organization)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Welcome to Spatial Meeting Platform")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }

            Spacer()

            // User Avatar
            Circle()
                .fill(.blue.gradient)
                .frame(width: 50, height: 50)
                .overlay {
                    if let user = appModel.currentUser {
                        Text(String(user.displayName.prefix(1)))
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                    }
                }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickActionButton(
                    title: "Instant Meeting",
                    icon: "video.fill",
                    color: .blue
                ) {
                    Task {
                        await startInstantMeeting()
                    }
                }

                QuickActionButton(
                    title: "Schedule",
                    icon: "calendar.badge.plus",
                    color: .green
                ) {
                    showingNewMeeting = true
                }

                QuickActionButton(
                    title: "Analytics",
                    icon: "chart.bar.fill",
                    color: .purple
                ) {
                    // Show analytics
                }

                QuickActionButton(
                    title: "Settings",
                    icon: "gear",
                    color: .gray
                ) {
                    // Show settings
                }
            }
        }
    }

    // MARK: - Today's Meetings

    private var todaysMeetingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Meetings")
                .font(.headline)

            ForEach(appModel.upcomingMeetings.prefix(5), id: \.id) { meeting in
                MeetingCard(meeting: meeting) {
                    Task {
                        await joinMeeting(meeting)
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Meetings Scheduled")
                .font(.title3)
                .fontWeight(.semibold)

            Text("You're all caught up!")
                .font(.body)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Button("Schedule Meeting") {
                    showingNewMeeting = true
                }
                .buttonStyle(.borderedProminent)

                Button("Join with Code") {
                    // Join with code
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Recent Meetings

    private var recentMeetingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Meetings")
                .font(.headline)

            if appModel.meetingHistory.isEmpty {
                Text("No recent meetings")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(appModel.meetingHistory.prefix(3), id: \.id) { meeting in
                    MeetingHistoryRow(meeting: meeting)
                }
            }
        }
    }

    // MARK: - Actions

    private func loadMeetings() async {
        do {
            try await appModel.fetchUpcomingMeetings()
        } catch {
            print("Failed to load meetings: \(error)")
        }
    }

    private func joinMeeting(_ meeting: Meeting) async {
        do {
            try await appModel.joinMeeting(meeting)
        } catch {
            print("Failed to join meeting: \(error)")
        }
    }

    private func startInstantMeeting() async {
        do {
            try await appModel.scheduleMeeting(
                title: "Instant Meeting",
                startDate: Date(),
                endDate: Date().addingTimeInterval(3600),
                type: .boardroom
            )

            // Join immediately
            if let meeting = appModel.upcomingMeetings.first {
                try await appModel.joinMeeting(meeting)
            }
        } catch {
            print("Failed to start instant meeting: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct MeetingCard: View {
    let meeting: Meeting
    let joinAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(meeting.title)
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                if meeting.status == .inProgress {
                    Text("In Progress")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 16) {
                Label("\(meeting.participants.count) participants", systemImage: "person.3.fill")
                Label(meeting.meetingType.displayName, systemImage: meeting.meetingType.icon)
            }
            .font(.callout)
            .foregroundStyle(.secondary)

            HStack {
                Text(meeting.scheduledStart, style: .time)
                Text("–")
                Text(meeting.scheduledEnd, style: .time)
            }
            .font(.callout)
            .foregroundStyle(.secondary)

            Button(action: joinAction) {
                Text("Join Now")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.blue.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct MeetingHistoryRow: View {
    let meeting: Meeting

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(meeting.title)
                    .font(.callout)
                    .fontWeight(.medium)

                Text(meeting.scheduledStart, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct NewMeetingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppModel.self) private var appModel

    @State private var title = ""
    @State private var selectedType: MeetingType = .boardroom
    @State private var startDate = Date()
    @State private var duration: TimeInterval = 3600

    var body: some View {
        NavigationStack {
            Form {
                Section("Meeting Details") {
                    TextField("Title", text: $title)

                    Picker("Environment", selection: $selectedType) {
                        ForEach(MeetingType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }

                    DatePicker("Start Time", selection: $startDate, in: Date()...)

                    Picker("Duration", selection: $duration) {
                        Text("30 minutes").tag(TimeInterval(1800))
                        Text("1 hour").tag(TimeInterval(3600))
                        Text("2 hours").tag(TimeInterval(7200))
                    }
                }
            }
            .navigationTitle("New Meeting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Schedule") {
                        Task {
                            await scheduleMeeting()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func scheduleMeeting() async {
        do {
            try await appModel.scheduleMeeting(
                title: title,
                startDate: startDate,
                endDate: startDate.addingTimeInterval(duration),
                type: selectedType
            )
            dismiss()
        } catch {
            print("Failed to schedule meeting: \(error)")
        }
    }
}

#Preview {
    DashboardView()
        .environment(AppModel())
}
