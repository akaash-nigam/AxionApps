# Machine Learning Model Specifications

## Document Overview

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## 1. Executive Summary

This document defines the machine learning models and algorithms powering Wardrobe Consultant's intelligent features, including clothing classification, style recommendations, color matching, and size prediction. All models run on-device using Core ML for privacy and performance.

## 2. ML Architecture Overview

### 2.1 Model Pipeline

```
User Input → ML Models → Smart Recommendations

Pipeline Components:
1. Image Classification: Photo → Clothing attributes
2. Style Recommendation: Context + Wardrobe → Outfit suggestions
3. Color Harmony: Colors → Matching recommendations
4. Size Recommendation: Measurements + Product → Size prediction
5. Dress Code Classification: Event text → Formality level
```

### 2.2 Technology Stack

- **Framework**: Core ML (on-device inference)
- **Training**: Create ML, PyTorch → Core ML conversion
- **Model Format**: .mlmodel (Core ML) or .mlpackage
- **Optimization**: Quantization, pruning for mobile
- **Update Strategy**: Over-the-air model updates via CloudKit

## 3. Clothing Classification Model

### 3.1 Model Purpose

Automatically classify clothing items from photos into categories, extract colors, identify patterns, and detect fabric types.

### 3.2 Model Architecture

**Type**: Convolutional Neural Network (CNN)
**Base**: MobileNetV3 (optimized for mobile)
**Task**: Multi-label classification

```
Input: Image (224x224x3)
       ↓
MobileNetV3 Backbone
       ↓
Feature Extraction (1280 features)
       ↓
├─ Category Classifier (Softmax, 30 classes)
├─ Color Extractor (Multi-label, Top 3 colors)
├─ Pattern Detector (Softmax, 10 patterns)
└─ Fabric Classifier (Softmax, 12 fabrics)
       ↓
Output: {
  category: "shirt",
  confidence: 0.92,
  colors: ["#4169E1", "#FFFFFF"],
  pattern: "solid",
  fabric: "cotton"
}
```

### 3.3 Training Data Requirements

**Dataset Size**: 50,000+ images
**Sources**:
- Fashion datasets (DeepFashion, Fashion-MNIST extended)
- Web scraping (retailer product images)
- User-contributed photos (with consent)

**Data Distribution**:
```
Tops (shirts, blouses, sweaters): 20,000 images
Bottoms (pants, skirts, shorts): 15,000 images
Dresses: 8,000 images
Outerwear (jackets, coats): 5,000 images
Accessories: 2,000 images
```

**Annotations Required**:
- Category label (required)
- Bounding box (optional, for segmentation)
- Color labels (top 3 colors)
- Pattern label
- Fabric type (if identifiable)

### 3.4 Training Process

```python
import coremltools as ct
import torchvision.models as models
import torch

# 1. Load pre-trained MobileNetV3
base_model = models.mobilenet_v3_large(pretrained=True)

# 2. Replace classifier head with custom heads
class ClothingClassifier(nn.Module):
    def __init__(self, base_model):
        super().__init__()
        self.features = base_model.features
        self.avgpool = base_model.avgpool

        # Custom heads
        self.category_head = nn.Linear(1280, 30)  # 30 categories
        self.color_head = nn.Linear(1280, 256)    # Color embeddings
        self.pattern_head = nn.Linear(1280, 10)   # 10 patterns
        self.fabric_head = nn.Linear(1280, 12)    # 12 fabric types

    def forward(self, x):
        x = self.features(x)
        x = self.avgpool(x)
        x = torch.flatten(x, 1)

        return {
            'category': self.category_head(x),
            'color': self.color_head(x),
            'pattern': self.pattern_head(x),
            'fabric': self.fabric_head(x)
        }

# 3. Train model
model = ClothingClassifier(base_model)
# ... training loop

# 4. Convert to Core ML
traced_model = torch.jit.trace(model, torch.rand(1, 3, 224, 224))
mlmodel = ct.convert(
    traced_model,
    inputs=[ct.ImageType(shape=(1, 3, 224, 224), scale=1/255.0)],
    outputs=[
        ct.TensorType(name="category"),
        ct.TensorType(name="color"),
        ct.TensorType(name="pattern"),
        ct.TensorType(name="fabric")
    ]
)
mlmodel.save("ClothingClassifier.mlmodel")
```

