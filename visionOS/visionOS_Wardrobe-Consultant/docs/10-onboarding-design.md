# Onboarding & First-Run Experience Design

## Document Overview

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## 1. Executive Summary

This document defines the onboarding and first-run experience for Wardrobe Consultant. The goal is to quickly demonstrate value while collecting essential information (body measurements, style preferences, permissions) without overwhelming the user. The experience should be completed in under 5 minutes and immediately showcase the app's core features.

## 2. Onboarding Philosophy

### 2.1 Core Principles

**Value-First**:
- Show, don't tell
- Demonstrate features immediately
- Quick wins before lengthy setup

**Progressive Disclosure**:
- Start with minimal required information
- Collect additional data over time
- Optional features introduced contextually

**Trust & Transparency**:
- Clear explanations for data collection
- Privacy-first messaging
- Easy to skip optional steps

**Spatial-Native**:
- Leverage visionOS capabilities
- Immersive demonstrations
- Natural gesture interactions

### 2.2 Success Criteria

**Completion Rate**: > 80% of users complete onboarding
**Time to Value**: Users see first outfit suggestion in < 3 minutes
**Retention**: > 70% return after first session

## 3. Onboarding Flow

### 3.1 Flow Overview

```
Launch App
    ↓
Step 1: Welcome & Value Proposition (30s)
    ↓
Step 2: Quick Demo (30s)
    ↓
Step 3: Style Quiz (90s)
    ↓
Step 4: Body Measurements (60s)
    ↓
Step 5: Permission Requests (45s)
    ↓
Step 6: Add First Item (Optional, 45s)
    ↓
Complete: First Outfit Suggestion!
```

**Total Time**: 4-5 minutes

### 3.2 Step-by-Step Design

---

## Step 1: Welcome & Value Proposition (30 seconds)

**Goal**: Hook user with clear value proposition

**Screen Design**:
```
┌──────────────────────────────────────────┐
│                                          │
│          [App Icon - 3D]                 │
│                                          │
│     Wardrobe Consultant                  │
│                                          │
│  Your Personal AI Stylist                │
│                                          │
│  ✓ Virtual try-on with AR                │
│  ✓ Outfit suggestions for any occasion   │
│  ✓ Never repeat outfits                  │
│                                          │
│       [Get Started]                      │
│                                          │
│    Already have an account? [Sign In]   │
│                                          │
└──────────────────────────────────────────┘
```

**Implementation**:
```swift
struct WelcomeView: View {
    @State private var animateIcon = false

    var body: some View {
        VStack(spacing: 40) {
            // Animated 3D app icon
            Model3D(named: "AppIcon") { model in
                model
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
            } placeholder: {
                ProgressView()
            }
            .rotationEffect(.degrees(animateIcon ? 360 : 0))
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: animateIcon)

            VStack(spacing: 16) {
                Text("Wardrobe Consultant")
                    .font(.system(size: 48, weight: .bold))

                Text("Your Personal AI Stylist")
                    .font(.title2)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "wand.and.stars", text: "Virtual try-on with AR")
                    FeatureRow(icon: "sparkles", text: "Outfit suggestions for any occasion")
                    FeatureRow(icon: "calendar", text: "Never repeat outfits")
                }
                .padding()
            }

            Button("Get Started") {
                // Navigate to next step
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button("Already have an account? Sign In") {
                // Navigate to sign in
            }
            .buttonStyle(.plain)
            .font(.caption)
        }
        .padding()
        .onAppear {
            animateIcon = true
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
            Text(text)
        }
    }
}
```

---

## Step 2: Quick Demo (30 seconds)

**Goal**: Show virtual try-on in action

**Screen Design**:
```
┌──────────────────────────────────────────┐
│  See It In Action                        │
│                                          │
│  [Video/Animation]                       │
│  Person using virtual try-on             │
│  Showing outfit suggestions              │
│                                          │
│  "Try on clothes instantly               │
│   without changing"                      │
│                                          │
│       [Next]    [Skip Demo]              │
└──────────────────────────────────────────┘
```

**Implementation**:
```swift
struct QuickDemoView: View {
    @State private var isPlaying = false

    var body: some View {
        VStack(spacing: 30) {
            Text("See It In Action")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Video player showing quick demo
            VideoPlayer(player: AVPlayer(url: demoVideoURL))
                .frame(height: 400)
                .cornerRadius(20)

            Text("Try on clothes instantly without changing")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                Button("Skip Demo") {
                    // Skip to next step
                }
                .buttonStyle(.bordered)

                Button("Next") {
                    // Navigate to next step
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    private var demoVideoURL: URL {
        Bundle.main.url(forResource: "demo_video", withExtension: "mp4")!
    }
}
```

