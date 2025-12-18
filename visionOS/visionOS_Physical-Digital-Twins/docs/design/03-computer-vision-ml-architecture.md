# Computer Vision & ML Architecture

## Overview

This document defines the computer vision and machine learning strategy for object recognition, the core interaction model for Physical-Digital Twins. The system must identify physical objects in real-time to create and retrieve digital twins.

## Recognition Pipeline

### High-Level Flow

```
┌──────────────────┐
│   Camera Feed    │
│  (ARKit/Vision)  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Frame Capture   │
│  (30 fps sample) │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────────┐
│        Recognition Router            │
│  (Determines recognition method)     │
└────┬─────────┬────────────┬─────────┘
     │         │            │
     ▼         ▼            ▼
┌─────────┐ ┌──────────┐ ┌──────────────┐
│ Barcode │ │  Vision  │ │ Visual Search│
│ Scanner │ │  ML Model│ │  (Similarity)│
└────┬────┘ └────┬─────┘ └──────┬───────┘
     │           │               │
     └───────────┴───────────────┘
                 │
                 ▼
         ┌───────────────┐
         │  Recognition  │
         │    Result     │
         └───────┬───────┘
                 │
                 ▼
         ┌───────────────┐
         │  Enrichment   │
         │  (API Calls)  │
         └───────┬───────┘
                 │
                 ▼
         ┌───────────────┐
         │ Digital Twin  │
         │   Creation    │
         └───────────────┘
```

## Recognition Methods

### 1. Barcode/QR Code Scanning

**Use Case**: Fastest and most accurate for packaged goods

**Implementation**:
```swift
import Vision

class BarcodeScanner {
    func scanBarcode(from image: CIImage) async throws -> BarcodeResult? {
        let request = VNDetectBarcodesRequest()
        request.symbologies = [
            .ean8, .ean13,      // European Article Numbers
            .upce, .upca,       // Universal Product Codes
            .qr,                // QR codes
            .code128, .code39,  // General barcodes
            .itf14, .dataMatrix // Additional formats
        ]

        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        try handler.perform([request])

        guard let results = request.results,
              let first = results.first,
              let payload = first.payloadStringValue else {
            return nil
        }

        return BarcodeResult(
            type: first.symbology,
            value: payload,
            confidence: first.confidence,
            boundingBox: first.boundingBox
        )
    }
}

struct BarcodeResult {
    let type: VNBarcodeSymbology
    let value: String
    let confidence: Float
    let boundingBox: CGRect
}
```

**Performance**:
- Detection time: <100ms
- Accuracy: >99% in good lighting
- Range: 10cm - 1m optimal

**Error Handling**:
- Poor lighting: Prompt user to adjust angle
- Partial barcode: Wait for full visibility
- Unknown barcode: Fall back to product API search

### 2. Core ML Object Classification

**Use Case**: General object recognition (books, furniture, electronics)

#### Model Selection

**Option A: Pre-trained Models**
```swift
// Use built-in Vision models
import Vision

let model = try VNCoreMLModel(for: MobileNetV3(configuration: MLModelConfiguration()).model)
let request = VNCoreMLRequest(model: model)
```

Advantages:
- Available immediately
- Good general object classification
- Optimized for Apple Silicon

Disadvantages:
- Not specialized for our use case
- Limited to ImageNet classes
- May need fine-tuning

**Option B: Custom Trained Model (Recommended)**
```
Training approach:
1. Collect dataset of common household objects (100k+ images)
2. Fine-tune MobileNetV3 or EfficientNet
3. Train for our specific categories
4. Export to Core ML format
5. Optimize for Neural Engine
```

Categories to train:
- Books (by cover)
- Furniture types (chair, table, sofa, desk, etc.)
- Electronics (TV, laptop, phone, camera, etc.)
- Appliances (microwave, blender, toaster, etc.)
- Food packaging (recognizable packages)
- Tools
- Plants (common varieties)

#### Model Architecture