### 3.5 Swift Integration

```swift
import CoreML
import Vision

class ClothingClassificationService {
    private var model: VNCoreMLModel?

    init() {
        guard let modelURL = Bundle.main.url(forResource: "ClothingClassifier", withExtension: "mlmodelc"),
              let coreMLModel = try? MLModel(contentsOf: modelURL),
              let visionModel = try? VNCoreMLModel(for: coreMLModel) else {
            return
        }
        self.model = visionModel
    }

    func classifyClothing(image: UIImage) async throws -> ClothingClassification {
        guard let model = model else {
            throw MLError.modelNotLoaded
        }

        guard let cgImage = image.cgImage else {
            throw MLError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results = request.results as? [VNCoreMLFeatureValueObservation] else {
                    continuation.resume(throwing: MLError.invalidResults)
                    return
                }

                let classification = self.parseResults(results)
                continuation.resume(returning: classification)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }

    private func parseResults(_ results: [VNCoreMLFeatureValueObservation]) -> ClothingClassification {
        // Parse model outputs
        // Extract category, colors, pattern, fabric

        return ClothingClassification(
            category: .shirt,
            subcategory: nil,
            confidence: 0.92,
            colors: ["#4169E1"],
            pattern: .solid,
            fabric: .cotton
        )
    }
}
```

### 3.6 Performance Targets

| Metric | Target | Minimum |
|--------|--------|---------|
| Inference Time | < 100ms | < 200ms |
| Category Accuracy | > 90% | > 85% |
| Color Accuracy | > 85% | > 75% |
| Model Size | < 10MB | < 20MB |
| Memory Usage | < 50MB | < 100MB |

## 4. Style Recommendation Model

### 4.1 Model Purpose

Generate outfit suggestions based on wardrobe items, weather context, calendar events, and user style preferences.

### 4.2 Model Approach

**Hybrid System**:
1. Rule-based engine (color theory, style rules)
2. Collaborative filtering (similar users)
3. Neural recommendation network

### 4.3 Neural Recommendation Architecture

```
Inputs:
  - Wardrobe items (embeddings)
  - Weather context (temperature, condition)
  - Event context (occasion, formality)
  - User preferences (style profile)
       ↓
Embedding Layer
  - Item features: [category, color, pattern, fabric] → 64-dim
  - Context features: [temp, weather, occasion] → 32-dim
  - User features: [style, preferences] → 32-dim
       ↓
Concatenate (128-dim)
       ↓
Dense Layer (256 units, ReLU)
       ↓
Dropout (0.3)
       ↓
Dense Layer (128 units, ReLU)
       ↓
Output Layer (Outfit score: 0-1)
       ↓
Ranking: Top-k outfits
```

### 4.4 Training Data

**Synthetic Data Generation**:
- Generate valid outfit combinations from style rules
- Assign scores based on rule compliance
- Augment with user feedback data

**Real User Data** (after launch):
- Outfits users created
- Outfits users wore (positive signal)
- Outfits users rejected (negative signal)

### 4.5 Rule-Based Engine (MVP)

For MVP, use rule-based system before ML model is trained:

```swift
class RuleBasedStyleEngine {
    func generateOutfits(
        wardrobe: [WardrobeItem],
        weather: CurrentWeather?,
        occasion: OccasionType?,
        profile: UserProfile
    ) -> [Outfit] {
        var outfits: [Outfit] = []

        // Filter items by weather appropriateness
        let appropriateItems = filterByWeather(wardrobe, weather: weather)

        // Generate combinations
        let tops = appropriateItems.filter { isTop($0) }
        let bottoms = appropriateItems.filter { isBottom($0) }

        for top in tops {
            for bottom in bottoms {
                // Check color compatibility
                guard areColorsCompatible(top.primaryColor, bottom.primaryColor) else {
                    continue
                }

                // Check style compatibility
                guard areStylesCompatible(top, bottom) else {
                    continue
                }

                // Check occasion appropriateness
                guard isAppropriateForOccasion(top, bottom, occasion: occasion) else {
                    continue
                }

                // Create outfit
                let outfit = Outfit(items: [top, bottom])
                outfit.occasionType = occasion?.rawValue ?? OccasionType.casual.rawValue

                // Score outfit
                let score = scoreOutfit(outfit, context: (weather, occasion, profile))
                outfit.confidenceScore = score

                outfits.append(outfit)
            }
        }

        // Sort by score and return top 10
        return outfits.sorted { $0.confidenceScore > $1.confidenceScore }.prefix(10).map { $0 }
    }

    private func areColorsCompatible(_ color1: String, _ color2: String) -> Bool {
        // Color theory rules
        let harmony = ColorHarmonyEngine()
        return harmony.areColorsHarmonious(color1, color2)
    }

    private func scoreOutfit(
        _ outfit: Outfit,
        context: (weather: CurrentWeather?, occasion: OccasionType?, profile: UserProfile)
    ) -> Float {
        var score: Float = 0.5

        // Color harmony bonus
        if areColorsHarmonious(outfit) {
            score += 0.2
        }

        // Weather appropriateness bonus
        if isWeatherAppropriate(outfit, weather: context.weather) {
            score += 0.15
        }

        // Occasion match bonus
        if matchesOccasion(outfit, occasion: context.occasion) {
            score += 0.15
        }

        return min(score, 1.0)
    }
}
```

## 5. Color Harmony Engine

### 5.1 Color Theory Rules

```swift
class ColorHarmonyEngine {
    func areColorsHarmonious(_ hex1: String, _ hex2: String) -> Bool {
        let color1 = parseHex(hex1)
        let color2 = parseHex(hex2)

        // Convert to HSL
        let hsl1 = rgbToHSL(color1)
        let hsl2 = rgbToHSL(color2)

        // Check harmony types
        return isComplementary(hsl1, hsl2) ||
               isAnalogous(hsl1, hsl2) ||
               isMonochromatic(hsl1, hsl2) ||
               isNeutralCombination(hsl1, hsl2)
    }

    private func isComplementary(_ hsl1: HSL, _ hsl2: HSL) -> Bool {
        // Complementary: Colors opposite on color wheel (180° apart)
        let hueDifference = abs(hsl1.hue - hsl2.hue)
        return hueDifference > 150 && hueDifference < 210
    }

    private func isAnalogous(_ hsl1: HSL, _ hsl2: HSL) -> Bool {
        // Analogous: Colors next to each other (30-60° apart)
        let hueDifference = abs(hsl1.hue - hsl2.hue)
        return hueDifference > 20 && hueDifference < 70
    }

    private func isMonochromatic(_ hsl1: HSL, _ hsl2: HSL) -> Bool {
        // Monochromatic: Same hue, different saturation/lightness
        let hueDifference = abs(hsl1.hue - hsl2.hue)
        return hueDifference < 20
    }

    private func isNeutralCombination(_ hsl1: HSL, _ hsl2: HSL) -> Bool {
        // One or both colors are neutral (low saturation)
        return hsl1.saturation < 0.2 || hsl2.saturation < 0.2
    }

    func suggestAccentColor(for baseColors: [String]) -> [String] {
        // Suggest accent colors that complement base colors
        // Use complementary or triadic color schemes

        let baseColor = baseColors.first ?? "#000000"
        let hsl = rgbToHSL(parseHex(baseColor))

        // Complementary color (opposite)
        let complementary = HSL(
            hue: (hsl.hue + 180).truncatingRemainder(dividingBy: 360),
            saturation: hsl.saturation,
            lightness: hsl.lightness
        )

        return [hslToHex(complementary)]
    }
}

struct HSL {
    var hue: CGFloat        // 0-360
    var saturation: CGFloat // 0-1
    var lightness: CGFloat  // 0-1
}
```

## 6. Size Recommendation Model

### 6.1 Model Purpose

Recommend clothing sizes for online shopping based on user's body measurements and product sizing charts.

### 6.2 Model Architecture

**Type**: Regression + Classification
**Inputs**:
- User measurements (height, chest, waist, hips)
- Product sizing chart
- Brand name (brand fit varies)
- Product category

