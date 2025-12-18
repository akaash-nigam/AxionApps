# ML Model Specifications
## Home Maintenance Oracle

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## Table of Contents

1. [Overview](#overview)
2. [Model 1: Appliance Classifier](#model-1-appliance-classifier)
3. [Model 2: Brand/Model Detector](#model-2-brandmodel-detector)
4. [Model 3: Part Recognition](#model-3-part-recognition)
5. [Model 4: OCR for Model Plates](#model-4-ocr-for-model-plates)
6. [Training Pipeline](#training-pipeline)
7. [Model Evaluation](#model-evaluation)
8. [Deployment Strategy](#deployment-strategy)
9. [Model Updates & Versioning](#model-updates--versioning)
10. [Performance Optimization](#performance-optimization)

---

## Overview

### Model Summary

| Model | Purpose | Type | Accuracy Target | Inference Time | Size |
|-------|---------|------|-----------------|----------------|------|
| Appliance Classifier | Categorize appliance type | Image Classification | 95%+ | <500ms | ~25MB |
| Brand/Model Detector | Identify specific product | Object Detection + Classification | 90%+ | <1s | ~50MB |
| Part Recognition | Identify replacement parts | Object Detection | 85%+ | <1s | ~40MB |
| OCR Engine | Extract model numbers | Text Recognition | 95%+ | <500ms | ~15MB |

### Technology Stack

**Framework**: Core ML + Create ML
**Training**: Python (PyTorch) → Core ML conversion
**Data Annotation**: Roboflow, Label Studio
**MLOps**: GitHub Actions + TestFlight

---

## Model 1: Appliance Classifier

### Purpose

Classify appliances into broad categories from camera feed.

### Architecture

**Base Model**: MobileNetV3-Large (pretrained on ImageNet)
**Modifications**:
- Replace final classification layer (1000 classes → 20 appliance classes)
- Add dropout (0.3) for regularization
- Fine-tune last 3 layers

```python
import torch
import torch.nn as nn
from torchvision import models

class ApplianceClassifier(nn.Module):
    def __init__(self, num_classes=20):
        super().__init__()
        self.model = models.mobilenet_v3_large(pretrained=True)

        # Freeze early layers
        for param in list(self.model.parameters())[:-10]:
            param.requires_grad = False

        # Replace classifier
        self.model.classifier = nn.Sequential(
            nn.Linear(960, 512),
            nn.Hardswish(inplace=True),
            nn.Dropout(p=0.3, inplace=True),
            nn.Linear(512, num_classes)
        )

    def forward(self, x):
        return self.model(x)
```

### Classes (20 Categories)

```python
APPLIANCE_CLASSES = [
    "refrigerator",
    "oven",
    "dishwasher",
    "washing_machine",
    "dryer",
    "microwave",
    "hvac_indoor_unit",
    "hvac_outdoor_unit",
    "water_heater",
    "furnace",
    "garage_door_opener",
    "thermostat",
    "circuit_breaker",
    "water_softener",
    "sump_pump",
    "ceiling_fan",
    "range_hood",
    "garbage_disposal",
    "smoke_detector",
    "other"
]
```

### Training Data Requirements

**Size**: 50,000+ images (2,500 per class minimum)

**Sources**:
1. **Public datasets**:
   - Open Images Dataset (Google)
   - iNaturalist (appliances subset)
2. **Web scraping**:
   - Manufacturer websites
   - Retailer product images (Home Depot, Lowe's)
3. **Crowdsourcing**:
   - Beta testers contribute photos
   - Amazon Mechanical Turk
4. **Synthetic data**:
   - 3D rendered appliances (Blender)
   - Varied lighting, angles, backgrounds

**Data Split**:
- Training: 70% (35,000 images)
- Validation: 15% (7,500 images)
- Test: 15% (7,500 images)

### Data Augmentation

```python
from torchvision import transforms

train_transforms = transforms.Compose([
    transforms.RandomResizedCrop(224, scale=(0.7, 1.0)),
    transforms.RandomHorizontalFlip(p=0.5),
    transforms.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.3),
    transforms.RandomRotation(15),
    transforms.RandomPerspective(distortion_scale=0.2, p=0.5),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                        std=[0.229, 0.224, 0.225])
])
```

### Training Hyperparameters

```python
HYPERPARAMETERS = {
    "batch_size": 32,
    "epochs": 50,
    "learning_rate": 0.001,
    "optimizer": "Adam",
    "weight_decay": 0.0001,
    "lr_scheduler": "ReduceLROnPlateau",
    "early_stopping_patience": 10,
    "loss_function": "CrossEntropyLoss"
}
```

### Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| Top-1 Accuracy | 95% | TBD |
| Top-3 Accuracy | 98% | TBD |
| Inference Time (iPhone 15 Pro) | <500ms | TBD |
| Model Size | <30MB | TBD |

### Core ML Integration

```swift
import CoreML
import Vision

class ApplianceClassificationService {
    private var model: VNCoreMLModel?

    init() {
        guard let modelURL = Bundle.main.url(forResource: "ApplianceClassifier", withExtension: "mlmodelc"),
              let visionModel = try? VNCoreMLModel(for: MLModel(contentsOf: modelURL)) else {
            fatalError("Failed to load model")
        }
        self.model = visionModel
    }

    func classify(image: CGImage) async throws -> ClassificationResult {
        guard let model = model else { throw ModelError.notLoaded }

        let request = VNCoreMLRequest(model: model)
        let handler = VNImageRequestHandler(cgImage: image, options: [:])

        try handler.perform([request])

        guard let results = request.results as? [VNClassificationObservation],
              let topResult = results.first else {
            throw ModelError.noResults
        }

        return ClassificationResult(
            category: topResult.identifier,
            confidence: topResult.confidence,
            alternatives: Array(results.dropFirst().prefix(3))
        )
    }
}

struct ClassificationResult {
    let category: String
    let confidence: Float
    let alternatives: [VNClassificationObservation]
}
```

---

## Model 2: Brand/Model Detector

### Purpose

Detect brand logos and identify specific appliance models.

### Architecture

**Base Model**: YOLOv8 Nano (object detection)
**Task**: Multi-stage detection
1. Detect appliance bounding box
2. Detect brand logo within appliance
3. Classify model based on visual features

```python
from ultralytics import YOLO

# Stage 1: Appliance detection
appliance_model = YOLO('yolov8n.pt')
appliance_model.train(
    data='appliances.yaml',
    epochs=100,
    imgsz=640,
    batch=16
)

# Stage 2: Logo detection
logo_model = YOLO('yolov8n.pt')
logo_model.train(
    data='logos.yaml',
    epochs=100,
    imgsz=320,
    batch=32
)
```

### Brand Classes (50 Major Brands)

```python
BRAND_CLASSES = [
    "GE", "Whirlpool", "Samsung", "LG", "Bosch",
    "KitchenAid", "Maytag", "Frigidaire", "Electrolux",
    "Kenmore", "Amana", "Hotpoint", "Roper",
    "Lennox", "Carrier", "Trane", "Rheem", "AO Smith",
    "Goodman", "York", "Honeywell", "Nest",
    "Chamberlain", "LiftMaster", "Genie",
    # ... 50 total
]
```

### Training Data

**Logo Detection**:
- 10,000+ images with brand logos annotated
- Data sources: Product photos, in-situ photos
- Annotations: Bounding boxes around logos

**Model Recognition**:
- 100,000+ images of specific models
- Labeled with brand + model number
- Varies by angle, lighting, environment

**Annotation Format (YOLO)**:
```
# Format: class_id center_x center_y width height
0 0.458 0.623 0.105 0.087  # Appliance
15 0.480 0.350 0.045 0.032  # GE logo
```

### Training Pipeline

```python
# appliances.yaml
train: ../datasets/appliances/train/images
val: ../datasets/appliances/val/images
test: ../datasets/appliances/test/images

nc: 20  # number of classes
names: ['refrigerator', 'oven', ...]  # class names
```

### Core ML Integration

```swift
import Vision

class BrandModelDetector {
    private let applianceDetector: VNCoreMLModel
    private let logoDetector: VNCoreMLModel

    func detect(image: CGImage) async throws -> DetectionResult {
        // Stage 1: Detect appliance
        let applianceBounds = try await detectAppliance(in: image)

        // Stage 2: Detect logo within appliance bounds
        let croppedImage = image.cropping(to: applianceBounds)!
        let brand = try await detectLogo(in: croppedImage)

        return DetectionResult(
            appliance: applianceBounds,
            brand: brand.name,
            confidence: brand.confidence
        )
    }

    private func detectAppliance(in image: CGImage) async throws -> CGRect {
        let request = VNCoreMLRequest(model: applianceDetector)
        let handler = VNImageRequestHandler(cgImage: image)
        try handler.perform([request])

        guard let results = request.results as? [VNRecognizedObjectObservation],
              let topResult = results.first else {
            throw DetectionError.noApplianceDetected
        }

        return topResult.boundingBox
    }

    private func detectLogo(in image: CGImage) async throws -> (name: String, confidence: Float) {
        let request = VNCoreMLRequest(model: logoDetector)
        let handler = VNImageRequestHandler(cgImage: image)
        try handler.perform([request])

        guard let results = request.results as? [VNRecognizedObjectObservation],
              let topResult = results.first else {
            throw DetectionError.noLogoDetected
        }

        return (topResult.labels.first!.identifier, topResult.confidence)
    }
}
```

### Performance Targets

| Metric | Target |
|--------|--------|
| Logo Detection mAP@0.5 | 90%+ |
| Brand Accuracy | 90%+ |
| Inference Time | <1s |
| Model Size | <50MB |

---

## Model 3: Part Recognition

### Purpose

Identify common replacement parts from images.

### Architecture

**Model**: EfficientNet-B0 (classification)
**Approach**: Single-stage classification of part type

```python
import timm

model = timm.create_model('efficientnet_b0', pretrained=True, num_classes=100)

# Fine-tune on parts dataset
for param in model.parameters():
    param.requires_grad = True  # Train all layers

# Last layer for 100 part types
model.classifier = nn.Sequential(
    nn.Dropout(0.4),
    nn.Linear(1280, 100)
)
```

### Part Classes (100 Common Parts)

```python
PART_CLASSES = [
    # Refrigerator
    "refrigerator_water_filter",
    "refrigerator_ice_maker",
    "refrigerator_door_seal",
    "refrigerator_shelf",
    "refrigerator_crisper_drawer",

    # Dishwasher
    "dishwasher_spray_arm",
    "dishwasher_filter",
    "dishwasher_door_latch",
    "dishwasher_pump",
    "dishwasher_heating_element",

    # HVAC
    "hvac_air_filter",
    "hvac_capacitor",
    "hvac_contactor",
    "hvac_thermostat",

    # Washer/Dryer
    "washer_pump",
    "washer_belt",
    "washer_agitator",
    "dryer_belt",
    "dryer_heating_element",
    "dryer_thermal_fuse",

    # ... 100 total
]
```

### Training Data

**Size**: 30,000+ images (300 per class)

**Sources**:
- Parts supplier websites (RepairClinic, PartSelect)
- iFixit teardown photos
- User-contributed photos
- 3D renders of parts

**Challenges**:
- High similarity between some parts
- Variations in lighting, angle
- Parts in-situ vs. isolated

### Data Preprocessing

```python
# Handle class imbalance with weighted sampling
from torch.utils.data import WeightedRandomSampler

class_counts = [len(os.listdir(f'data/train/{cls}')) for cls in PART_CLASSES]
class_weights = 1. / torch.tensor(class_counts, dtype=torch.float)
sample_weights = [class_weights[label] for _, label in dataset]

sampler = WeightedRandomSampler(
    weights=sample_weights,
    num_samples=len(sample_weights),
    replacement=True
)
```

### Performance Targets

| Metric | Target |
|--------|--------|
| Top-1 Accuracy | 85%+ |
| Top-5 Accuracy | 95%+ |
| Inference Time | <1s |

---

## Model 4: OCR for Model Plates

### Purpose

Extract model numbers, serial numbers, and specifications from appliance labels.

### Architecture

**Approach**: Two-stage OCR
1. Text detection (find text regions)
2. Text recognition (read text)

**Models**:
- Detection: CRAFT (Character Region Awareness for Text Detection)
- Recognition: CRNN (Convolutional Recurrent Neural Network)

### Apple Vision Framework

For MVP, use Apple's Vision framework:

```swift
import Vision

class ModelPlateOCR {
    func extractText(from image: CGImage) async throws -> [String] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false  // Model numbers don't need language correction
        request.recognitionLanguages = ["en-US"]

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        guard let observations = request.results else {
            throw OCRError.noTextDetected
        }

        return observations.compactMap { observation in
            observation.topCandidates(1).first?.string
        }
    }

    func parseModelNumber(from strings: [String]) -> String? {
        // Regex patterns for common model number formats
        let patterns = [
            #"[A-Z]{2,4}\d{3,8}[A-Z]{0,3}"#,  // e.g., GDT695SSJ2SS
            #"Model:\s*([A-Z0-9-]+)"#,          // e.g., Model: ABC-123
            #"M/N:\s*([A-Z0-9-]+)"#             // e.g., M/N: XYZ-456
        ]

        for pattern in patterns {
            for string in strings {
                if let match = string.range(of: pattern, options: .regularExpression) {
                    return String(string[match])
                }
            }
        }

        return nil
    }
}
```

### Custom Model (Future Enhancement)

For improved accuracy on appliance-specific text:

```python
# CRNN architecture
class CRNN(nn.Module):
    def __init__(self, num_classes):
        super().__init__()
        # CNN feature extractor
        self.cnn = nn.Sequential(
            nn.Conv2d(1, 64, 3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2, 2),
            # ... more layers
        )

        # RNN sequence modeling
        self.rnn = nn.LSTM(512, 256, bidirectional=True, batch_first=True)

        # Output layer
        self.fc = nn.Linear(512, num_classes)

    def forward(self, x):
        features = self.cnn(x)
        # Reshape for RNN
        sequence, _ = self.rnn(features)
        output = self.fc(sequence)
        return output
```

### Performance Targets

| Metric | Target |
|--------|--------|
| Character Accuracy | 95%+ |
| Model Number Extraction Rate | 90%+ |
| Inference Time | <500ms |

---

## Training Pipeline

### Infrastructure

**Training Environment**:
- GPU: NVIDIA A100 (cloud) or local Mac Studio (M2 Ultra)
- Framework: PyTorch 2.0+
- Experiment tracking: Weights & Biases

**Pipeline Stages**:
```
Data Collection → Annotation → Training → Evaluation → Conversion → Deployment
```

### Automated Training Pipeline

```python
# train_pipeline.py

import wandb
from torch.utils.data import DataLoader

class TrainingPipeline:
    def __init__(self, config):
        self.config = config
        self.model = self.build_model()
        self.train_loader = self.build_dataloader('train')
        self.val_loader = self.build_dataloader('val')

        wandb.init(project="home-maintenance-oracle", config=config)

    def train(self):
        for epoch in range(self.config['epochs']):
            # Training loop
            train_loss, train_acc = self.train_epoch()

            # Validation loop
            val_loss, val_acc = self.validate()

            # Log metrics
            wandb.log({
                'epoch': epoch,
                'train_loss': train_loss,
                'train_acc': train_acc,
                'val_loss': val_loss,
                'val_acc': val_acc
            })

            # Save checkpoint
            if val_acc > self.best_acc:
                self.save_checkpoint(f'best_model_epoch_{epoch}.pth')

            # Early stopping
            if self.should_stop():
                break

        # Convert to Core ML
        self.convert_to_coreml()

    def convert_to_coreml(self):
        import coremltools as ct

        # Trace model
        traced_model = torch.jit.trace(self.model, example_input)

        # Convert
        mlmodel = ct.convert(
            traced_model,
            inputs=[ct.ImageType(shape=(1, 3, 224, 224))]
        )

        # Save
        mlmodel.save('ApplianceClassifier.mlmodel')
```

### Data Versioning

Use DVC (Data Version Control):

```bash
# Track dataset
dvc add data/appliances
git add data/appliances.dvc
git commit -m "Add appliance dataset v1.0"

# Push to remote storage (S3, Google Drive)
dvc push
```

---

## Model Evaluation

### Metrics

**Classification Models**:
- Accuracy (Top-1, Top-3, Top-5)
- Precision, Recall, F1-score per class
- Confusion matrix
- ROC-AUC

**Detection Models**:
- mAP (mean Average Precision)
- IoU (Intersection over Union)
- Precision-Recall curves

**OCR**:
- Character Error Rate (CER)
- Word Error Rate (WER)
- Exact match rate

### Evaluation Script

```python
def evaluate_model(model, test_loader):
    model.eval()
    all_preds = []
    all_labels = []

    with torch.no_grad():
        for images, labels in test_loader:
            outputs = model(images)
            _, preds = torch.max(outputs, 1)
            all_preds.extend(preds.cpu().numpy())
            all_labels.extend(labels.cpu().numpy())

    # Metrics
    accuracy = accuracy_score(all_labels, all_preds)
    precision = precision_score(all_labels, all_preds, average='weighted')
    recall = recall_score(all_labels, all_preds, average='weighted')
    f1 = f1_score(all_labels, all_preds, average='weighted')

    # Confusion matrix
    cm = confusion_matrix(all_labels, all_preds)

    return {
        'accuracy': accuracy,
        'precision': precision,
        'recall': recall,
        'f1': f1,
        'confusion_matrix': cm
    }
```

### Test Sets

**Diverse Test Data**:
1. **In-domain**: Similar to training (same sources, similar conditions)
2. **Out-of-domain**: Different lighting, angles, backgrounds
3. **Edge cases**: Dirty appliances, partial views, obstructions
4. **Adversarial**: Intentionally challenging examples

---

## Deployment Strategy

### Model Packaging

```swift
// Model metadata
struct ModelMetadata: Codable {
    let version: String
    let createdAt: Date
    let accuracy: Float
    let classes: [String]
    let inputSize: CGSize
}

class ModelManager {
    func loadModel(name: String) throws -> VNCoreMLModel {
        // Check for updated model
        let localVersion = getLocalModelVersion(name)
        let remoteVersion = try await checkRemoteVersion(name)

        if remoteVersion > localVersion {
            try await downloadModel(name, version: remoteVersion)
        }

        // Load model
        let modelURL = getModelURL(name)
        return try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
    }

    private func downloadModel(_ name: String, version: String) async throws {
        let url = URL(string: "https://cdn.hmo.com/models/\(name)_v\(version).mlmodelc")!
        // Download and replace local model
    }
}
```

### Over-the-Air Updates

**Strategy**: Download models on Wi-Fi only

```swift
class ModelUpdateManager {
    func checkForUpdates() async {
        guard Reachability.isConnectedViaWiFi else { return }

        let availableModels = try? await api.getAvailableModels()

        for model in availableModels ?? [] {
            if model.version > localVersion(for: model.name) {
                scheduleDownload(model)
            }
        }
    }

    private func scheduleDownload(_ model: ModelInfo) {
        let request = BGProcessingTaskRequest(identifier: "com.hmo.model-download")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = true  // Only download when charging

        try? BGTaskScheduler.shared.submit(request)
    }
}
```

---

## Model Updates & Versioning

### Versioning Scheme

**Format**: `MAJOR.MINOR.PATCH`
- MAJOR: Breaking changes (new architecture, different input/output)
- MINOR: New classes added, improved accuracy
- PATCH: Bug fixes, minor improvements

**Example**: `1.2.3`

### Continuous Improvement

**Feedback Loop**:
1. User corrections logged
2. Low-confidence predictions flagged
3. Data collected (with consent)
4. Models retrained monthly
5. A/B testing new models

```swift
class ModelFeedback {
    func logCorrection(predicted: String, actual: String, image: UIImage) {
        guard UserPreferences.shared.allowDataCollection else { return }

        let feedback = FeedbackEntry(
            modelVersion: currentModelVersion,
            predicted: predicted,
            actual: actual,
            imageHash: image.hash,  // Don't store actual image
            timestamp: Date()
        )

        analyticsService.log(feedback)
    }
}
```

---

## Performance Optimization

### On-Device Optimization

**Quantization**: Reduce model size and inference time

```python
import coremltools as ct

# Post-training quantization
model_fp32 = ct.models.MLModel('model.mlmodel')
model_int8 = ct.models.neural_network.quantization_utils.quantize_weights(
    model_fp32,
    nbits=8
)
model_int8.save('model_quantized.mlmodel')
```

**Result**: ~4x smaller, ~2x faster, <1% accuracy loss

### Neural Engine Utilization

Ensure models run on Apple Neural Engine:

```swift
let config = MLModelConfiguration()
config.computeUnits = .all  // Use Neural Engine when available

let model = try MLModel(contentsOf: modelURL, configuration: config)
```

### Batch Inference

Process multiple frames efficiently:

```swift
func classifyBatch(images: [CGImage]) async throws -> [ClassificationResult] {
    let requests = images.map { image in
        VNCoreMLRequest(model: model) { request, error in
            // Handle result
        }
    }

    // Process in parallel
    await withTaskGroup(of: ClassificationResult.self) { group in
        for request in requests {
            group.addTask {
                try await self.performRequest(request)
            }
        }

        return await group.reduce(into: []) { $0.append($1) }
    }
}
```

### Caching Predictions

```swift
actor PredictionCache {
    private var cache: [String: ClassificationResult] = [:]

    func get(imageHash: String) -> ClassificationResult? {
        cache[imageHash]
    }

    func set(imageHash: String, result: ClassificationResult) {
        cache[imageHash] = result

        // Evict old entries
        if cache.count > 100 {
            cache.removeFirst()
        }
    }
}
```

---

## Future Enhancements

### Federated Learning

Learn from user data without collecting it:

```swift
// Local training on user device
class FederatedLearningManager {
    func trainLocalModel(on userCorrections: [TrainingExample]) {
        // Fine-tune model locally
        // Upload only model weights (not data) to server
        // Server aggregates weights from many users
    }
}
```

### Multi-Modal Learning

Combine vision + spatial data:

```swift
struct MultiModalInput {
    let image: CGImage
    let spatialContext: ARFrame  // Room layout, depth
    let previousDetections: [Detection]  // Temporal context
}
```

### Active Learning

Prioritize which data to label next:

```python
def select_samples_for_labeling(unlabeled_data, model, budget=1000):
    # Uncertainty sampling
    predictions = model.predict_proba(unlabeled_data)
    uncertainty = 1 - predictions.max(axis=1)

    # Select most uncertain samples
    indices = uncertainty.argsort()[-budget:]
    return unlabeled_data[indices]
```

---

**Document Status**: Ready for Review
**Next Steps**: Begin data collection, set up training pipeline, train baseline models
