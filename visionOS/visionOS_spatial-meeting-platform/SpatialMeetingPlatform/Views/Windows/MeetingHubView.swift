import SwiftUI

struct MeetingHubView: View {
    @Environment(AppState.self) private var appState
    @State private var upcomingMeetings: [Meeting] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                headerView

                // Meeting stats
                statsView

                // Meetings list
                if isLoading {
                    ProgressView("Loading meetings...")
                        .frame(maxHeight: .infinity)
                } else if let error = errorMessage {
                    errorView(error)
                } else {
                    meetingsList
                }

                Spacer()

                // Schedule meeting button
                scheduleButton
            }
            .padding()
            .navigationTitle("Meeting Hub")
            .task {
                await loadMeetings()
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome, \(appState.currentUser?.displayName ?? "User")")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Spatial Meeting Platform")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Status indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(appState.isAuthenticated ? .green : .gray)
                    .frame(width: 8, height: 8)

                Text(appState.isAuthenticated ? "Online" : "Offline")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statsView: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Today",
                value: "\(todayMeetings.count)",
                icon: "calendar"
            )

            StatCard(
                title: "Upcoming",
                value: "\(upcomingMeetings.count)",
                icon: "clock"
            )
        }
    }

    private var meetingsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if upcomingMeetings.isEmpty {
                    emptyStateView
                } else {
                    ForEach(upcomingMeetings, id: \.id) { meeting in
                        MeetingCardView(meeting: meeting) {
                            await joinMeeting(meeting)
                        }
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No upcoming meetings")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("Schedule a meeting to get started")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)

            Button("Retry") {
                Task { await loadMeetings() }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var scheduleButton: some View {
        Button(action: scheduleMeeting) {
            Label("Schedule Meeting", systemImage: "plus.circle.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    // MARK: - Computed Properties

    private var todayMeetings: [Meeting] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        return upcomingMeetings.filter { meeting in
            meeting.startTime >= today && meeting.startTime < tomorrow
        }
    }

    // MARK: - Actions

    private func loadMeetings() async {
        isLoading = true
        errorMessage = nil

        do {
            upcomingMeetings = try await appState.meetingService.upcomingMeetings()
            print("✅ Loaded \(upcomingMeetings.count) meetings")
        } catch {
            errorMessage = "Failed to load meetings: \(error.localizedDescription)"
            print("❌ Error loading meetings: \(error)")
        }

        isLoading = false
    }

    private func joinMeeting(_ meeting: Meeting) async {
        do {
            try await appState.joinMeeting(meeting)
            print("✅ Joined meeting: \(meeting.title)")
        } catch {
            errorMessage = "Failed to join meeting: \(error.localizedDescription)"
            print("❌ Error joining meeting: \(error)")
        }
    }

    private func scheduleMeeting() {
        print("📅 Schedule meeting tapped")
        // TODO: Show schedule meeting sheet
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct MeetingCardView: View {
    let meeting: Meeting
    let onJoin: () async -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 6) {
                Text(meeting.title)
                    .font(.headline)

                HStack(spacing: 12) {
                    Label(timeString, systemImage: "clock")
                    Label("\(meeting.participantCount) participants", systemImage: "person.2")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                if let description = meeting.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                }
            }

            Spacer()

            // Join button
            Button(action: { Task { await onJoin() } }) {
                Text(isNow ? "Join Now" : "Join")
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(isNow ? .green : .blue)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var statusColor: Color {
        switch meeting.status {
        case .live: return .green
        case .scheduled: return .blue
        case .ended: return .gray
        case .cancelled: return .red
        }
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: meeting.startTime)
    }

    private var isNow: Bool {
        let now = Date()
        return meeting.startTime <= now && meeting.endTime > now
    }
}

#Preview {
    MeetingHubView()
        .environment(AppState())
}
