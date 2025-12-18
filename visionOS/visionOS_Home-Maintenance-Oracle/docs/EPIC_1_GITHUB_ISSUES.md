# GitHub Issues for Epic 1: Appliance Recognition

Copy and paste these into GitHub Issues to track Epic 1 progress.

---

## Issue #1: Core ML Model Integration

**Title**: [Epic 1] Story 1.1: Core ML Model Integration

**Labels**: `feature`, `epic-1`, `sprint-2`, `ml`

**Assignee**: [ML Engineer]

**Description**:

### User Story
As a developer,
I want to integrate the appliance classifier model,
So that we can recognize appliances from camera feed.

### Epic
Part of Epic 1: Appliance Recognition

### Tasks
- [ ] Research Create ML vs pre-trained model approach
- [ ] Obtain or train ApplianceClassifier model for 10 categories
  - refrigerator, oven, dishwasher, washer, dryer, microwave, hvac, water_heater, garage_door, other
- [ ] Add .mlmodel file to Xcode project (Resources/CoreML/)
- [ ] Update `RecognitionService.swift` to use actual Core ML model
- [ ] Implement image preprocessing pipeline
- [ ] Add confidence threshold logic (85% minimum)
- [ ] Implement result caching (5 min expiry)
- [ ] Write unit tests for classifier (>80% accuracy target)

### Acceptance Criteria
- [ ] Model integrated and loads successfully on app launch
- [ ] Can classify 10 appliance categories
- [ ] Returns confidence scores
- [ ] Low confidence (<85%) returns top 3 alternatives
- [ ] Unit tests pass with >80% accuracy on test set
- [ ] Inference time < 500ms on Vision Pro

### Technical Notes
**Approach A (Quick MVP)**: Use Create ML with existing ImageNet transfer learning
```swift
// In Xcode: Create ML > Image Classifier
// Train on dataset of ~50 images per category
// Export as .mlmodel
```

**Approach B (Better accuracy)**: Fine-tune MobileNetV3
```python
# See ML_MODEL_SPECIFICATIONS.md for training details
```

### Test Images
Need test dataset:
- 10 categories × 10 test images each = 100 images minimum
- Store in `HomeMaintenanceOracleTests/Resources/TestImages/`

### Dependencies
None (can start immediately)

### Estimate
Story Points: 8
Days: 5

---

## Issue #2: Camera Integration

**Title**: [Epic 1] Story 1.2: ARKit Camera Integration

**Labels**: `feature`, `epic-1`, `sprint-2`, `arkit`

**Assignee**: [iOS Developer]

**Description**:

### User Story
As a user,
I want to use my Vision Pro camera,
So that I can capture appliance images for recognition.

### Epic
Part of Epic 1: Appliance Recognition

### Tasks
- [ ] Request camera permissions in `RecognitionViewModel`
- [ ] Implement ARKit scene setup in `RecognitionImmersiveView`
- [ ] Create `CameraService.swift` for camera management
- [ ] Implement live camera feed rendering
- [ ] Add capture button with haptic feedback
- [ ] Implement image capture from ARKit camera
- [ ] Handle camera authorization states (authorized, denied, restricted)
- [ ] Update Info.plist camera usage description (already done ✅)
- [ ] Add error handling for camera failures

### Acceptance Criteria
- [ ] Camera feed displays smoothly in immersive space
- [ ] Can capture still images at full resolution
- [ ] Permission prompt appears on first use
- [ ] Handles permission denied gracefully with helpful message
- [ ] Works in various lighting conditions
- [ ] No memory leaks during extended camera use
- [ ] Frame rate maintained at 60fps

### Technical Notes

**ARKit Camera Setup**:
```swift
// In RecognitionImmersiveView.swift
RealityView { content in
    let cameraAnchor = AnchorEntity(.camera)
    content.add(cameraAnchor)

    // ARKit scene configuration
    let arSession = ARKitSession()
    let worldTracking = WorldTrackingProvider()

    try await arSession.run([worldTracking])
}
```