---

## Step 3: Style Quiz (90 seconds)

**Goal**: Understand user's style preferences

**Questions** (5 questions):
1. What's your go-to style?
2. Favorite colors to wear?
3. Comfort vs. style priority?
4. Typical weekly activities?
5. Style goals?

**Screen Design**:
```
┌──────────────────────────────────────────┐
│  Tell Us Your Style                      │
│                                          │
│  Question 1 of 5                         │
│  [Progress: ████░░░░░░]                  │
│                                          │
│  What's your go-to style?                │
│                                          │
│  ┌────────┐  ┌────────┐  ┌────────┐    │
│  │Minimal │  │Classic │  │ Trendy │    │
│  │  ist   │  │        │  │        │    │
│  └────────┘  └────────┘  └────────┘    │
│                                          │
│  ┌────────┐  ┌────────┐  ┌────────┐    │
│  │  Edgy  │  │ Boho   │  │ Sporty │    │
│  │        │  │        │  │        │    │
│  └────────┘  └────────┘  └────────┘    │
│                                          │
│              [Next]                      │
└──────────────────────────────────────────┘
```

**Implementation**:
```swift
struct StyleQuizView: View {
    @StateObject var viewModel: StyleQuizViewModel
    @State private var currentQuestion = 0

    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Text("Tell Us Your Style")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack {
                    Text("Question \(currentQuestion + 1) of 5")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ProgressView(value: Double(currentQuestion), total: 5)
                        .frame(width: 150)
                }
            }

            Spacer()

            // Question
            QuestionView(
                question: viewModel.questions[currentQuestion],
                selection: $viewModel.answers[currentQuestion]
            )

            Spacer()

            // Navigation
            HStack(spacing: 20) {
                if currentQuestion > 0 {
                    Button("Back") {
                        currentQuestion -= 1
                    }
                    .buttonStyle(.bordered)
                }

                Button(currentQuestion < 4 ? "Next" : "Complete") {
                    if currentQuestion < 4 {
                        currentQuestion += 1
                    } else {
                        viewModel.completeQuiz()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.answers[currentQuestion] == nil)
            }
        }
        .padding()
    }
}

struct QuestionView: View {
    let question: StyleQuestion
    @Binding var selection: String?

    var body: some View {
        VStack(spacing: 20) {
            Text(question.text)
                .font(.title2)
                .multilineTextAlignment(.center)

            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 16) {
                ForEach(question.options, id: \.self) { option in
                    OptionCard(
                        title: option,
                        isSelected: selection == option
                    ) {
                        selection = option
                    }
                }
            }
        }
    }
}

struct OptionCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 120, height: 100)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

// MARK: - View Model
class StyleQuizViewModel: ObservableObject {
    @Published var answers: [String?] = Array(repeating: nil, count: 5)

    let questions: [StyleQuestion] = [
        StyleQuestion(
            text: "What's your go-to style?",
            options: ["Minimalist", "Classic", "Trendy", "Edgy", "Boho", "Sporty"]
        ),
        StyleQuestion(
            text: "Favorite colors to wear?",
            options: ["Neutrals", "Blues", "Earth Tones", "Pastels", "Bold Colors", "Dark Colors"]
        ),
        StyleQuestion(
            text: "What matters more to you?",
            options: ["Comfort", "Style", "Balanced", "Depends on Occasion"]
        ),
        StyleQuestion(
            text: "What do you do most weeks?",
            options: ["Office Work", "Creative Work", "Physical Activity", "Social Events", "Mix of Everything"]
        ),
        StyleQuestion(
            text: "What's your style goal?",
            options: ["Look Polished", "Save Time", "Build Confidence", "Experiment", "Stay On Trend"]
        )
    ]

    func completeQuiz() {
        // Save answers to user profile
        saveToUserProfile()
    }

    private func saveToUserProfile() {
        // Persist answers
    }
}

struct StyleQuestion {
    let text: String
    let options: [String]
}
```

---

## Step 4: Body Measurements (60 seconds)

**Goal**: Collect body measurements for size recommendations

**Options**:
1. **AR Scan** (Recommended): Quick automated measurement
2. **Manual Entry**: Type in measurements
3. **Skip**: Can add later

