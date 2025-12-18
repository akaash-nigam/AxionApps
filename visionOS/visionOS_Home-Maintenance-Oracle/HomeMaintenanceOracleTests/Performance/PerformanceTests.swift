//
//  PerformanceTests.swift
//  HomeMaintenanceOracleTests
//
//  Created on 2025-11-24.
//  Performance and benchmarking tests
//
//  NOTE: Performance tests should be run on actual devices for accurate results
//  These provide baseline metrics for optimization
//

import XCTest
@testable import HomeMaintenanceOracle

final class PerformanceTests: XCTestCase {

    // MARK: - Image Processing Performance

    func testImagePreprocessing_Performance() throws {
        // Given
        let preprocessor = ImagePreprocessor()
        let testImage = try createTestImage(width: 640, height: 480)

        // Measure preprocessing time
        measure {
            _ = preprocessor.preprocess(testImage, targetSize: CGSize(width: 224, height: 224))
        }

        // Baseline: Should complete in <50ms on modern hardware
    }

    func testImageNormalization_Performance() throws {
        // Given
        let preprocessor = ImagePreprocessor()
        let testImage = try createTestImage(width: 224, height: 224)

        // Measure normalization time
        measure {
            _ = preprocessor.normalize(testImage)
        }

        // Baseline: Should complete in <20ms
    }

    func testImageQualityCheck_Performance() throws {
        // Given
        let preprocessor = ImagePreprocessor()
        let testImage = try createTestImage(width: 640, height: 480)

        // Measure quality checking time
        measure {
            _ = preprocessor.isImageSuitable(testImage)
        }

        // Baseline: Should complete in <10ms
    }

    // MARK: - Core Data Performance

    func testCoreDataFetch_Performance() throws {
        // Given - Seed database with test data
        let context = PersistenceController.preview.container.viewContext
        for i in 0..<100 {
            let entity = ApplianceEntity(context: context)
            entity.id = UUID()
            entity.brand = "Brand \(i)"
            entity.model = "Model \(i)"
            entity.category = "refrigerator"
        }
        try context.save()

        // Measure fetch performance
        let fetchRequest = ApplianceEntity.fetchRequest()
        measure {
            _ = try? context.fetch(fetchRequest)
        }

        // Baseline: Should complete in <10ms for 100 items
    }

    func testCoreDataInsert_Performance() throws {
        // Given
        let context = PersistenceController.preview.container.viewContext

        // Measure insert performance
        measure {
            let entity = ApplianceEntity(context: context)
            entity.id = UUID()
            entity.brand = "Test Brand"
            entity.model = "Test Model"
            entity.category = "refrigerator"
            try? context.save()
        }

        // Baseline: Should complete in <5ms per item
    }

    func testCoreDataBulkInsert_Performance() throws {
        // Given
        let context = PersistenceController.preview.container.viewContext

        // Measure bulk insert performance
        measure {
            for i in 0..<100 {
                let entity = ApplianceEntity(context: context)
                entity.id = UUID()
                entity.brand = "Brand \(i)"
                entity.model = "Model \(i)"
                entity.category = "refrigerator"
            }
            try? context.save()
        }

        // Baseline: Should complete in <500ms for 100 items
    }

    // MARK: - Service Layer Performance

    func testMaintenanceTaskQuery_Performance() async throws {
        // Given - Repository with many tasks
        let repository = MockMaintenanceRepository()
        for i in 0..<1000 {
            let task = MaintenanceTask(
                applianceId: UUID(),
                title: "Task \(i)",
                frequency: .monthly,
                nextDueDate: Date().addingTimeInterval(Double(i) * 86400)
            )
            try await repository.saveTask(task)
        }

        // Measure query performance
        measure {
            _ = try? await repository.getUpcomingTasks(limit: 10)
        }

        // Baseline: Should complete in <50ms for 1000 tasks
    }

    func testMaintenanceTaskFiltering_Performance() async throws {
        // Given - Large task set
        let repository = MockMaintenanceRepository()
        let applianceId = UUID()
        for i in 0..<500 {
            let task = MaintenanceTask(
                applianceId: i % 2 == 0 ? applianceId : UUID(),
                title: "Task \(i)",
                frequency: .monthly,
                nextDueDate: Date()
            )
            try await repository.saveTask(task)
        }

        // Measure filtering performance
        measure {
            _ = try? await repository.getTasks(for: applianceId)
        }

        // Baseline: Should complete in <30ms for 500 tasks
    }

    // MARK: - Memory Performance