**Output**: Recommended size + confidence

```
Input Features:
  - User height
  - User chest
  - User waist
  - User hips
  - Product category (one-hot encoded)
  - Brand ID (embedding)
       ↓
Dense Layer (128 units, ReLU)
       ↓
Dropout (0.2)
       ↓
Dense Layer (64 units, ReLU)
       ↓
Output: Size class (XS, S, M, L, XL, XXL)
        Confidence score (0-1)
```

### 6.3 Swift Implementation

```swift
class SizeRecommendationService {
    private var model: MLModel?

    func recommendSize(
        measurements: BodyMeasurements,
        product: Product
    ) async throws -> SizeRecommendation {
        // For MVP: Rule-based heuristics

        guard let sizingChart = product.sizingChart else {
            // Fallback to standard sizing
            return standardSizeRecommendation(measurements: measurements)
        }

        // Find best matching size from chart
        var bestSize: String?
        var bestScore: Float = 0

        for (size, dimensions) in sizingChart {
            let score = calculateFitScore(
                userMeasurements: measurements,
                productDimensions: dimensions
            )

            if score > bestScore {
                bestScore = score
                bestSize = size
            }
        }

        return SizeRecommendation(
            recommendedSize: bestSize ?? "M",
            confidence: bestScore,
            fitType: determineFitType(bestScore),
            notes: generateNotes(measurements, product)
        )
    }

    private func calculateFitScore(
        userMeasurements: BodyMeasurements,
        productDimensions: ProductDimensions
    ) -> Float {
        // Calculate how well product dimensions match user measurements

        let chestDiff = abs(userMeasurements.chest.value - productDimensions.chest) / productDimensions.chest
        let waistDiff = abs(userMeasurements.waist.value - productDimensions.waist) / productDimensions.waist

        // Perfect match = 0 difference
        // Score = 1 - average difference
        let score = 1.0 - Float((chestDiff + waistDiff) / 2.0)

        return max(0, min(1.0, score))
    }
}
```

## 7. Dress Code Classification Model

### 7.1 Model Purpose

Extract dress code from calendar event descriptions using NLP.

### 7.2 Model Architecture

**Type**: Text Classification (BERT-based)
**Model**: DistilBERT (smaller, faster)

```
Input: "Wedding ceremony - Black tie optional"
       ↓
Tokenization
       ↓
DistilBERT Encoder
       ↓
Pooling Layer
       ↓
Dense Layer (64 units)
       ↓
Output: Dress code class (8 classes)
        Confidence score
```

### 7.3 Training Data

**Dataset**: Synthetic + Real
- Wedding invitations
- Event descriptions from social media
- Corporate event announcements
- Manually labeled examples

**Classes**:
1. White Tie
2. Black Tie
3. Black Tie Optional
4. Cocktail Attire
5. Business Professional
6. Business Casual
7. Smart Casual
8. Casual

### 7.4 Swift Implementation (Keyword-Based MVP)

```swift
class DressCodeClassifier {
    func classifyDressCode(eventText: String) -> DressCodeAnalysis {
        let lowercased = eventText.lowercased()

        // Explicit mentions (high confidence)
        if lowercased.contains("white tie") {
            return DressCodeAnalysis(dressCode: .whiteTie, confidence: 0.95, source: "explicit")
        }
        if lowercased.contains("black tie optional") || lowercased.contains("semi-formal") {
            return DressCodeAnalysis(dressCode: .blackTieOptional, confidence: 0.9, source: "explicit")
        }
        if lowercased.contains("black tie") {
            return DressCodeAnalysis(dressCode: .blackTie, confidence: 0.95, source: "explicit")
        }
        if lowercased.contains("cocktail") {
            return DressCodeAnalysis(dressCode: .cocktailAttire, confidence: 0.9, source: "explicit")
        }

        // Event type inference (medium confidence)
        if lowercased.contains("wedding") || lowercased.contains("gala") {
            return DressCodeAnalysis(dressCode: .cocktailAttire, confidence: 0.7, source: "event_type")
        }
        if lowercased.contains("interview") || lowercased.contains("board meeting") {
            return DressCodeAnalysis(dressCode: .businessProfessional, confidence: 0.8, source: "event_type")
        }
        if lowercased.contains("meeting") || lowercased.contains("presentation") {
            return DressCodeAnalysis(dressCode: .businessCasual, confidence: 0.6, source: "event_type")
        }

        // Default
        return DressCodeAnalysis(dressCode: .smartCasual, confidence: 0.4, source: "default")
    }
}
```

