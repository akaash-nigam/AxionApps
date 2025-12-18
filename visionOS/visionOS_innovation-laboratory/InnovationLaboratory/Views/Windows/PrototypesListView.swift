import SwiftUI
import SwiftData

struct PrototypesListView: View {
    @Query private var prototypes: [Prototype]

    var body: some View {
        List {
            if prototypes.isEmpty {
                ContentUnavailableView(
                    "No Prototypes Yet",
                    systemImage: "cube.3d",
                    description: Text("Create your first prototype from an idea")
                )
            } else {
                ForEach(prototypes) { prototype in
                    PrototypeRow(prototype: prototype)
                }
            }
        }
        .navigationTitle("Prototypes")
    }
}

struct PrototypeRow: View {
    let prototype: Prototype

    var body: some View {
        HStack {
            Image(systemName: "cube.fill")
                .font(.title2)
                .foregroundStyle(.purple)

            VStack(alignment: .leading) {
                Text(prototype.name)
                    .font(.headline)

                Text("Version \\(prototype.version)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Label(prototype.status.rawValue, systemImage: prototype.status.icon)
                .font(.caption)
        }
    }
}

#Preview {
    PrototypesListView()
}