    func testMemoryUsage_LargeApplianceList() throws {
        // Measure memory footprint of large data sets
        measure(metrics: [XCTMemoryMetric()]) {
            var appliances: [Appliance] = []
            for i in 0..<1000 {
                let appliance = Appliance(
                    brand: "Brand \(i)",
                    model: "Model \(i)",
                    serialNumber: "SN\(i)",
                    category: .refrigerator,
                    notes: "Test notes for appliance \(i)"
                )
                appliances.append(appliance)
            }
            _ = appliances.count
        }

        // Baseline: Should use <10MB for 1000 appliances
    }

    func testMemoryUsage_MaintenanceTaskCreation() throws {
        measure(metrics: [XCTMemoryMetric()]) {
            var tasks: [MaintenanceTask] = []
            for i in 0..<1000 {
                let task = MaintenanceTask(
                    applianceId: UUID(),
                    title: "Task \(i)",
                    taskDescription: "Description for task \(i)",
                    frequency: .monthly,
                    nextDueDate: Date()
                )
                tasks.append(task)
            }
            _ = tasks.count
        }

        // Baseline: Should use <5MB for 1000 tasks
    }

    // MARK: - CPU Performance

    func testCPUUsage_DateCalculations() throws {
        // Measure CPU usage for date calculations
        measure(metrics: [XCTCPUMetric()]) {
            for _ in 0..<1000 {
                let task = MaintenanceTask(
                    applianceId: UUID(),
                    title: "Test",
                    frequency: .monthly,
                    nextDueDate: Date()
                )
                _ = task.calculateNextDueDate(from: Date())
                _ = task.isOverdue
                _ = task.daysUntilDue
            }
        }
    }

    // MARK: - Network Simulation Performance

    func testAPIResponseTime_Simulation() async throws {
        // Simulate API response times
        let apiClient = MockAPIClient()

        measure {
            Task {
                _ = try? await apiClient.simulateNetworkCall(delay: 0.1)
            }
        }

        // Baseline: Should complete in <150ms (100ms + overhead)
    }

    // MARK: - Startup Performance

    func testAppDependencies_InitializationTime() throws {
        // Measure dependency injection initialization
        measure {
            _ = AppDependencies.shared
        }

        // Baseline: Should complete in <50ms
    }

    func testCoreData_InitializationTime() throws {
        // Measure Core Data stack initialization
        measure {
            _ = PersistenceController.shared
        }

        // Baseline: Should complete in <100ms
    }

    // MARK: - Stress Tests

    func testConcurrentTaskOperations_Performance() async throws {
        // Test performance under concurrent load
        let repository = MockMaintenanceRepository()

        measure {
            Task {
                await withTaskGroup(of: Void.self) { group in
                    for i in 0..<100 {
                        group.addTask {
                            let task = MaintenanceTask(
                                applianceId: UUID(),
                                title: "Task \(i)",
                                frequency: .monthly,
                                nextDueDate: Date()
                            )
                            try? await repository.saveTask(task)
                        }
                    }
                }
            }
        }

        // Baseline: Should complete in <2s for 100 concurrent operations
    }

    // MARK: - Helper Methods

    private func createTestImage(width: Int, height: Int) throws -> CGImage {
        var pixels = [UInt8](repeating: 128, count: width * height * 4)

        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                pixels[offset] = UInt8(x * 255 / width)
                pixels[offset + 1] = UInt8(y * 255 / height)
                pixels[offset + 2] = 128
                pixels[offset + 3] = 255
            }
        }

        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ),
        let cgImage = context.makeImage() else {
            throw NSError(domain: "test", code: 1)
        }

        return cgImage
    }
}

// MARK: - Mock API Client

class MockAPIClient {
    func simulateNetworkCall(delay: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
}

// MARK: - Performance Baselines
/*
 PERFORMANCE BASELINES (for reference):

 Image Processing:
 - Preprocessing (640x480 → 224x224): <50ms
 - Normalization (224x224): <20ms
 - Quality check: <10ms

 Core Data:
 - Fetch 100 items: <10ms
 - Insert single item: <5ms
 - Bulk insert 100 items: <500ms

 Service Layer:
 - Query 1000 tasks: <50ms
 - Filter 500 tasks: <30ms

 Memory:
 - 1000 appliances: <10MB
 - 1000 maintenance tasks: <5MB

 Startup:
 - DI container initialization: <50ms
 - Core Data stack initialization: <100ms

 Stress:
 - 100 concurrent operations: <2s

 These baselines should be updated after running on actual hardware.
 Performance may vary significantly between simulator and device.
 */