**Permission Handling**:
```swift
func requestCameraPermission() async -> Bool {
    let status = AVCaptureDevice.authorizationStatus(for: .video)

    switch status {
    case .authorized:
        return true
    case .notDetermined:
        return await AVCaptureDevice.requestAccess(for: .video)
    case .denied, .restricted:
        showPermissionDeniedAlert()
        return false
    @unknown default:
        return false
    }
}
```

### Dependencies
None (can start in parallel with Issue #1)

### Estimate
Story Points: 5
Days: 2

---

## Issue #3: Recognition UI with Spatial Positioning

**Title**: [Epic 1] Story 1.3: Recognition Result UI

**Labels**: `feature`, `epic-1`, `sprint-2`, `ui`

**Assignee**: [UI Developer]

**Description**:

### User Story
As a user,
I want to see recognition results overlaid in space,
So that I know what appliance was detected.

### Epic
Part of Epic 1: Appliance Recognition

### Tasks
- [ ] Update `RecognitionImmersiveView.swift` with production UI
- [ ] Implement floating result card design
- [ ] Show appliance category with icon (from `ApplianceCategory.icon`)
- [ ] Display brand (if detected) and confidence score
- [ ] Add "Save to Inventory" and "Try Again" buttons
- [ ] Position card spatially near detected appliance (1m away, eye level)
- [ ] Implement loading state with progress indicator
- [ ] Add error states:
  - No appliance detected
  - Low confidence (<85%)
  - Model load failed
- [ ] Add success animations
- [ ] Implement hand gesture controls (pinch to dismiss)

### Acceptance Criteria
- [ ] Recognition results display in floating glass card
- [ ] Card positioned spatially near target (uses world anchor)
- [ ] All states handled (loading, success, error, low confidence)
- [ ] UI follows visionOS design guidelines
- [ ] Matches design in `SPATIAL_UX_DESIGN.md`
- [ ] Animations smooth (60fps)
- [ ] Accessible with VoiceOver

### Design Reference
See `docs/SPATIAL_UX_DESIGN.md` - Recognition Flow section

### UI States
1. **Idle**: "Point at an appliance" instructions
2. **Loading**: "Recognizing..." with spinner
3. **Success**: Result card with category, brand, confidence
4. **Low Confidence**: Show top 3 alternatives
5. **Error**: Helpful error message with "Try Again"

### Dependencies
- Depends on Issue #1 (ML model) for actual recognition
- Can use mock data for UI development

### Estimate
Story Points: 5
Days: 3

---

## Issue #4: Manual Entry Fallback

**Title**: [Epic 1] Story 1.4: Manual Appliance Entry

**Labels**: `feature`, `epic-1`, `sprint-2`, `ui`

**Assignee**: [iOS Developer]

**Description**:

### User Story
As a user,
I want to manually enter appliance details,
So that I can add appliances even if recognition fails.

### Epic
Part of Epic 1: Appliance Recognition

### Tasks
- [ ] Create `ApplianceFormView.swift`
- [ ] Implement form fields:
  - [ ] Category picker (10 categories)
  - [ ] Brand text field
  - [ ] Model text field
  - [ ] Serial number text field (optional)
  - [ ] Room location picker
  - [ ] Install date picker (optional)
- [ ] Add photo picker integration (PhotosUI)
- [ ] Implement form validation
  - Brand required
  - Model required
  - Category required
- [ ] Save to Core Data via `InventoryService`
- [ ] Show success confirmation
- [ ] Link from recognition failure screen
- [ ] Add "Enter Manually" button to `HomeView`

### Acceptance Criteria
- [ ] Form displays with all required fields
- [ ] Validation prevents empty submissions
- [ ] Can add appliance manually
- [ ] Photo can be attached from library
- [ ] Saves to Core Data successfully
- [ ] Returns to inventory list after save
- [ ] Works offline (local save, sync later)

### Technical Notes

**Form Structure**:
```swift
struct ApplianceFormView: View {
    @State private var category: ApplianceCategory = .other
    @State private var brand = ""
    @State private var model = ""
    // ... other fields

    var body: some View {
        Form {
            Section("Appliance Type") {
                Picker("Category", selection: $category) {
                    ForEach(ApplianceCategory.allCases) { cat in
                        Label(cat.displayName, systemImage: cat.icon)
                            .tag(cat)
                    }
                }
            }
            // ... more sections
        }
    }
}
```

### Dependencies
None (can start in parallel)

### Estimate
Story Points: 5
Days: 2

---

## Issue #5: Brand Detection (Optional - Can Defer)

**Title**: [Epic 1] Story 1.5: Brand Logo Detection

**Labels**: `feature`, `epic-1`, `sprint-3`, `ml`, `nice-to-have`

**Assignee**: [ML Engineer]

**Description**:

### User Story
As a user,
I want the app to detect the brand,
So that I get more accurate appliance identification.

### Epic
Part of Epic 1: Appliance Recognition

### Tasks
- [ ] Research logo detection approaches:
  - Option A: Separate logo detection Core ML model
  - Option B: OCR on brand labels with Vision framework
  - Option C: Combine both approaches
- [ ] Choose best approach for MVP
- [ ] Implement chosen solution
- [ ] Train on 5 major brands (GE, Whirlpool, Samsung, LG, Bosch)
- [ ] Integrate with `RecognitionService`
- [ ] Add brand confidence score
- [ ] Test with real appliance photos

### Acceptance Criteria
- [ ] Detects at least 5 major brands
- [ ] Brand detection >70% accurate
- [ ] Falls back gracefully if brand not detected
- [ ] Doesn't slow down main recognition (<500ms total)

### Technical Notes

**Option B (Simpler MVP approach)**:
```swift
func detectBrand(in image: CGImage) async throws -> String? {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate

    let handler = VNImageRequestHandler(cgImage: image)
    try handler.perform([request])

    guard let observations = request.results else { return nil }

    // Look for known brands in text
    let knownBrands = ["GE", "WHIRLPOOL", "SAMSUNG", "LG", "BOSCH"]
    for observation in observations {
        for brand in knownBrands {
            if observation.topCandidates(1).first?.string.contains(brand) == true {
                return brand
            }
        }
    }

    return nil
}
```

### Dependencies
- Depends on Issue #1 (main recognition working)
- Can be deferred to Sprint 3 if time constrained

### Estimate
Story Points: 5
Days: 3

**Note**: This is optional for MVP. Defer if Sprint 2 runs long.

---

## Epic 1 Summary

**Total Story Points**: 28
**Total Estimated Days**: 15 days (3 weeks)
**Sprint**: Sprint 2 & Sprint 3

### Priority Order
1. **Issue #1** (ML Model) - CRITICAL - Start Week 3
2. **Issue #2** (Camera) - CRITICAL - Start Week 3 (parallel)
3. **Issue #3** (Recognition UI) - CRITICAL - Start Week 4
4. **Issue #4** (Manual Entry) - HIGH - Start Week 4 (parallel)
5. **Issue #5** (Brand Detection) - LOW - Defer to Sprint 3 or post-MVP

### Sprint 2 Goal
By end of Week 4:
- ✅ ML model recognizes 10 appliance types
- ✅ Camera captures images
- ✅ Recognition UI shows results
- ✅ Can save recognized appliances to inventory

---

## How to Use These Issues

1. **Copy each issue** into GitHub (Issues > New Issue)
2. **Assign to team members** based on skills
3. **Add to Sprint 2 milestone**
4. **Move to project board** (Sprint 2 column)
5. **Link related issues** (e.g., Issue #3 depends on #1)
6. **Track progress** with checkboxes
7. **Close when done** and verified

---

**Created**: 2025-11-24
**Epic**: Epic 1 - Appliance Recognition
**Target**: Weeks 3-5
