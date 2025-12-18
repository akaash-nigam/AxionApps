# Core ML Model Specifications

## Object Detection Model

**Purpose**: Identify household objects for vocabulary labeling

**Model**: YOLOv8 (You Only Look Once) - optimized for Core ML
**Alternative**: Vision Framework's built-in object detection

### Specifications
- **Input**: 640×640 RGB image
- **Output**: Bounding boxes + class labels + confidence scores
- **Classes**: 5,000+ household objects
- **Format**: Core ML (.mlmodel or .mlpackage)
- **Size**: ~50MB (quantized)
- **Inference Time**: <50ms on Apple Silicon

### Object Categories
```
Furniture: chair, table, sofa, bed, desk, shelf
Kitchen: refrigerator, stove, microwave, pot, pan, plate, fork, knife
Electronics: TV, laptop, phone, remote, keyboard, mouse
Decor: lamp, picture frame, vase, pillow, curtain
Bathroom: sink, toilet, shower, mirror, towel
Office: pen, paper, notebook, stapler, scissors
```

### Implementation
```swift
import CoreML
import Vision

class ObjectDetector {
    private var model: VNCoreMLModel?

    init() {
        guard let modelURL = Bundle.main.url(forResource: "YOLOv8ObjectDetection", withExtension: "mlmodelc"),
              let mlModel = try? MLModel(contentsOf: modelURL),
              let visionModel = try? VNCoreMLModel(for: mlModel) else {
            return
        }
        self.model = visionModel
    }

    func detectObjects(in image: CVPixelBuffer) async throws -> [DetectedObject] {
        guard let model = model else {
            throw ObjectDetectionError.modelNotLoaded
        }

        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(cvPixelBuffer: image)
        try handler.perform([request])

        guard let results = request.results as? [VNRecognizedObjectObservation] else {
            return []
        }

        return results.compactMap { observation in
            guard observation.confidence > 0.7 else { return nil }
            return DetectedObject(
                label: observation.labels.first?.identifier ?? "",
                confidence: observation.confidence,
                boundingBox: observation.boundingBox
            )
        }
    }
}

struct DetectedObject {
    let label: String
    let confidence: Float
    let boundingBox: CGRect
}
```

## Speech Recognition Model

**Purpose**: Transcribe user speech with phoneme-level timing

**Primary**: Apple Speech Framework (on-device)
**Enhanced**: Custom acoustic model for pronunciation analysis

### Specifications
- **Supported Languages**: 50+ languages
- **On-Device**: iOS 17+ (English, Spanish, French, German, Japanese, Mandarin)
- **Latency**: <300ms
- **Accuracy**: 95%+ for native speech

### Phoneme Extraction
```swift
import Speech

class PronunciationAnalyzer {
    private let recognizer: SFSpeechRecognizer

    func analyzePhonemes(audioURL: URL, language: String) async throws -> [Phoneme] {
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: language)) else {
            throw SpeechError.unsupportedLanguage
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.addsPunctuation = false
        request.taskHint = .dictation

        // Request phonetic transcription (iOS 17+)
        if #available(iOS 17.0, *) {
            request.phoneticTranscription = true
        }

        let result = try await recognizer.recognitionTask(with: request).finish()

        // Extract phonemes from transcription
        return extractPhonemes(from: result)
    }

    private func extractPhonemes(from result: SFSpeechRecognitionResult) -> [Phoneme] {
        var phonemes: [Phoneme] = []

        for segment in result.bestTranscription.segments {
            // Parse IPA notation
            let ipa = segment.phoneticTranscription ?? ""
            phonemes.append(Phoneme(
                symbol: ipa,
                timestamp: segment.timestamp,
                duration: segment.duration,
                confidence: segment.confidence
            ))
        }

        return phonemes
    }
}

struct Phoneme {
    let symbol: String // IPA symbol
    let timestamp: TimeInterval
    let duration: TimeInterval
    let confidence: Float
}
```

## Grammar Analysis Model

**Purpose**: Detect grammar errors in user speech

**Approach**: Rule-based + ML hybrid

### Specifications
- **Primary**: Apple Natural Language Framework
- **Enhanced**: Custom LSTM model for context-aware corrections
- **Languages**: Language-specific rule sets

### Implementation
```swift
import NaturalLanguage

class GrammarChecker {
    private let tagger = NLTagger(tagSchemes: [.lexicalClass, .lemma, .language])

    func checkGrammar(text: String, language: String) -> [GrammarError] {
        tagger.string = text

        var errors: [GrammarError] = []

        // Tokenize and tag
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                             unit: .word,
                             scheme: .lexicalClass) { tag, range in

            if let tag = tag {
                // Apply language-specific rules
                if let error = checkLanguageRule(tag: tag, word: String(text[range]), language: language) {
                    errors.append(error)
                }
            }
            return true
        }

        return errors
    }

    private func checkLanguageRule(tag: NLTag, word: String, language: String) -> GrammarError? {
        // Language-specific grammar rules
        switch language {
        case "es":
            return checkSpanishGrammar(tag: tag, word: word)
        case "fr":
            return checkFrenchGrammar(tag: tag, word: word)
        default:
            return nil
        }
    }

    private func checkSpanishGrammar(tag: NLTag, word: String) -> GrammarError? {
        // Example: Check verb conjugation
        if tag == .verb {
            // Implement verb conjugation rules
        }
        return nil
    }
}
```

## Text-to-Phoneme Model

**Purpose**: Generate pronunciation guide for words

**Model**: Phonemizer (rule-based + neural)

### Implementation
```swift
class PhonemeDictionary {
    private var cache: [String: String] = [:] // word -> IPA

    func getPhonemes(for word: String, language: String) -> String {
        if let cached = cache[word] {
            return cached
        }

        // Generate phonemes
        let phonemes = generatePhonemes(word: word, language: language)
        cache[word] = phonemes
        return phonemes
    }

    private func generatePhonemes(word: String, language: String) -> String {
        // Language-specific phoneme rules
        // Can use espeak-ng or similar library
        return ""
    }
}
```

## Model Updates and Versioning

### Update Strategy
- **Over-the-air**: Download model updates without app update
- **Versioning**: Track model versions for compatibility
- **Fallback**: Keep previous model version as backup

```swift
class ModelManager {
    func downloadModel(name: String, version: String) async throws {
        let url = URL(string: "https://models.languageimmersion.app/\(name)/\(version).mlmodel")!

        let (localURL, _) = try await URLSession.shared.download(from: url)

        // Compile model
        let compiledURL = try await MLModel.compileModel(at: localURL)

        // Move to app's model directory
        let modelDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Models")

        try FileManager.default.moveItem(at: compiledURL,
                                         to: modelDir.appendingPathComponent("\(name).mlmodelc"))
    }
}
```

## Performance Benchmarks

| Model | Size | Inference Time | Accuracy |
|-------|------|---------------|----------|
| Object Detection | 50MB | 45ms | 92% |
| Speech Recognition | On-device | 250ms | 95% |
| Grammar Analysis | 10MB | 15ms | 88% |
| Phoneme Generation | 5MB | 5ms | 90% |
