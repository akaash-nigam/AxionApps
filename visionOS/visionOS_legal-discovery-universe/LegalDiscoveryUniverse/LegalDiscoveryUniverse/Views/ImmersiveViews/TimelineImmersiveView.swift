//
//  TimelineImmersiveView.swift
//  Legal Discovery Universe
//
//  Created on 2025-11-17.
//

import SwiftUI
import RealityKit

struct TimelineImmersiveView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        RealityView { content in
            let rootEntity = Entity()

            // Create timeline flow (placeholder)
            if let currentCase = appState.currentCase,
               let timeline = currentCase.timelines.first {
                let timelineEntity = createTimelineFlow(for: timeline)
                rootEntity.addChild(timelineEntity)
            }

            content.add(rootEntity)
        }
        .overlay(alignment: .bottom) {
            timelineControls
        }
    }

    private var timelineControls: some View {
        HStack(spacing: 16) {
            Button {
                // Scroll to start
            } label: {
                Image(systemName: "backward.end.fill")
            }

            Button {
                // Previous event
            } label: {
                Image(systemName: "chevron.left")
            }

            Text("March 2023 - Present")
                .font(.caption)
                .padding(.horizontal)

            Button {
                // Next event
            } label: {
                Image(systemName: "chevron.right")
            }

            Button {
                // Scroll to end
            } label: {
                Image(systemName: "forward.end.fill")
            }

            Spacer()

            Button("Exit") {
                Task {
                    await dismissImmersiveSpace()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .glassBackgroundEffect()
        .padding()
    }

    private func createTimelineFlow(for timeline: Timeline) -> Entity {
        let flow = Entity()

        // Create timeline river (placeholder)
        let sortedEvents = timeline.sortedEvents

        for (index, event) in sortedEvents.enumerated() {
            let marker = createEventMarker(for: event, index: index, total: sortedEvents.count)
            flow.addChild(marker)
        }

        return flow
    }

    private func createEventMarker(for event: TimelineEvent, index: Int, total: Int) -> ModelEntity {
        let size = event.eventType.size.pointSize / 1000.0 // Convert to meters

        let marker = ModelEntity(
            mesh: .generateSphere(radius: size / 2),
            materials: [SimpleMaterial(color: eventColor(for: event), isMetallic: false)]
        )

        // Position along timeline (left to right)
        let totalLength: Float = 10.0 // 10 meter timeline
        let position = -totalLength / 2 + (Float(index) / Float(total)) * totalLength

        marker.position = SIMD3<Float>(position, 0, -2.0)

        marker.generateCollisionShapes(recursive: false)
        marker.components[InputTargetComponent.self] = InputTargetComponent()
        marker.components[HoverEffectComponent.self] = HoverEffectComponent()

        return marker
    }

    private func eventColor(for event: TimelineEvent) -> UIColor {
        switch event.eventType {
        case .critical: return .red
        case .settlement: return .green
        case .hearing: return .purple
        case .deadline: return .orange
        default: return .blue
        }
    }
}

#Preview {
    TimelineImmersiveView()
        .environment(AppState())
}
