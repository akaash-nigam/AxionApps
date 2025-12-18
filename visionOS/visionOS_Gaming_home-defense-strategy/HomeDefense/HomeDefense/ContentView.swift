import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var showImmersiveSpace = false
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack(spacing: 30) {
            Text("Home Defense Strategy")
                .font(.extraLargeTitle)
                .fontWeight(.bold)

            Text("Transform your space into a battlefield")
                .font(.title)
                .foregroundStyle(.secondary)

            Button(action: {
                Task {
                    if showImmersiveSpace {
                        await dismissImmersiveSpace()
                        showImmersiveSpace = false
                    } else {
                        await openImmersiveSpace(id: "DefenseSpace")
                        showImmersiveSpace = true
                    }
                }
            }) {
                Text(showImmersiveSpace ? "Exit Defense Mode" : "Start Defense")
                    .font(.title2)
                    .padding()
                    .frame(minWidth: 300)
            }
            .buttonStyle(.borderedProminent)
            .tint(showImmersiveSpace ? .red : .green)
        }
        .padding(50)
    }
}

#Preview {
    ContentView()
}
