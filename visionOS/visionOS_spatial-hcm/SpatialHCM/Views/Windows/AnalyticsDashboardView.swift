import SwiftUI

struct AnalyticsDashboardView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Analytics Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Placeholder for analytics content
                Text("Analytics visualizations would appear here")
                    .foregroundStyle(.secondary)
                    .frame(maxHeight: .infinity)
            }
            .padding()
        }
        .navigationTitle("Analytics")
    }
}

#Preview {
    AnalyticsDashboardView()
        .environment(AppState())
}