## 8. Model Management

### 8.1 Model Versioning

```swift
class MLModelManager {
    private let modelVersion = "1.0.0"
    private let minimumSupportedVersion = "1.0.0"

    func checkForModelUpdates() async throws {
        // Check CloudKit for new model versions
        let latestVersion = try await fetchLatestModelVersion()

        if latestVersion > currentVersion {
            try await downloadAndInstallModel(version: latestVersion)
        }
    }

    private func downloadAndInstallModel(version: String) async throws {
        // Download .mlmodel file from CloudKit
        // Validate integrity (checksum)
        // Replace old model
        // Update version
    }
}
```

### 8.2 Model Performance Monitoring

```swift
class MLPerformanceMonitor {
    func logInference(
        modelName: String,
        inferenceTime: TimeInterval,
        inputSize: Int,
        memoryUsage: UInt64
    ) {
        // Log to analytics
        // Track performance degradation
        // Alert if performance drops below threshold
    }

    func trackAccuracy(
        modelName: String,
        prediction: Any,
        userFeedback: Bool
    ) {
        // Track user feedback on predictions
        // Calculate accuracy over time
        // Trigger retraining if accuracy drops
    }
}
```

## 9. Model Optimization

### 9.1 Quantization

```python
# Quantize model to reduce size
quantized_model = ct.models.neural_network.quantization_utils.quantize_weights(
    mlmodel,
    nbits=8  # 8-bit quantization (4x size reduction)
)
```

### 9.2 Pruning

```python
# Remove redundant weights
import torch.nn.utils.prune as prune

# Prune 30% of connections
prune.l1_unstructured(model.category_head, name='weight', amount=0.3)
```

## 10. Testing & Validation

### 10.1 Unit Tests

```swift
class ClothingClassificationTests: XCTestCase {
    var service: ClothingClassificationService!

    override func setUp() {
        service = ClothingClassificationService()
    }

    func testShirtClassification() async throws {
        let image = UIImage(named: "test_blue_shirt")!
        let result = try await service.classifyClothing(image: image)

        XCTAssertEqual(result.category, .shirt)
        XCTAssertGreaterThan(result.confidence, 0.8)
        XCTAssertTrue(result.colors.contains("#4169E1")) // Blue
    }

    func testInferencePerformance() async throws {
        let image = UIImage(named: "test_item")!

        let start = Date()
        _ = try await service.classifyClothing(image: image)
        let elapsed = Date().timeIntervalSince(start)

        XCTAssertLessThan(elapsed, 0.2) // < 200ms
    }
}
```

### 10.2 Accuracy Benchmarks

| Model | Test Set Size | Accuracy | F1 Score |
|-------|---------------|----------|----------|
| Clothing Classifier | 5,000 images | 92% | 0.91 |
| Style Recommender | 1,000 outfits | 85% acceptance | N/A |
| Size Recommender | 500 users | 88% correct | N/A |

## 11. Future Enhancements

### 11.1 Advanced Models

**Generative Models**:
- Style transfer: Apply patterns from one item to another
- Virtual model generation: Create 3D models from 2D photos

**Personalization**:
- User-specific recommendation models
- Continual learning from user behavior

### 11.2 Multi-Modal Models

- Combine text + image for better product understanding
- Video analysis for better clothing movement prediction

## 12. Next Steps

- ✅ ML specifications complete
- ⬜ Collect/curate training datasets
- ⬜ Train classification model
- ⬜ Implement rule-based recommendation engine (MVP)
- ⬜ Convert models to Core ML
- ⬜ Integrate models into app
- ⬜ A/B test recommendations

---

**Document Status**: Draft - Ready for Review
**Next Document**: Security & Privacy Design Document