```swift
class ObjectClassificationModel {
    private let model: VNCoreMLModel
    private let threshold: Float = 0.7

    init() throws {
        // Load our custom trained model
        let config = MLModelConfiguration()
        config.computeUnits = .all // Use Neural Engine + GPU + CPU

        let mlModel = try PhysicalObjectClassifier(configuration: config).model
        self.model = try VNCoreMLModel(for: mlModel)
    }

    func classify(image: CIImage) async throws -> ClassificationResult {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first,
                      topResult.confidence > self.threshold else {
                    continuation.resume(throwing: VisionError.lowConfidence)
                    return
                }

                let result = ClassificationResult(
                    category: ObjectCategory(from: topResult.identifier),
                    confidence: topResult.confidence,
                    alternatives: results.prefix(3).map {
                        (ObjectCategory(from: $0.identifier), $0.confidence)
                    }
                )
                continuation.resume(returning: result)
            }

            request.imageCropAndScaleOption = .centerCrop

            let handler = VNImageRequestHandler(ciImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

struct ClassificationResult {
    let category: ObjectCategory
    let confidence: Float
    let alternatives: [(ObjectCategory, Float)]
}
```

#### Training Pipeline

```python
# Training script outline (using Create ML or TensorFlow)

# 1. Dataset preparation
dataset_structure = {
    "books/": ["book_001.jpg", "book_002.jpg", ...],
    "furniture_chair/": [...],
    "furniture_table/": [...],
    "electronics_tv/": [...],
    # ... etc
}

# 2. Data augmentation
augmentations = [
    RandomRotation(degrees=15),
    RandomLighting(brightness=0.2),
    RandomCrop(scale=0.8),
    Flip(horizontal=True),
]

# 3. Fine-tune MobileNetV3
base_model = MobileNetV3Large(pretrained=True)
model = FineTuneClassifier(
    base_model=base_model,
    num_classes=len(our_categories),
    freeze_layers=100  # Freeze early layers
)

# 4. Train
train(
    model=model,
    epochs=50,
    batch_size=128,
    learning_rate=0.001,
    validation_split=0.2
)

# 5. Export to Core ML
coreml_model = ct.convert(
    model,
    inputs=[ct.ImageType(shape=(1, 3, 224, 224))],
    compute_precision=ct.precision.FLOAT16  # Neural Engine optimization
)
coreml_model.save("PhysicalObjectClassifier.mlmodel")
```

**Model Metrics**:
- Target accuracy: >85% top-1, >95% top-3
- Inference time: <200ms on Neural Engine
- Model size: <50MB (for app bundle)

### 3. Image Similarity Search

**Use Case**: Unique items without barcodes (books by cover, collectibles)

#### Approach: Feature Extraction + Nearest Neighbor

```swift
import Vision

class ImageSimilaritySearch {
    private let featureExtractor: VNCoreMLModel
    private let index: ImageSearchIndex

    init() throws {
        // Use a feature extraction model (e.g., ResNet50 without classifier)
        let model = try VNCoreMLModel(for: FeatureExtractor().model)
        self.featureExtractor = model
        self.index = ImageSearchIndex()
    }

    func extractFeatures(from image: CIImage) async throws -> [Float] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: featureExtractor) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                // Extract feature vector from model output
                guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                      let features = results.first?.featureValue.multiArrayValue else {
                    continuation.resume(throwing: VisionError.featureExtractionFailed)
                    return
                }

                // Convert MLMultiArray to [Float]
                let featureVector = self.multiArrayToFloatArray(features)
                continuation.resume(returning: featureVector)
            }

            let handler = VNImageRequestHandler(ciImage: image, options: [:])
            try? handler.perform([request])
        }
    }

    func findSimilar(to query: CIImage, topK: Int = 5) async throws -> [SimilarityMatch] {
        let queryFeatures = try await extractFeatures(from: query)
        return index.search(features: queryFeatures, topK: topK)
    }

    private func multiArrayToFloatArray(_ multiArray: MLMultiArray) -> [Float] {
        let count = multiArray.count
        let pointer = multiArray.dataPointer.assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: pointer, count: count))
    }
}

struct SimilarityMatch {
    let twinID: UUID
    let similarity: Float // Cosine similarity 0-1
    let thumbnail: UIImage?
}
```

#### Search Index Implementation

```swift
class ImageSearchIndex {
    private var index: [(twinID: UUID, features: [Float])] = []

    func add(twinID: UUID, features: [Float]) {
        index.append((twinID, features))
    }

    func search(features: [Float], topK: Int) -> [SimilarityMatch] {
        // Compute cosine similarity with all indexed items
        let similarities = index.map { item -> (UUID, Float) in
            let similarity = cosineSimilarity(features, item.features)
            return (item.twinID, similarity)
        }

        // Return top K matches
        return similarities
            .sorted { $0.1 > $1.1 }
            .prefix(topK)
            .map { SimilarityMatch(twinID: $0.0, similarity: $0.1, thumbnail: nil) }
    }

    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        let dotProduct = zip(a, b).reduce(0.0) { $0 + $1.0 * $1.1 }
        let magnitudeA = sqrt(a.reduce(0.0) { $0 + $1 * $1 })
        let magnitudeB = sqrt(b.reduce(0.0) { $0 + $1 * $1 })
        return dotProduct / (magnitudeA * magnitudeB)
    }
}

// For large datasets (>10k items), consider using:
// - Accelerate framework's vDSP for optimized vector operations
// - Approximate Nearest Neighbors (ANN) library like FAISS
```

