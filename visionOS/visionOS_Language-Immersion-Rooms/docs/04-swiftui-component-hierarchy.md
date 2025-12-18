# SwiftUI Component Hierarchy

## App Structure

```
LanguageImmersionApp
├── WindowGroup (Main Menu & Settings)
│   └── MainMenuView
├── ImmersiveSpace (Learning Environment)
│   └── ImmersiveLearningView
└── Window (Progress Dashboard)
    └── ProgressDashboardView
```

## View Hierarchy

### Root Level

```swift
@main
struct LanguageImmersionApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var sceneManager = SceneManager()

    var body: some Scene {
        // Main window for settings and menu
        WindowGroup {
            MainMenuView()
                .environmentObject(appState)
        }

        // Immersive space for learning
        ImmersiveSpace(id: "LearningSpace") {
            ImmersiveLearningView()
                .environmentObject(appState)
                .environmentObject(sceneManager)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)

        // Progress window
        WindowGroup(id: "Progress") {
            ProgressDashboardView()
                .environmentObject(appState)
        }
        .defaultSize(width: 800, height: 600)
    }
}
```

## Main Menu View

```swift
struct MainMenuView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Header
                HeaderView()

                // Quick Start
                QuickStartCard()

                // Feature Grid
                FeatureGrid()

                // Settings & Profile
                HStack {
                    NavigationLink(destination: SettingsView()) {
                        SettingsButton()
                    }

                    NavigationLink(destination: ProfileView()) {
                        ProfileButton()
                    }
                }
            }
            .padding(40)
        }
    }
}
```

### Main Menu Components

```swift
// HeaderView.swift
struct HeaderView: View {
    var body: some View {
        VStack {
            Text("Language Immersion Rooms")
                .font(.system(size: 48, weight: .bold))
            Text("Transform your space into a language learning environment")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
}

// QuickStartCard.swift
struct QuickStartCard: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: appState.currentLanguage.flag)
                Text("Continue Learning \(appState.currentLanguage.name)")
                    .font(.title2)
            }

            ProgressBar(progress: appState.todayProgress)

            Button("Start Session") {
                appState.startLearningSession()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(30)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

// FeatureGrid.swift
struct FeatureGrid: View {
    let features = [
        Feature(title: "Object Labels", icon: "tag.fill", destination: AnyView(ObjectLabelingView())),
        Feature(title: "Conversations", icon: "bubble.left.and.bubble.right.fill", destination: AnyView(ConversationSelectionView())),
        Feature(title: "Pronunciation", icon: "waveform", destination: AnyView(PronunciationCoachView())),
        Feature(title: "Environments", icon: "building.2.fill", destination: AnyView(EnvironmentSelectionView()))
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 20) {
            ForEach(features) { feature in
                NavigationLink(destination: feature.destination) {
                    FeatureCard(feature: feature)
                }
            }
        }
    }
}

struct FeatureCard: View {
    let feature: Feature

    var body: some View {
        VStack {
            Image(systemName: feature.icon)
                .font(.system(size: 48))
            Text(feature.title)
                .font(.headline)
        }
        .frame(width: 200, height: 200)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
```

## Immersive Learning View

```swift
struct ImmersiveLearningView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var sceneManager: SceneManager
    @State private var showGrammarCard = false

    var body: some View {
        RealityView { content in
            // Setup RealityKit scene
            await sceneManager.setupScene(content: content)
        } update: { content in
            // Update scene based on state
            sceneManager.updateScene(content: content)
        }
        .overlay(alignment: .topTrailing) {
            // Controls overlay
            LearningControlsOverlay()
        }
        .overlay(alignment: .center) {
            // Grammar cards
            if showGrammarCard {
                GrammarCardView(card: sceneManager.currentGrammarCard)
            }
        }
        .overlay(alignment: .bottom) {
            // Conversation UI
            ConversationBottomBar()
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    sceneManager.handleTap(on: value.entity)
                }
        )
    }
}
```

### Immersive View Components

