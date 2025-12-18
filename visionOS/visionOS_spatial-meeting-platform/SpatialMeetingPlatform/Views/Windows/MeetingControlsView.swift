//
//  MeetingControlsView.swift
//  SpatialMeetingPlatform
//
//  Meeting controls window for active meetings
//

import SwiftUI

struct MeetingControlsView: View {

    @Environment(AppModel.self) private var appModel
    @State private var audioEnabled = true
    @State private var videoEnabled = false
    @State private var showingParticipants = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Meeting Title
            if let meeting = appModel.activeMeeting {
                Text(meeting.title)
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            Divider()

            // Audio Controls
            audioSection

            Divider()

            // Video Controls
            videoSection

            Divider()

            // Participants
            participantsSection

            Divider()

            // Share Content
            shareSection

            Divider()

            // Actions
            actionsSection

            Spacer()
        }
        .padding(24)
        .frame(width: 400)
        .glassBackgroundEffect()
    }

    // MARK: - Audio Section

    private var audioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Audio", systemImage: "speaker.wave.2.fill")
                .font(.headline)

            HStack {
                Button(action: { audioEnabled.toggle() }) {
                    HStack {
                        Image(systemName: audioEnabled ? "mic.fill" : "mic.slash.fill")
                        Text(audioEnabled ? "Mute" : "Unmute")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(audioEnabled ? .blue : .red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            Toggle("Spatial Audio", isOn: .constant(true))
                .font(.callout)
        }
    }

    // MARK: - Video Section

    private var videoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Video", systemImage: "video.fill")
                .font(.headline)

            Button(action: { videoEnabled.toggle() }) {
                HStack {
                    Image(systemImage: videoEnabled ? "video.fill" : "video.slash.fill")
                    Text(videoEnabled ? "Stop Video" : "Start Video")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Participants Section

    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Participants", systemImage: "person.3.fill")
                    .font(.headline)

                Spacer()

                if let meeting = appModel.activeMeeting {
                    Text("\(meeting.participants.count)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }

            if let meeting = appModel.activeMeeting {
                ForEach(meeting.participants.prefix(3), id: \.id) { participant in
                    ParticipantRow(participant: participant)
                }

                if meeting.participants.count > 3 {
                    Button("View All (\(meeting.participants.count))") {
                        showingParticipants = true
                    }
                    .font(.callout)
                }
            }
        }
    }

    // MARK: - Share Section

    private var shareSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Share", systemImage: "square.and.arrow.up")
                .font(.headline)

            HStack(spacing: 12) {
                ShareButton(icon: "display", title: "Screen")
                ShareButton(icon: "doc.fill", title: "Document")
                ShareButton(icon: "scribble", title: "Whiteboard")
            }
        }
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    await appModel.toggleImmersiveMode()
                }
            }) {
                HStack {
                    Image(systemName: appModel.immersiveModeActive ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    Text(appModel.immersiveModeActive ? "Exit Immersive" : "Enter Immersive")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.purple)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)

            Button(action: {
                Task {
                    await leaveMeeting()
                }
            }) {
                HStack {
                    Image(systemName: "phone.down.fill")
                    Text("Leave Meeting")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.red)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Actions

    private func leaveMeeting() async {
        do {
            try await appModel.leaveMeeting()
        } catch {
            print("Failed to leave meeting: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct ParticipantRow: View {
    let participant: Participant

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(participant.presenceState == .speaking ? .green : .blue)
                .frame(width: 32, height: 32)
                .overlay {
                    Text(String(participant.user.displayName.prefix(1)))
                        .font(.caption)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(participant.user.displayName)
                    .font(.callout)
                    .fontWeight(.medium)

                if participant.presenceState == .speaking {
                    Text("Speaking")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }

            Spacer()

            if !participant.audioEnabled {
                Image(systemImage: "mic.slash.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ShareButton: View {
    let icon: String
    let title: String

    var body: some View {
        Button(action: {
            // Share action
        }) {
            VStack(spacing: 8) {
                Image(systemImage: icon)
                    .font(.title3)

                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MeetingControlsView()
        .environment(AppModel())
}