### 4. OCR for Text Extraction

**Use Case**: Extract expiration dates, product names, model numbers

```swift
import Vision

class TextExtractor {
    func extractText(from image: CIImage, language: String = "en-US") async throws -> [TextObservation] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let results = observations.compactMap { observation -> TextObservation? in
                    guard let topCandidate = observation.topCandidates(1).first else {
                        return nil
                    }
                    return TextObservation(
                        text: topCandidate.string,
                        confidence: topCandidate.confidence,
                        boundingBox: observation.boundingBox
                    )
                }

                continuation.resume(returning: results)
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = [language]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(ciImage: image, options: [:])
            try? handler.perform([request])
        }
    }

    func extractExpirationDate(from image: CIImage) async throws -> Date? {
        let textObservations = try await extractText(from: image)

        // Look for date patterns
        let datePatterns = [
            "EXP:? (\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4})",  // EXP: MM/DD/YYYY
            "Best by:? (\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4})", // Best by MM/DD/YYYY
            "(\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4})",        // Plain date
            "USE BY (\\d{2} [A-Z]{3} \\d{4})",           // USE BY 15 NOV 2024
        ]

        for observation in textObservations {
            for pattern in datePatterns {
                if let date = extractDate(from: observation.text, pattern: pattern) {
                    return date
                }
            }
        }

        return nil
    }

    private func extractDate(from text: String, pattern: String) -> Date? {
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(text.startIndex..., in: text)

        guard let match = regex?.firstMatch(in: text, range: range),
              let dateRange = Range(match.range(at: 1), in: text) else {
            return nil
        }

        let dateString = String(text[dateRange])
        return DateParser.parse(dateString)
    }
}

struct TextObservation {
    let text: String
    let confidence: Float
    let boundingBox: CGRect
}
```

## Recognition Router

### Intelligent Method Selection

```swift
class RecognitionRouter {
    private let barcodeScanner: BarcodeScanner
    private let objectClassifier: ObjectClassificationModel
    private let imageSimilarity: ImageSimilaritySearch
    private let textExtractor: TextExtractor

    func recognize(image: CIImage) async throws -> RecognitionResult {
        // 1. Try barcode first (fastest and most accurate)
        if let barcode = try? await barcodeScanner.scanBarcode(from: image) {
            return RecognitionResult(
                method: .barcode,
                identifier: barcode.value,
                confidence: barcode.confidence
            )
        }

        // 2. Try ML classification
        if let classification = try? await objectClassifier.classify(image: image) {
            if classification.confidence > 0.8 {
                return RecognitionResult(
                    method: .vision,
                    category: classification.category,
                    confidence: classification.confidence
                )
            }
        }

        // 3. Try visual similarity search for books
        if let bookMatches = try? await imageSimilarity.findSimilar(to: image),
           let bestMatch = bookMatches.first,
           bestMatch.similarity > 0.85 {
            return RecognitionResult(
                method: .imageSimilarity,
                twinID: bestMatch.twinID,
                confidence: bestMatch.similarity
            )
        }

        // 4. Last resort: Extract text for manual matching
        if let text = try? await textExtractor.extractText(from: image),
           !text.isEmpty {
            return RecognitionResult(
                method: .ocr,
                extractedText: text.map { $0.text },
                confidence: 0.5
            )
        }

        // 5. No recognition possible
        throw RecognitionError.unrecognized
    }
}

struct RecognitionResult {
    let method: RecognitionMethod
    var identifier: String?       // For barcodes
    var category: ObjectCategory?  // For classification
    var twinID: UUID?             // For similarity match
    var extractedText: [String]?  // For OCR
    let confidence: Float
}
```

## Performance Optimization

### 1. Frame Sampling Strategy

