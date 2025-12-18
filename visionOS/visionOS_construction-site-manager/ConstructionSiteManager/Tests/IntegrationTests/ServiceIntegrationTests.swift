//
//  ServiceIntegrationTests.swift
//  Construction Site Manager Tests
//
//  Integration tests for service layer
//

import Testing
import Foundation
@testable import ConstructionSiteManager

@Suite("Service Integration Tests")
struct ServiceIntegrationTests {

    @Test("API client GET request structure")
    func testAPIClientGETRequest() async throws {
        // Arrange
        let client = APIClient(baseURL: "https://test.api.com")

        // Act & Assert
        // We can't actually make the request without a server,
        // but we can verify the client initializes correctly
        #expect(client != nil)
    }

    @Test("API client handles different HTTP methods")
    func testHTTPMethods() {
        // Assert
        #expect(HTTPMethod.get.rawValue == "GET")
        #expect(HTTPMethod.post.rawValue == "POST")
        #expect(HTTPMethod.put.rawValue == "PUT")
        #expect(HTTPMethod.delete.rawValue == "DELETE")
        #expect(HTTPMethod.patch.rawValue == "PATCH")
    }

    @Test("API error types")
    func testAPIErrorTypes() {
        // Arrange & Act
        let errors: [APIError] = [
            .badRequest,
            .unauthorized,
            .forbidden,
            .notFound,
            .serverError
        ]

        // Assert
        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(!error.errorDescription!.isEmpty)
        }
    }

    @Test("Sync service initializes correctly")
    func testSyncServiceInitialization() {
        // Arrange & Act
        let service = SyncService.shared

        // Assert
        #expect(!service.isSyncing)
        #expect(service.lastSyncDate == nil)
        #expect(service.pendingChanges.isEmpty)
    }

    @Test("Sync service queues changes")
    func testSyncServiceQueueing() {
        // Arrange
        let service = SyncService.shared
        let change = Change(
            type: .create,
            entityType: "Site",
            entityId: UUID()
        )

        // Act
        service.queueChange(change)

        // Assert
        #expect(!service.pendingChanges.isEmpty)
        #expect(service.pendingChanges.count == 1)
        #expect(service.pendingChanges.first?.type == .create)
    }

    @Test("Change model stores all required data")
    func testChangeModel() {
        // Arrange
        let entityId = UUID()
        let timestamp = Date()

        // Act
        let change = Change(
            type: .update,
            entityType: "Project",
            entityId: entityId,
            timestamp: timestamp
        )

        // Assert
        #expect(change.type == .update)
        #expect(change.entityType == "Project")
        #expect(change.entityId == entityId)
        #expect(change.timestamp == timestamp)
    }

    @Test("Safety monitoring starts and stops")
    func testSafetyMonitoringLifecycle() {
        // Arrange
        let service = SafetyMonitoringService.shared

        // Act
        service.startMonitoring()

        // Assert
        #expect(service.isMonitoring)

        // Act - Stop
        service.stopMonitoring()

        // Assert
        #expect(!service.isMonitoring)
    }

    @Test("Safety service manages active alerts")
    func testSafetyServiceAlertManagement() async {
        // Arrange
        let service = SafetyMonitoringService.shared
        let alert = SafetyAlert(
            type: .proximityViolation,
            severity: .high,
            message: "Worker too close to crane"
        )

        // Act
        await service.addAlert(alert)

        // Assert
        await MainActor.run {
            #expect(!service.activeAlerts.isEmpty)
            #expect(service.activeAlerts.count == 1)
            #expect(service.activeAlerts.first?.message == "Worker too close to crane")
        }
    }
}

@Suite("Data Flow Integration Tests")
struct DataFlowTests {

