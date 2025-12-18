//
//  ContentView.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Main navigation container
//

import SwiftUI

struct ContentView: View {

    // MARK: - Properties

    @State private var selectedTab: Tab = .home

    // MARK: - Body

    var body: some View {
        #if os(visionOS)
        NavigationSplitView {
            List(Tab.allCases, selection: $selectedTab) { tab in
                Label(tab.title, systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationTitle("Home Maintenance")
        } detail: {
            selectedTabView
        }
        #else
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases) { tab in
                selectedTabView(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        #endif
    }

    // MARK: - View Builders

    @ViewBuilder
    private var selectedTabView: some View {
        selectedTabView(for: selectedTab)
    }

    @ViewBuilder
    private func selectedTabView(for tab: Tab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .inventory:
            InventoryListView()
        case .maintenance:
            MaintenanceScheduleView()
        case .settings:
            SettingsView()
        }
    }
}

// MARK: - Tab Enum

extension ContentView {
    enum Tab: String, CaseIterable, Identifiable {
        case home
        case inventory
        case maintenance
        case settings

        var id: String { rawValue }

        var title: String {
            switch self {
            case .home: return "Home"
            case .inventory: return "Inventory"
            case .maintenance: return "Maintenance"
            case .settings: return "Settings"
            }
        }

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .inventory: return "cube.box.fill"
            case .maintenance: return "wrench.and.screwdriver.fill"
            case .settings: return "gear"
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