```swift
class CameraCaptureManager {
    private var lastProcessedTime: Date = .distantPast
    private let processingInterval: TimeInterval = 0.5 // Process every 500ms (2 fps)

    func shouldProcessFrame() -> Bool {
        let now = Date()
        if now.timeIntervalSince(lastProcessedTime) >= processingInterval {
            lastProcessedTime = now
            return true
        }
        return false
    }
}
```

**Rationale**: Processing every frame (30fps) is unnecessary and wastes battery. 2fps sampling is sufficient for object recognition.

### 2. Neural Engine Optimization

```swift
let config = MLModelConfiguration()
config.computeUnits = .all  // Use Neural Engine + GPU + CPU

// Alternatively, force Neural Engine only for best efficiency
config.computeUnits = .cpuAndNeuralEngine
```

**Performance Targets**:
- Barcode scan: <100ms
- ML classification: <200ms on Neural Engine
- Image similarity: <300ms (with indexed search)
- OCR: <500ms

### 3. Image Preprocessing

```swift
func preprocessImage(_ image: CIImage) -> CIImage {
    // 1. Crop to center (reduce resolution)
    let cropRect = CGRect(
        x: image.extent.width * 0.25,
        y: image.extent.height * 0.25,
        width: image.extent.width * 0.5,
        height: image.extent.height * 0.5
    )
    let cropped = image.cropped(to: cropRect)

    // 2. Resize to model input size (224x224 for most models)
    let scale = 224.0 / max(cropped.extent.width, cropped.extent.height)
    let resized = cropped.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

    // 3. Normalize (if needed by model)
    return resized
}
```

### 4. Background Processing

```swift
@MainActor
class ObjectRecognitionViewModel: ObservableObject {
    @Published var recognizedObject: RecognitionResult?
    @Published var isProcessing = false

    private let recognitionQueue = DispatchQueue(
        label: "com.app.recognition",
        qos: .userInitiated
    )

    func processFrame(_ image: CIImage) {
        guard !isProcessing else { return }

        isProcessing = true

        Task {
            do {
                // Recognition runs off main thread
                let result = try await recognitionRouter.recognize(image: image)

                // UI update on main thread
                await MainActor.run {
                    self.recognizedObject = result
                    self.isProcessing = false
                }
            } catch {
                await MainActor.run {
                    self.isProcessing = false
                    // Handle error
                }
            }
        }
    }
}
```

## Model Management

### Model Updates

```swift
class MLModelManager {
    private let modelURL: URL
    private let remoteModelURL = URL(string: "https://api.yourapp.com/models/latest")!

    func checkForUpdates() async throws {
        // 1. Fetch model metadata from server
        let metadata = try await fetchModelMetadata()

        // 2. Compare version with local model
        if metadata.version > currentModelVersion {
            // 3. Download new model in background
            try await downloadModel(url: metadata.downloadURL)

            // 4. Swap model (will take effect on next app launch)
            try replaceModel()
        }
    }

    private func fetchModelMetadata() async throws -> ModelMetadata {
        let (data, _) = try await URLSession.shared.data(from: remoteModelURL)
        return try JSONDecoder().decode(ModelMetadata.self, from: data)
    }
}

struct ModelMetadata: Codable {
    let version: Int
    let downloadURL: URL
    let checksum: String
    let size: Int64
}
```

### Model Versioning

```
Models are versioned and stored in app bundle:
PhysicalObjectClassifier_v1.mlmodel  (initial release)
PhysicalObjectClassifier_v2.mlmodel  (improved accuracy)
PhysicalObjectClassifier_v3.mlmodel  (new categories)

Over-the-air updates stored in:
~/Library/Application Support/Models/
```

## Accuracy & Metrics

### Evaluation Metrics

```swift
struct RecognitionMetrics {
    var totalAttempts: Int = 0
    var successfulRecognitions: Int = 0
    var averageConfidence: Float = 0
    var averageLatency: TimeInterval = 0

    var successRate: Float {
        Float(successfulRecognitions) / Float(max(totalAttempts, 1))
    }

    mutating func record(success: Bool, confidence: Float, latency: TimeInterval) {
        totalAttempts += 1
        if success {
            successfulRecognitions += 1
        }
        averageConfidence = (averageConfidence * Float(totalAttempts - 1) + confidence) / Float(totalAttempts)
        averageLatency = (averageLatency * Double(totalAttempts - 1) + latency) / Double(totalAttempts)
    }
}
```

### Target Metrics

