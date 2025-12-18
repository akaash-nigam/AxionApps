//
//  PerformanceTests.swift
//  Language Immersion Rooms Tests
//
//  Performance and load tests
//
//  ⚠️  REQUIRES: Xcode Instruments and profiling tools
//  These tests measure performance characteristics
//

import XCTest
@testable import LanguageImmersionRooms

final class PerformanceTests: XCTestCase {

    // MARK: - Service Performance

    func testVocabularyServiceTranslationPerformance() {
        let service = VocabularyService()

        measure {
            for _ in 0..<10000 {
                _ = service.translate("table", to: .spanish)
            }
        }
    }

    func testVocabularyServiceGetAllWordsPerformance() {
        let service = VocabularyService()

        measure {
            for _ in 0..<1000 {
                _ = service.getAllWords(language: .spanish)
            }
        }
    }

    func testVocabularyServiceCategoryFilterPerformance() {
        let service = VocabularyService()

        measure {
            for _ in 0..<5000 {
                _ = service.getWords(for: .kitchen, language: .spanish)
            }
        }
    }

    func testObjectDetectionPerformance() {
        let service = ObjectDetectionService()
        let expectation = XCTestExpectation(description: "Detection completes")

        measure {
            Task {
                _ = try? await service.detectObjects()
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)
        }
    }

    // MARK: - Data Model Performance

    func testVocabularyWordCreationPerformance() {
        measure {
            for i in 0..<10000 {
                _ = VocabularyWord(
                    word: "palabra\(i)",
                    translation: "word\(i)",
                    category: .general,
                    language: .spanish
                )
            }
        }
    }

    func testConversationMessageCreationPerformance() {
        measure {
            for i in 0..<10000 {
                _ = ConversationMessage(
                    content: "Message \(i)",
                    isUser: i % 2 == 0,
                    timestamp: Date()
                )
            }
        }
    }

    func testDetectedObjectCreationPerformance() {
        measure {
            for i in 0..<10000 {
                _ = DetectedObject(
                    label: "object\(i)",
                    confidence: 0.95,
                    boundingBox: CGRect(x: 0, y: 0, width: 100, height: 100),
                    position: SIMD3<Float>(Float(i), 0, 0)
                )
            }
        }
    }

    // MARK: - JSON Performance

    func testVocabularyWordEncodingPerformance() {
        let word = VocabularyWord(
            word: "mesa",
            translation: "table",
            category: .kitchen,
            language: .spanish
        )

        let encoder = JSONEncoder()

        measure {
            for _ in 0..<10000 {
                _ = try? encoder.encode(word)
            }
        }
    }

