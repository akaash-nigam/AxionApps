//
//  ContentView.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(FarmManager.self) private var farmManager

    var body: some View {
        DashboardView()
    }
}

#Preview {
    ContentView()
        .environment(FarmManager())
        .environment(AppModel())
        .environment(ServiceContainer())
}
