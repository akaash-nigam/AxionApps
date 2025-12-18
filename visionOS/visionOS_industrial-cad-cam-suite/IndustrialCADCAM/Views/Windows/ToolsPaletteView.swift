//
//  ToolsPaletteView.swift
//  IndustrialCADCAM
//
//  Floating tools palette for CAD/CAM operations
//

import SwiftUI

struct ToolsPaletteView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTool: CADTool?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Tools")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top)

                // Sketch Tools
                ToolSection(title: "Sketch", icon: "pencil.line") {
                    ToolGrid {
                        ToolButton(tool: .line, icon: "line.diagonal", label: "Line")
                        ToolButton(tool: .circle, icon: "circle", label: "Circle")
                        ToolButton(tool: .rectangle, icon: "rectangle", label: "Rectangle")
                        ToolButton(tool: .arc, icon: "arc.3points", label: "Arc")
                    }
                }

                // 3D Features
                ToolSection(title: "3D Features", icon: "cube") {
                    ToolGrid {
                        ToolButton(tool: .extrude, icon: "arrow.up", label: "Extrude")
                        ToolButton(tool: .revolve, icon: "arrow.triangle.2.circlepath", label: "Revolve")
                        ToolButton(tool: .fillet, icon: "circle.dotted", label: "Fillet")
                        ToolButton(tool: .chamfer, icon: "square.slash", label: "Chamfer")
                    }
                }

                // Modify Tools
                ToolSection(title: "Modify", icon: "slider.horizontal.3") {
                    ToolGrid {
                        ToolButton(tool: .pattern, icon: "square.grid.2x2", label: "Pattern")
                        ToolButton(tool: .mirror, icon: "arrow.left.and.right.righttriangle.left.righttriangle.right", label: "Mirror")
                        ToolButton(tool: .delete, icon: "trash", label: "Delete")
                        ToolButton(tool: .undo, icon: "arrow.uturn.backward", label: "Undo")
                    }
                }

                // Measure Tools
                ToolSection(title: "Measure", icon: "ruler") {
                    ToolGrid {
                        ToolButton(tool: .distance, icon: "ruler", label: "Distance")
                        ToolButton(tool: .angle, icon: "angle", label: "Angle")
                        ToolButton(tool: .mass, icon: "scalemass", label: "Mass")
                        ToolButton(tool: .point, icon: "mappin.circle", label: "Point")
                    }
                }

                // Simulate Tools
                ToolSection(title: "Simulate", icon: "chart.line.uptrend.xyaxis") {
                    ToolGrid {
                        ToolButton(tool: .stress, icon: "arrow.up.arrow.down", label: "Stress")
                        ToolButton(tool: .thermal, icon: "thermometer", label: "Thermal")
                        ToolButton(tool: .cfd, icon: "wind", label: "CFD")
                        ToolButton(tool: .modal, icon: "waveform", label: "Modal")
                    }
                }

                // View Tools
                ToolSection(title: "View", icon: "eye") {
                    ToolGrid {
                        ToolButton(tool: .home, icon: "house", label: "Home")
                        ToolButton(tool: .fit, icon: "viewfinder", label: "Fit")
                        ToolButton(tool: .section, icon: "scissors", label: "Section")
                        ToolButton(tool: .light, icon: "light.max", label: "Light")
                    }
                }
            }
        }
        .frame(minWidth: 280)
    }
}

// MARK: - Tool Section

struct ToolSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.headline)
            }
            .padding(.horizontal)

            content()
                .padding(.horizontal)
        }
    }
}

// MARK: - Tool Grid

struct ToolGrid<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            content()
        }
    }
}

// MARK: - Tool Button

struct ToolButton: View {
    let tool: CADTool
    let icon: String
    let label: String

    @State private var isHovered = false

    var body: some View {
        Button(action: {
            // Tool action
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(height: 32)

                Text(label)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? Color.blue.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - CAD Tool Enum

enum CADTool {
    // Sketch
    case line, circle, rectangle, arc

    // 3D Features
    case extrude, revolve, fillet, chamfer

    // Modify
    case pattern, mirror, delete, undo

    // Measure
    case distance, angle, mass, point

    // Simulate
    case stress, thermal, cfd, modal

    // View
    case home, fit, section, light
}

#Preview {
    ToolsPaletteView()
        .frame(width: 300, height: 700)
}
