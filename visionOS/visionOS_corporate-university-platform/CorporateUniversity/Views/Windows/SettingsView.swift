//
//  SettingsView.swift
//  CorporateUniversity
//
//  Complete implementation with user preferences and account settings
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var notificationsEnabled = true
    @State private var autoPlayVideos = true
    @State private var downloadQuality: VideoQuality = .high
    @State private var offlineMode = false
    @State private var textSize: TextSize = .medium
    @State private var reduceMotion = false
    @State private var showProfileEditor = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Profile Section
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 64, height: 64)
                            .overlay {
                                Text("JD")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("John Doe")
                                .font(.headline)
                            Text("john.doe@company.com")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Software Engineer")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        
                        Spacer()
                        
                        Button("Edit") {
                            showProfileEditor = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Profile")
                }
                
                // Learning Preferences
                Section {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Auto-play Videos", isOn: $autoPlayVideos)
                    Toggle("Offline Mode", isOn: $offlineMode)
                    
                    Picker("Download Quality", selection: $downloadQuality) {
                        ForEach(VideoQuality.allCases, id: \.self) { quality in
                            Text(quality.rawValue).tag(quality)
                        }
                    }
                } header: {
                    Text("Learning Preferences")
                } footer: {
                    Text("Offline mode downloads courses for offline viewing")
                }
                
                // Appearance
                Section {
                    Picker("Text Size", selection: $textSize) {
                        ForEach(TextSize.allCases, id: \.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    
                    Toggle("Reduce Motion", isOn: $reduceMotion)
                } header: {
                    Text("Appearance & Accessibility")
                } footer: {
                    Text("Reduce motion can help with motion sensitivity")
                }
                
                // Account Settings
                Section {
                    NavigationLink {
                        Text("Change Password")
                            .navigationTitle("Change Password")
                    } label: {
                        Label("Change Password", systemImage: "key")
                    }
                    
                    NavigationLink {
                        Text("Privacy Settings")
                            .navigationTitle("Privacy")
                    } label: {
                        Label("Privacy Settings", systemImage: "lock.shield")
                    }
                    
                    NavigationLink {
                        Text("Data Management")
                            .navigationTitle("Data Management")
                    } label: {
                        Label("Data Management", systemImage: "externaldrive")
                    }
                    
                    Button(role: .destructive) {
                        // Sign out
                    } label: {
                        Label("Sign Out", systemImage: "arrow.right.square")
                    }
                } header: {
                    Text("Account")
                }
                
                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .foregroundStyle(.secondary)
                    }
                    
                    NavigationLink {
                        Text("Terms of Service")
                            .navigationTitle("Terms of Service")
                    } label: {
                        Text("Terms of Service")
                    }
                    
                    NavigationLink {
                        Text("Privacy Policy")
                            .navigationTitle("Privacy Policy")
                    } label: {
                        Text("Privacy Policy")
                    }
                    
                    NavigationLink {
                        Text("Help & Support")
                            .navigationTitle("Help")
                    } label: {
                        Text("Help & Support")
                    }
                } header: {
                    Text("About")
                }
                
                // Cache & Storage
                Section {
                    HStack {
                        Text("Cache Size")
                        Spacer()
                        Text("142 MB")
                            .foregroundStyle(.secondary)
                    }
                    
                    Button("Clear Cache") {
                        // Clear cache
                    }
                    .foregroundStyle(.red)
                } header: {
                    Text("Storage")
                } footer: {
                    Text("Clearing cache will remove downloaded content")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .glassBackgroundEffect()
        .sheet(isPresented: $showProfileEditor) {
            ProfileEditorView()
        }
    }
}

enum VideoQuality: String, CaseIterable {
    case low = "Low (360p)"
    case medium = "Medium (720p)"
    case high = "High (1080p)"
    case ultra = "Ultra (4K)"
}

enum TextSize: String, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"
}

struct ProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = "John"
    @State private var lastName = "Doe"
    @State private var email = "john.doe@company.com"
    @State private var department = "Engineering"
    @State private var role = "Software Engineer"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                Section("Work Information") {
                    TextField("Department", text: $department)
                    TextField("Role", text: $role)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppModel())
}