```swift
// LearningControlsOverlay.swift
struct LearningControlsOverlay: View {
    @EnvironmentObject var sceneManager: SceneManager
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 15) {
            // Exit button
            Button(action: { sceneManager.exitSession() }) {
                Label("Exit", systemImage: "xmark.circle.fill")
            }
            .buttonStyle(.borderless)

            Divider()

            // Mode toggles
            Toggle("Show Labels", isOn: $sceneManager.showLabels)
            Toggle("Grammar Help", isOn: $sceneManager.showGrammar)

            Divider()

            // Environment selector
            EnvironmentPicker(selection: $sceneManager.currentEnvironment)

            // Settings
            Button(action: { showSettings = true }) {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .sheet(isPresented: $showSettings) {
                SessionSettingsView()
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding(30)
    }
}

// ConversationBottomBar.swift
struct ConversationBottomBar: View {
    @EnvironmentObject var sceneManager: SceneManager
    @State private var isListening = false

    var body: some View {
        HStack(spacing: 20) {
            // Character avatar
            if let character = sceneManager.currentCharacter {
                AsyncImage(url: character.thumbnailURL) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            }

            // Last message
            VStack(alignment: .leading) {
                Text(sceneManager.lastMessage)
                    .font(.body)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Mic button
            Button(action: { toggleListening() }) {
                Image(systemName: isListening ? "mic.fill" : "mic")
                    .font(.system(size: 24))
                    .foregroundColor(isListening ? .red : .primary)
            }
            .buttonStyle(.borderedProminent)
            .tint(isListening ? .red : .blue)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding(.horizontal, 40)
        .padding(.bottom, 30)
    }

    private func toggleListening() {
        isListening.toggle()
        if isListening {
            sceneManager.startListening()
        } else {
            sceneManager.stopListening()
        }
    }
}

// GrammarCardView.swift
struct GrammarCardView: View {
    let card: GrammarCard

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text(card.title)
                    .font(.headline)
            }

            Divider()

            // Error
            VStack(alignment: .leading, spacing: 5) {
                Text("You said:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(card.incorrectPhrase)
                    .font(.body)
                    .foregroundColor(.red)
            }

            // Correction
            VStack(alignment: .leading, spacing: 5) {
                Text("Correct:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(card.correctPhrase)
                    .font(.body)
                    .foregroundColor(.green)
            }

            Divider()

            // Explanation
            Text(card.explanation)
                .font(.caption)

            // Actions
            HStack {
                Button("Practice") {
                    card.startPractice()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Dismiss") {
                    card.dismiss()
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(20)
        .frame(width: 400)
        .background(.regularMaterial)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}
```

## Object Labeling View

```swift
struct ObjectLabelingView: View {
    @StateObject private var labelManager = ObjectLabelManager()
    @State private var labelMode: LabelMode = .standard
    @State private var isScanning = false

    var body: some View {
        VStack {
            // Header
            Text("Object Labeling")
                .font(.largeTitle)
                .padding()

            // Controls
            HStack(spacing: 20) {
                Picker("Label Mode", selection: $labelMode) {
                    Text("Minimal").tag(LabelMode.minimal)
                    Text("Standard").tag(LabelMode.standard)
                    Text("Detailed").tag(LabelMode.detailed)
                }
                .pickerStyle(.segmented)

                Button(isScanning ? "Stop Scanning" : "Scan Room") {
                    toggleScanning()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            // Object list
            List(labelManager.detectedObjects) { object in
                ObjectLabelRow(object: object)
            }

            // Start button
            Button("Start Labeling") {
                labelManager.startLabeling(mode: labelMode)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }

    private func toggleScanning() {
        isScanning.toggle()
        if isScanning {
            labelManager.startScanning()
        } else {
            labelManager.stopScanning()
        }
    }
}

struct ObjectLabelRow: View {
    let object: DetectedObject

    var body: some View {
        HStack {
            Image(systemName: object.icon)
            VStack(alignment: .leading) {
                Text(object.name)
                    .font(.headline)
                Text(object.translation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Play pronunciation
            Button(action: { object.playPronunciation() }) {
                Image(systemName: "speaker.wave.2.fill")
            }
            .buttonStyle(.borderless)
        }
    }
}
```

## Conversation Selection View

```swift
struct ConversationSelectionView: View {
    @StateObject private var scenarioManager = ScenarioManager()
    @State private var selectedCategory: ScenarioCategory = .dailyLife

    var body: some View {
        VStack {
            // Header
            Text("Choose a Scenario")
                .font(.largeTitle)
                .padding()

            // Category picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(ScenarioCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Scenario grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
                    ForEach(scenarioManager.scenarios(for: selectedCategory)) { scenario in
                        ScenarioCard(scenario: scenario) {
                            scenarioManager.start(scenario: scenario)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct ScenarioCard: View {
    let scenario: Scenario
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Preview image
            AsyncImage(url: scenario.previewImageURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(.gray.opacity(0.3))
            }
            .frame(height: 150)
            .clipped()

            // Info
            VStack(alignment: .leading, spacing: 5) {
                Text(scenario.name)
                    .font(.headline)

                Text(scenario.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                // Meta info
                HStack {
                    Label(scenario.difficulty.rawValue, systemImage: "star.fill")
                    Spacer()
                    Label("\(Int(scenario.duration / 60)) min", systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)

            // Start button
            Button("Start") {
                action()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}
```