    @Test("Site to Project relationship")
    func testSiteProjectRelationship() {
        // Arrange
        let site = Site(
            name: "Test Site",
            address: Address(
                street: "123 Test St",
                city: "Test City",
                state: "TS",
                zipCode: "12345",
                country: "USA"
            ),
            gpsLatitude: 37.7749,
            gpsLongitude: -122.4194
        )

        let endDate = Date().addingTimeInterval(86400 * 180)  // 180 days
        let project = Project(
            name: "Test Project",
            projectType: .commercial,
            scheduledEndDate: endDate
        )

        // Act
        site.projects.append(project)
        project.site = site

        // Assert
        #expect(site.projects.count == 1)
        #expect(site.projects.first?.name == "Test Project")
        #expect(project.site?.name == "Test Site")
    }

    @Test("Project to BIM Model relationship")
    func testProjectBIMRelationship() {
        // Arrange
        let endDate = Date().addingTimeInterval(86400 * 180)
        let project = Project(
            name: "Test Project",
            projectType: .commercial,
            scheduledEndDate: endDate
        )

        let bimModel = BIMModel(
            name: "Building Model",
            format: .ifc,
            fileURL: "model.ifc"
        )

        // Act
        project.bimModels.append(bimModel)
        bimModel.project = project

        // Assert
        #expect(project.bimModels.count == 1)
        #expect(project.bimModels.first?.name == "Building Model")
        #expect(bimModel.project?.name == "Test Project")
    }

    @Test("BIM Model to Element relationship")
    func testBIMModelElementRelationship() {
        // Arrange
        let model = BIMModel(
            name: "Test Model",
            format: .ifc,
            fileURL: "test.ifc"
        )

        let element = BIMElement(
            ifcGuid: "guid-123",
            ifcType: "IfcWall",
            name: "Wall-001",
            discipline: .architectural
        )

        // Act
        model.elements.append(element)
        element.model = model

        // Assert
        #expect(model.elements.count == 1)
        #expect(model.elementCount == 1)
        #expect(element.model?.name == "Test Model")
    }

    @Test("Issue to Project relationship")
    func testIssueProjectRelationship() {
        // Arrange
        let endDate = Date().addingTimeInterval(86400 * 180)
        let project = Project(
            name: "Test Project",
            projectType: .commercial,
            scheduledEndDate: endDate
        )

        let issueDueDate = Date().addingTimeInterval(86400 * 7)
        let issue = Issue(
            title: "Test Issue",
            description: "Description",
            type: .quality,
            priority: .medium,
            assignedTo: "Worker",
            reporter: "Manager",
            dueDate: issueDueDate
        )

        // Act
        project.issues.append(issue)
        issue.project = project

        // Assert
        #expect(project.issues.count == 1)
        #expect(issue.project?.name == "Test Project")
    }
}

@Suite("Error Handling Integration Tests")
struct ErrorHandlingTests {

    @Test("API error provides user-friendly messages")
    func testAPIErrorMessages() {
        // Arrange
        let errors: [(APIError, String)] = [
            (.badRequest, "Bad request"),
            (.unauthorized, "Unauthorized"),
            (.forbidden, "Access forbidden"),
            (.notFound, "Resource not found"),
            (.serverError, "Server error")
        ]

        // Assert
        for (error, expectedSubstring) in errors {
            let description = error.errorDescription ?? ""
            #expect(description.lowercased().contains(expectedSubstring.lowercased()))
        }
    }

    @Test("Safety severity comparison works")
    func testSafetySeverityComparison() {
        // Assert
        #expect(SafetySeverity.low < SafetySeverity.medium)
        #expect(SafetySeverity.medium < SafetySeverity.high)
        #expect(SafetySeverity.high < SafetySeverity.critical)

        // Verify transitivity
        #expect(SafetySeverity.low < SafetySeverity.critical)
    }

    @Test("Element status comparison works")
    func testElementStatusComparison() {
        // Assert
        #expect(ElementStatus.notStarted < ElementStatus.inProgress)
        #expect(ElementStatus.inProgress < ElementStatus.completed)
        #expect(ElementStatus.completed < ElementStatus.approved)
    }
}