| Metric | Target | Notes |
|--------|--------|-------|
| Barcode accuracy | >99% | In good lighting |
| ML classification (top-1) | >85% | Known objects |
| ML classification (top-3) | >95% | User can select |
| Image similarity | >80% | Books by cover |
| OCR date extraction | >90% | Clear text |
| Average latency | <500ms | Total pipeline |
| Success rate | >80% | Overall recognition |

## Error Handling

### Failure Modes & Fallbacks

```swift
enum RecognitionError: Error {
    case unrecognized
    case lowConfidence
    case poorLighting
    case objectTooFar
    case modelLoadFailed
    case timeout
}

extension RecognitionRouter {
    func handleFailure(_ error: RecognitionError, image: CIImage) -> UserGuidance {
        switch error {
        case .unrecognized:
            return .showManualEntry("We couldn't identify this object. Try scanning a barcode or enter details manually.")

        case .lowConfidence:
            return .suggestAlternative("Not sure what this is. Try getting closer or scanning a barcode.")

        case .poorLighting:
            return .adjustEnvironment("Too dark. Move to better lighting or turn on a light.")

        case .objectTooFar:
            return .moveCloser("Move closer to the object (10-50cm optimal).")

        case .modelLoadFailed:
            return .criticalError("Recognition unavailable. Please restart the app.")

        case .timeout:
            return .retry("Recognition took too long. Please try again.")
        }
    }
}

enum UserGuidance {
    case showManualEntry(String)
    case suggestAlternative(String)
    case adjustEnvironment(String)
    case moveCloser(String)
    case criticalError(String)
    case retry(String)
}
```

## Future Enhancements

### Phase 2: Advanced Features

1. **Multi-object Detection**: Detect multiple objects in single frame
2. **3D Object Recognition**: Use depth sensor for better furniture identification
3. **Continuous Learning**: Upload anonymized failures for model retraining
4. **Context-Aware Recognition**: Use location to bias predictions (kitchen → food)
5. **Federated Learning**: On-device model improvements

### Phase 3: Advanced ML

1. **Object Segmentation**: Precise object boundaries for AR anchoring
2. **Pose Estimation**: Understand object orientation
3. **State Recognition**: Recognize open/closed, full/empty, new/used
4. **Material Recognition**: Identify materials (wood, plastic, metal)

## Testing Strategy

### Unit Tests

```swift
class ObjectClassifierTests: XCTestCase {
    func testBookRecognition() async throws {
        let classifier = try ObjectClassificationModel()
        let testImage = CIImage(named: "test_book_cover")!

        let result = try await classifier.classify(image: testImage)

        XCTAssertEqual(result.category, .book)
        XCTAssertGreaterThan(result.confidence, 0.8)
    }

    func testLowConfidenceHandling() async throws {
        let classifier = try ObjectClassificationModel()
        let ambiguousImage = CIImage(named: "test_ambiguous")!

        do {
            _ = try await classifier.classify(image: ambiguousImage)
            XCTFail("Should throw low confidence error")
        } catch VisionError.lowConfidence {
            // Expected
        }
    }
}
```

### Integration Tests

```swift
class RecognitionPipelineTests: XCTestCase {
    func testEndToEndBookRecognition() async throws {
        let router = RecognitionRouter()
        let bookImage = CIImage(named: "test_atomic_habits_cover")!

        let result = try await router.recognize(image: bookImage)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.method, .vision)
        XCTAssertEqual(result.category, .book)
    }

    func testBarcodeFallback() async throws {
        // Test that barcode is tried first before vision
    }
}
```

### Performance Tests

```swift
class RecognitionPerformanceTests: XCTestCase {
    func testRecognitionLatency() async throws {
        let router = RecognitionRouter()
        let testImage = CIImage(named: "test_object")!

        let start = Date()
        _ = try await router.recognize(image: testImage)
        let latency = Date().timeIntervalSince(start)

        XCTAssertLessThan(latency, 0.5) // 500ms target
    }
}
```

## Summary

This computer vision architecture provides:
- **Multi-modal Recognition**: Barcode, ML, similarity search, OCR
- **High Accuracy**: >85% classification, >99% barcode scanning
- **Low Latency**: <500ms end-to-end recognition
- **Efficient**: Neural Engine optimization, frame sampling
- **Robust**: Graceful fallbacks and error handling
- **Extensible**: Easy to add new models and methods

The recognition pipeline is the core of the user experience—when a user points at an object, they expect instant, accurate identification. This architecture ensures that happens reliably.