**Screen Design**:
```
┌──────────────────────────────────────────┐
│  Body Measurements                       │
│                                          │
│  For accurate size recommendations       │
│                                          │
│  Choose your method:                     │
│                                          │
│  ┌─────────────────────────────────┐    │
│  │  AR Scan (Recommended)          │    │
│  │  Quick & accurate               │    │
│  │  [Start Scan]                   │    │
│  └─────────────────────────────────┘    │
│                                          │
│  ┌─────────────────────────────────┐    │
│  │  Manual Entry                   │    │
│  │  Type your measurements         │    │
│  │  [Enter Manually]               │    │
│  └─────────────────────────────────┘    │
│                                          │
│  [Skip for Now]                          │
│                                          │
│  ℹ️ Your measurements stay on your       │
│     device and are never shared          │
└──────────────────────────────────────────┘
```

**Implementation**:
```swift
struct BodyMeasurementsView: View {
    @State private var showARScan = false
    @State private var showManualEntry = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Body Measurements")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("For accurate size recommendations")
                .font(.title3)
                .foregroundColor(.secondary)

            Spacer()

            VStack(spacing: 16) {
                // AR Scan option
                MeasurementOptionCard(
                    title: "AR Scan",
                    subtitle: "Quick & accurate",
                    icon: "viewfinder",
                    badge: "Recommended"
                ) {
                    showARScan = true
                }

                // Manual entry option
                MeasurementOptionCard(
                    title: "Manual Entry",
                    subtitle: "Type your measurements",
                    icon: "pencil"
                ) {
                    showManualEntry = true
                }
            }

            Spacer()

            Button("Skip for Now") {
                // Skip to next step
            }
            .buttonStyle(.plain)

            // Privacy notice
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.blue)
                Text("Your measurements stay on your device and are never shared")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .padding()
        .fullScreenCover(isPresented: $showARScan) {
            ARMeasurementView()
        }
        .sheet(isPresented: $showManualEntry) {
            ManualMeasurementView()
        }
    }
}

struct MeasurementOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    var badge: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .frame(width: 60)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                        if let badge = badge {
                            Text(badge)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// AR Measurement View
struct ARMeasurementView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ARMeasurementViewModel

    var body: some View {
        ZStack {
            // AR View
            ARViewContainer()

            VStack {
                // Instructions
                Text("Stand 2 meters away")
                    .font(.title2)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding()

                Spacer()

                if viewModel.isScanning {
                    ProgressView("Scanning...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }

                // Controls
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Capture") {
                        viewModel.startScanning()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isScanning)
                }
                .padding()
            }
        }
    }
}

// Manual Measurement View
struct ManualMeasurementView: View {
    @Environment(\.dismiss) var dismiss
    @State private var height: String = ""
    @State private var chest: String = ""
    @State private var waist: String = ""
    @State private var hips: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Body Measurements") {
                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("inches", text: $height)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Chest")
                        Spacer()
                        TextField("inches", text: $chest)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Waist")
                        Spacer()
                        TextField("inches", text: $waist)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Hips")
                        Spacer()
                        TextField("inches", text: $hips)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section {
                    Button("How to Measure") {
                        // Show measurement guide
                    }
                }
            }
            .navigationTitle("Manual Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMeasurements()
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        !height.isEmpty && !chest.isEmpty && !waist.isEmpty && !hips.isEmpty
    }

    private func saveMeasurements() {
        // Save to secure storage
    }
}
```

---

## Step 5: Permission Requests (45 seconds)

**Goal**: Request necessary permissions with clear explanations

**Permissions**:
1. Camera (Required for virtual try-on)
2. Calendar (Optional, for event-based suggestions)
3. Location (Optional, for weather context)

**Screen Design**:
```
┌──────────────────────────────────────────┐
│  Enable Features                         │
│                                          │
│  Grant permissions to unlock full        │
│  functionality                           │
│                                          │
│  ┌─────────────────────────────────┐    │
│  │  📷 Camera Access                │    │
│  │  Required for virtual try-on     │    │
│  │  [Enable]                        │    │
│  └─────────────────────────────────┘    │
│                                          │
│  ┌─────────────────────────────────┐    │
│  │  📅 Calendar Access               │    │
│  │  Outfit suggestions for events   │    │
│  │  [Enable]  [Skip]                │    │
│  └─────────────────────────────────┘    │
│                                          │
│  ┌─────────────────────────────────┐    │
│  │  📍 Location Access               │    │
│  │  Weather-appropriate outfits     │    │
│  │  [Enable]  [Skip]                │    │
│  └─────────────────────────────────┘    │
│                                          │
│              [Continue]                  │
└──────────────────────────────────────────┘
```

