import SwiftUI
import RealityKit

struct WorkoutSpaceView: View {
    @State private var workoutTime: TimeInterval = 0
    @State private var heartRate = 72
    @State private var timer: Timer?
    @State private var currentExercise = "Warm Up"
    @State private var repsCompleted = 0

    var body: some View {
        RealityView { content in
            // Create workout environment
            let gym = createGymEnvironment()
            content.add(gym)

            // Add workout equipment
            let equipment = createWorkoutEquipment()
            equipment.position = [0, 0, -2]
            content.add(equipment)

            // Add training markers
            let markers = createTrainingMarkers()
            markers.position = [0, 0.01, -1]
            content.add(markers)

            // Add virtual trainer
            let trainer = createVirtualTrainer()
            trainer.position = [-2, 1, -2.5]
            content.add(trainer)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    completeRep()
                }
        )
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Workout Session")
                    .font(.title)
                    .fontWeight(.bold)

                Divider()

                // Timer and stats
                HStack(spacing: 25) {
                    VStack(alignment: .leading) {
                        Label("Time", systemImage: "timer")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatTime(workoutTime))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                    }

                    Divider()
                        .frame(height: 50)

                    VStack(alignment: .leading) {
                        Label("Heart Rate", systemImage: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(heartRate) BPM")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                    }
                }

                Divider()

                // Current exercise
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Exercise")
                        .font(.headline)
                    Text(currentExercise)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }

                // Reps counter
                HStack {
                    Text("Reps:")
                        .font(.headline)
                    Spacer()
                    Text("\(repsCompleted)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.orange)
                }
                .padding()
                .background(.orange.opacity(0.2))
                .cornerRadius(10)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding()
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                workoutTime += 1
                // Simulate heart rate changes
                heartRate = Int.random(in: 110...145)
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func createGymEnvironment() -> Entity {
        let gym = Entity()

        // Floor
        let floor = ModelEntity(
            mesh: .generatePlane(width: 8, depth: 6),
            materials: [SimpleMaterial(color: .init(red: 0.3, green: 0.3, blue: 0.35, alpha: 1), isMetallic: false)]
        )
        floor.position.y = -0.5
        gym.addChild(floor)

        // Mirrors (walls)
        let mirrorMaterial = SimpleMaterial(color: .init(white: 0.8, alpha: 0.5), isMetallic: true)
        let mirror = ModelEntity(
            mesh: .generateBox(width: 6, height: 2.5, depth: 0.05),
            materials: [mirrorMaterial]
        )
        mirror.position = [0, 1, -4]
        gym.addChild(mirror)

        return gym
    }

    private func createWorkoutEquipment() -> Entity {
        let equipment = Entity()

        // Dumbbells
        for i in 0..<3 {
            let dumbbell = ModelEntity(
                mesh: .generateCylinder(height: 0.3, radius: 0.05),
                materials: [SimpleMaterial(color: .systemGray, isMetallic: true)]
            )
            dumbbell.position = [Float(i - 1) * 0.5, 0.3, 0]
            equipment.addChild(dumbbell)
        }

        // Yoga mat
        let mat = ModelEntity(
            mesh: .generatePlane(width: 0.8, depth: 1.8),
            materials: [SimpleMaterial(color: .systemPurple, isMetallic: false)]
        )
        mat.position = [0, 0.01, 1]
        equipment.addChild(mat)

        return equipment
    }

    private func createTrainingMarkers() -> Entity {
        let markers = Entity()

        // Create target markers for exercises
        for i in 0..<4 {
            let marker = ModelEntity(
                mesh: .generateSphere(radius: 0.1),
                materials: [SimpleMaterial(color: .systemGreen, isMetallic: false)]
            )
            let angle = Float(i) * (.pi / 2)
            marker.position = [sin(angle) * 1.2, 0.8, cos(angle) * 1.2]
            marker.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.1)]))
            marker.components.set(InputTargetComponent())
            markers.addChild(marker)
        }

        return markers
    }

    private func createVirtualTrainer() -> ModelEntity {
        let trainer = ModelEntity(
            mesh: .generateCylinder(height: 1.7, radius: 0.2),
            materials: [SimpleMaterial(color: .systemBlue, isMetallic: false)]
        )

        // Add head
        let head = ModelEntity(
            mesh: .generateSphere(radius: 0.15),
            materials: [SimpleMaterial(color: .systemBlue, isMetallic: false)]
        )
        head.position.y = 1
        trainer.addChild(head)

        return trainer
    }

    private func completeRep() {
        repsCompleted += 1

        // Change exercise every 10 reps
        if repsCompleted % 10 == 0 {
            let exercises = ["Squats", "Push-ups", "Lunges", "Planks", "Burpees"]
            currentExercise = exercises.randomElement() ?? "Exercise"
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    WorkoutSpaceView()
}