    func testVocabularyWordDecodingPerformance() throws {
        let word = VocabularyWord(
            word: "mesa",
            translation: "table",
            category: .kitchen,
            language: .spanish
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(word)
        let decoder = JSONDecoder()

        measure {
            for _ in 0..<10000 {
                _ = try? decoder.decode(VocabularyWord.self, from: data)
            }
        }
    }

    func testConversationHistoryEncodingPerformance() {
        let messages = (0..<100).map { i in
            ConversationMessage(
                content: "Message \(i)",
                isUser: i % 2 == 0,
                timestamp: Date()
            )
        }

        let encoder = JSONEncoder()

        measure {
            for _ in 0..<1000 {
                _ = try? encoder.encode(messages)
            }
        }
    }

    // MARK: - State Management Performance

    @MainActor
    func testAppStateUpdatePerformance() {
        let appState = AppState()

        measure {
            for _ in 0..<10000 {
                appState.incrementWordsEncountered()
            }
        }
    }

    @MainActor
    func testSessionStartEndPerformance() {
        let appState = AppState()

        measure {
            for _ in 0..<1000 {
                appState.startLearningSession()
                appState.endLearningSession()
            }
        }
    }

    // MARK: - Collection Performance

    func testVocabularySearchPerformance() {
        let service = VocabularyService()
        let allWords = service.getAllWords(language: .spanish)

        measure {
            for _ in 0..<1000 {
                _ = allWords.filter { $0.category == .kitchen }
            }
        }
    }

    func testVocabularyDictionaryLookupPerformance() {
        let service = VocabularyService()
        let allWords = service.getAllWords(language: .spanish)
        let dictionary = Dictionary(uniqueKeysWithValues: allWords.map { ($0.translation, $0) })

        measure {
            for _ in 0..<100000 {
                _ = dictionary["table"]
            }
        }
    }

    // MARK: - Memory Performance

    func testVocabularyServiceMemoryUsage() {
        measureMetrics([XCTMemoryMetric()], automaticallyStartMeasuring: false) {
            startMeasuring()

            let service = VocabularyService()
            var words: [[VocabularyWord]] = []

            for _ in 0..<100 {
                words.append(service.getAllWords(language: .spanish))
            }

            stopMeasuring()

            // Keep reference to prevent optimization
            _ = words.count
        }
    }

    func testMessageHistoryMemoryUsage() {
        measureMetrics([XCTMemoryMetric()], automaticallyStartMeasuring: false) {
            startMeasuring()

            var messages: [[ConversationMessage]] = []

            for batch in 0..<100 {
                let batchMessages = (0..<100).map { i in
                    ConversationMessage(
                        content: "Message \(batch)-\(i)",
                        isUser: i % 2 == 0,
                        timestamp: Date()
                    )
                }
                messages.append(batchMessages)
            }

            stopMeasuring()

            // Keep reference
            _ = messages.count
        }
    }

    // MARK: - Async Performance

    func testConcurrentDetectionPerformance() {
        let service = ObjectDetectionService()

        measure {
            let expectation = XCTestExpectation(description: "All detections complete")
            expectation.expectedFulfillmentCount = 10

            for _ in 0..<10 {
                Task {
                    _ = try? await service.detectObjects()
                    expectation.fulfill()
                }
            }

            wait(for: [expectation], timeout: 30.0)
        }
    }

    func testSerialDetectionPerformance() {
        let service = ObjectDetectionService()

        measure {
            let expectation = XCTestExpectation(description: "All detections complete")

            Task {
                for _ in 0..<10 {
                    _ = try? await service.detectObjects()
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 30.0)
        }
    }

    // MARK: - RealityKit Performance (Simulated)

    func testLabelEntityCreationPerformance() {
        let words = (0..<100).map { i in
            VocabularyWord(
                word: "palabra\(i)",
                translation: "word\(i)",
                category: .general,
                language: .spanish
            )
        }

        measure {
            // Simulate label entity creation overhead
            for word in words {
                _ = ObjectLabelEntity(
                    word: word,
                    position: SIMD3<Float>(0, 0, 0)
                )
            }
        }
    }

    // MARK: - Baseline Metrics

    func testBaselinePerformance() {
        // Establish baseline for comparison

        measure {
            var sum = 0
            for i in 0..<1000000 {
                sum += i
            }
            _ = sum
        }
    }

    func testStringOperationsPerformance() {
        measure {
            for i in 0..<10000 {
                _ = "test string \(i)".lowercased()
            }
        }
    }

    func testArrayOperationsPerformance() {
        let array = Array(0..<10000)

        measure {
            _ = array.filter { $0 % 2 == 0 }
        }
    }

    func testDictionaryOperationsPerformance() {
        let dict = Dictionary(uniqueKeysWithValues: (0..<10000).map { ($0, "value\($0)") })

        measure {
            for i in 0..<10000 {
                _ = dict[i]
            }
        }
    }

    // MARK: - Load Tests

    func testHighVolumeTranslations() {
        let service = VocabularyService()
        let words = ["table", "chair", "door", "window", "lamp"]

        measure {
            for _ in 0..<50000 {
                for word in words {
                    _ = service.translate(word, to: .spanish)
                }
            }
        }
    }

    func testHighVolumeObjectCreation() {
        measure {
            var objects: [DetectedObject] = []

            for i in 0..<10000 {
                let object = DetectedObject(
                    label: "object\(i % 10)",
                    confidence: Double.random(in: 0.8...0.99),
                    boundingBox: CGRect(
                        x: Double.random(in: 0...100),
                        y: Double.random(in: 0...100),
                        width: 50,
                        height: 50
                    ),
                    position: SIMD3<Float>(
                        Float.random(in: -2...2),
                        Float.random(in: 0...2),
                        Float.random(in: -3...(- 1))
                    )
                )
                objects.append(object)
            }

            _ = objects.count
        }
    }
}