**Implementation**:
```swift
struct PermissionsView: View {
    @StateObject var viewModel: PermissionsViewModel

    var body: some View {
        VStack(spacing: 30) {
            Text("Enable Features")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Grant permissions to unlock full functionality")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 16) {
                PermissionCard(
                    icon: "camera.fill",
                    title: "Camera Access",
                    description: "Required for virtual try-on",
                    isRequired: true,
                    status: viewModel.cameraStatus
                ) {
                    await viewModel.requestCamera()
                }

                PermissionCard(
                    icon: "calendar",
                    title: "Calendar Access",
                    description: "Outfit suggestions for events",
                    isRequired: false,
                    status: viewModel.calendarStatus
                ) {
                    await viewModel.requestCalendar()
                }

                PermissionCard(
                    icon: "location.fill",
                    title: "Location Access",
                    description: "Weather-appropriate outfits",
                    isRequired: false,
                    status: viewModel.locationStatus
                ) {
                    await viewModel.requestLocation()
                }
            }

            Spacer()

            Button("Continue") {
                viewModel.completePermissions()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.hasRequiredPermissions)
        }
        .padding()
    }
}

struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isRequired: Bool
    let status: PermissionStatus
    let action: () async -> Void

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 32))
                .frame(width: 50)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                    if isRequired {
                        Text("Required")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Group {
                switch status {
                case .notDetermined:
                    Button("Enable") {
                        Task {
                            await action()
                        }
                    }
                    .buttonStyle(.bordered)
                case .granted:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                case .denied:
                    Button("Settings") {
                        openSettings()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

enum PermissionStatus {
    case notDetermined
    case granted
    case denied
}
```

---

## Step 6: Add First Item (Optional, 45 seconds)

**Goal**: Get user started with at least one wardrobe item

**Options**:
1. Take photo
2. Choose from library
3. Skip (use sample wardrobe)

**Screen Design**:
```
┌──────────────────────────────────────────┐
│  Add Your First Item                     │
│                                          │
│  Let's start building your digital       │
│  wardrobe                                │
│                                          │
│  ┌─────────────────┐                     │
│  │                 │                     │
│  │   [Camera Icon] │                     │
│  │                 │                     │
│  │  Take Photo     │                     │
│  └─────────────────┘                     │
│                                          │
│  ┌─────────────────┐                     │
│  │                 │                     │
│  │  [Library Icon] │                     │
│  │                 │                     │
│  │ Choose Existing │                     │
│  └─────────────────┘                     │
│                                          │
│  [Skip - Use Sample Wardrobe]            │
└──────────────────────────────────────────┘
```

**Implementation**:
```swift
struct AddFirstItemView: View {
    @State private var showCamera = false
    @State private var showPhotoPicker = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Add Your First Item")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Let's start building your digital wardrobe")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 16) {
                BigActionButton(
                    icon: "camera.fill",
                    title: "Take Photo"
                ) {
                    showCamera = true
                }

                BigActionButton(
                    icon: "photo.fill",
                    title: "Choose Existing"
                ) {
                    showPhotoPicker = true
                }
            }

            Spacer()

            Button("Skip - Use Sample Wardrobe") {
                // Complete onboarding with sample data
            }
            .buttonStyle(.plain)
        }
        .padding()
        .fullScreenCover(isPresented: $showCamera) {
            CameraView()
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView()
        }
    }
}

struct BigActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
```

---

## Step 7: Completion & First Outfit (30 seconds)

**Goal**: Celebrate completion and show immediate value

**Screen Design**:
```
┌──────────────────────────────────────────┐
│  You're All Set! 🎉                      │
│                                          │
│  Here's your first outfit suggestion:    │
│                                          │
│  ┌─────────────────────────────────┐    │
│  │                                 │    │
│  │      [Outfit Preview]           │    │
│  │                                 │    │
│  │   • Blue Shirt                  │    │
│  │   • Black Pants                 │    │
│  │   • Brown Shoes                 │    │
│  │                                 │    │
│  │  Perfect for: Casual Friday     │    │
│  │  Weather: 72°F, Sunny           │    │
│  │                                 │    │
│  └─────────────────────────────────┘    │
│                                          │
│       [Try It On]  [See More]           │
│                                          │
└──────────────────────────────────────────┘
```