## Progress Dashboard View

```swift
struct ProgressDashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var progressTracker = ProgressTracker()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Stats overview
                    StatsOverviewSection(stats: progressTracker.stats)

                    // Streak
                    StreakSection(streak: appState.currentStreak)

                    // Skills breakdown
                    SkillsBreakdownSection(skills: progressTracker.skills)

                    // Recent activity
                    RecentActivitySection(activities: progressTracker.recentActivities)

                    // Vocabulary progress
                    VocabularyProgressSection(progress: progressTracker.vocabularyProgress)
                }
                .padding(40)
            }
            .navigationTitle("Your Progress")
        }
    }
}

struct StatsOverviewSection: View {
    let stats: LearningStats

    var body: some View {
        HStack(spacing: 20) {
            StatCard(title: "Study Time", value: "\(stats.totalHours)h", icon: "clock.fill")
            StatCard(title: "Conversations", value: "\(stats.conversationCount)", icon: "bubble.left.and.bubble.right.fill")
            StatCard(title: "Words Learned", value: "\(stats.wordsLearned)", icon: "book.fill")
            StatCard(title: "Accuracy", value: "\(Int(stats.accuracy))%", icon: "checkmark.circle.fill")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.blue)

            Text(value)
                .font(.system(size: 36, weight: .bold))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}
```

## Settings View

```swift
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("labelSize") private var labelSize: LabelSize = .medium
    @AppStorage("speechSpeed") private var speechSpeed: Double = 1.0

    var body: some View {
        Form {
            // Account section
            Section("Account") {
                AccountInfoView()
                SubscriptionView()
            }

            // Language preferences
            Section("Languages") {
                LanguagePreferencesView()
            }

            // Display settings
            Section("Display") {
                Picker("Label Size", selection: $labelSize) {
                    Text("Small").tag(LabelSize.small)
                    Text("Medium").tag(LabelSize.medium)
                    Text("Large").tag(LabelSize.large)
                }

                Toggle("High Contrast", isOn: $appState.preferences.highContrastMode)
                Toggle("Reduced Motion", isOn: $appState.preferences.reducedMotion)
            }

            // Audio settings
            Section("Audio") {
                Slider(value: $speechSpeed, in: 0.5...2.0, step: 0.1) {
                    Text("Speech Speed: \(speechSpeed, specifier: "%.1f")x")
                }

                Picker("Voice Gender", selection: $appState.preferences.voiceGender) {
                    Text("Male").tag(VoiceGender.male)
                    Text("Female").tag(VoiceGender.female)
                    Text("Neutral").tag(VoiceGender.neutral)
                }
            }

            // Learning settings
            Section("Learning") {
                Picker("Difficulty", selection: $appState.preferences.difficultyMode) {
                    Text("Easy").tag(DifficultyMode.easy)
                    Text("Normal").tag(DifficultyMode.normal)
                    Text("Challenging").tag(DifficultyMode.challenging)
                }

                Picker("Correction Timing", selection: $appState.preferences.correctionTiming) {
                    Text("Immediate").tag(CorrectionTiming.immediate)
                    Text("After Sentence").tag(CorrectionTiming.afterSentence)
                    Text("End of Session").tag(CorrectionTiming.endOfSession)
                }

                Stepper("Daily Goal: \(appState.preferences.dailyGoalMinutes) min",
                        value: $appState.preferences.dailyGoalMinutes,
                        in: 5...120,
                        step: 5)
            }

            // Privacy
            Section("Privacy") {
                Toggle("Allow Analytics", isOn: $appState.preferences.allowAnalytics)
                Button("Delete My Data") {
                    // Confirmation dialog
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
    }
}
```

## Reusable Components

### ProgressBar

```swift
struct ProgressBar: View {
    let progress: Double // 0.0 - 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.gray.opacity(0.3))

                Rectangle()
                    .fill(.blue)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 8)
        .cornerRadius(4)
    }
}
```

### LoadingView

```swift
struct LoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text(message)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}
```

## Style Guide

### Colors

```swift
extension Color {
    static let appPrimary = Color.blue
    static let appSecondary = Color.green
    static let appAccent = Color.orange
    static let appError = Color.red
}
```

### Fonts

```swift
extension Font {
    static let appTitle = Font.system(size: 48, weight: .bold)
    static let appHeadline = Font.system(size: 24, weight: .semibold)
    static let appBody = Font.system(size: 16, weight: .regular)
    static let appCaption = Font.system(size: 12, weight: .regular)
}
```

### Button Styles

```swift
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.appPrimary)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
```
