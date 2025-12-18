//
//  SharedContentView.swift
//  SpatialMeetingPlatform
//
//  Shared content display window
//

import SwiftUI

struct SharedContentView: View {

    @Environment(AppModel.self) private var appModel
    @State private var currentPage = 1
    @State private var totalPages = 12

    var body: some View {
        VStack(spacing: 0) {
            // Content Area
            contentArea

            // Controls
            controlBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }

    // MARK: - Content Area

    private var contentArea: some View {
        ZStack {
            // Placeholder content
            VStack(spacing: 20) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.opacity(0.3))

                Text("Q4_Roadmap.pdf")
                    .font(.title)
                    .fontWeight(.semibold)

                VStack(spacing: 12) {
                    Text("Product Roadmap Q4 2024")
                        .font(.title2)

                    Divider()
                        .frame(width: 300)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Feature A - Launch Nov 1")
                        Text("• Feature B - Launch Nov 15")
                        Text("• Feature C - Launch Dec 1")
                    }
                    .font(.title3)
                }
                .padding(40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.95))
    }

    // MARK: - Control Bar

    private var controlBar: some View {
        HStack {
            // Previous Button
            Button(action: {
                if currentPage > 1 {
                    currentPage -= 1
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            .buttonStyle(.bordered)
            .disabled(currentPage == 1)

            Text("Page \(currentPage) of \(totalPages)")
                .font(.callout)
                .foregroundStyle(.secondary)

            // Next Button
            Button(action: {
                if currentPage < totalPages {
                    currentPage += 1
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .buttonStyle(.bordered)
            .disabled(currentPage == totalPages)

            Spacer()

            // Annotation Tools
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemImage: "pencil.tip")
                }
                .buttonStyle(.bordered)

                Button(action: {}) {
                    Image(systemImage: "highlighter")
                }
                .buttonStyle(.bordered)

                Button(action: {}) {
                    Image(systemImage: "bubble.left")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.regularMaterial)
    }
}

#Preview {
    SharedContentView()
        .environment(AppModel())
}