**Implementation**:
```swift
struct OnboardingCompleteView: View {
    let firstOutfit: Outfit

    var body: some View {
        VStack(spacing: 30) {
            // Celebration
            VStack(spacing: 16) {
                Text("You're All Set!")
                    .font(.system(size: 48))
                Text("🎉")
                    .font(.system(size: 80))
            }

            Text("Here's your first outfit suggestion:")
                .font(.title2)

            // Outfit card
            OutfitCard(outfit: firstOutfit)
                .frame(height: 400)

            // Actions
            HStack(spacing: 20) {
                Button("Try It On") {
                    // Open virtual try-on
                }
                .buttonStyle(.bordered)

                Button("See More") {
                    // Navigate to home
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
```

## 4. Progressive Onboarding

### 4.1 In-App Feature Discovery

**Contextual Tips**:
- Show tooltips when user first encounters a feature
- Highlight new capabilities as they're unlocked
- Celebrate milestones (10 items, first outfit worn)

**Implementation**:
```swift
struct FeatureDiscoveryView: View {
    @State private var showTip = true

    var body: some View {
        ZStack {
            // Main content
            ContentView()

            // Tooltip
            if showTip {
                VStack {
                    Spacer()

                    FeatureTipCard(
                        title: "Tap to Try On",
                        message: "Select any outfit and tap 'Try On' to see it on your body in AR",
                        icon: "hand.tap.fill"
                    ) {
                        showTip = false
                    }
                    .padding()
                }
                .transition(.move(edge: .bottom))
            }
        }
    }
}

struct FeatureTipCard: View {
    let title: String
    let message: String
    let icon: String
    let dismiss: () -> Void

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Button(action: dismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}
```

### 4.2 Empty States

**Empty Wardrobe**:
```swift
struct EmptyWardrobeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "tshirt")
                .font(.system(size: 80))
                .foregroundColor(.secondary)

            Text("Your Wardrobe is Empty")
                .font(.title2)
                .fontWeight(.bold)

            Text("Add your first clothing item to start getting personalized outfit suggestions")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Add Item") {
                // Open add item flow
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}
```

## 5. Onboarding Analytics

### 5.1 Metrics to Track

```swift
struct OnboardingAnalytics {
    // Funnel metrics
    static func trackStep(_ step: OnboardingStep) {
        Analytics.log("onboarding_step_viewed", parameters: [
            "step": step.rawValue,
            "step_number": step.stepNumber
        ])
    }

    static func trackStepCompleted(_ step: OnboardingStep, duration: TimeInterval) {
        Analytics.log("onboarding_step_completed", parameters: [
            "step": step.rawValue,
            "duration_seconds": duration
        ])
    }

    // Completion
    static func trackOnboardingComplete(duration: TimeInterval) {
        Analytics.log("onboarding_completed", parameters: [
            "total_duration_seconds": duration
        ])
    }

    // Drop-off
    static func trackOnboardingAbandoned(atStep step: OnboardingStep) {
        Analytics.log("onboarding_abandoned", parameters: [
            "step": step.rawValue
        ])
    }
}

enum OnboardingStep: String {
    case welcome
    case demo
    case styleQuiz
    case bodyMeasurements
    case permissions
    case addFirstItem
    case complete

    var stepNumber: Int {
        switch self {
        case .welcome: return 1
        case .demo: return 2
        case .styleQuiz: return 3
        case .bodyMeasurements: return 4
        case .permissions: return 5
        case .addFirstItem: return 6
        case .complete: return 7
        }
    }
}
```

## 6. Testing Onboarding

### 6.1 Test Scenarios

```swift
class OnboardingUITests: XCTestCase {
    func testCompleteOnboardingFlow() {
        let app = XCUIApplication()
        app.launch()

        // Welcome
        XCTAssertTrue(app.staticTexts["Wardrobe Consultant"].exists)
        app.buttons["Get Started"].tap()

        // Demo (can skip)
        app.buttons["Skip Demo"].tap()

        // Style quiz
        app.buttons["Minimalist"].tap()
        app.buttons["Next"].tap()
        // ... complete all questions

        // Body measurements (skip)
        app.buttons["Skip for Now"].tap()

        // Permissions
        app.buttons["Enable Camera"].tap()
        // Handle system permission alert
        app.buttons["Continue"].tap()

        // Add first item (skip)
        app.buttons["Skip - Use Sample Wardrobe"].tap()

        // Should see completion
        XCTAssertTrue(app.staticTexts["You're All Set!"].exists)
    }
}
```

## 7. Next Steps

- ✅ Onboarding flow designed
- ⬜ Implement onboarding screens
- ⬜ Create demo video
- ⬜ Add analytics tracking
- ⬜ A/B test onboarding variations
- ⬜ Monitor completion rates

---

**Document Status**: Draft - Ready for Review
**All Design Documents**: ✅ Complete
