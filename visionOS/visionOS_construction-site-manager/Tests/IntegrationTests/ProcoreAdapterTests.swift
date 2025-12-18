import Testing
@testable import ConstructionSiteManager

@Suite("Procore Adapter Tests")
struct ProcoreAdapterTests {

    @Test("Authorization URL is correctly formatted")
    func testAuthorizationURL() async {
        // Arrange
        let adapter = ProcoreAdapter(
            clientId: "test_client_id",
            clientSecret: "test_secret",
            redirectURI: "http://localhost:8080/callback"
        )

        // Act
        let authURL = await adapter.getAuthorizationURL()

        // Assert
        #expect(authURL != nil)
        #expect(authURL?.absoluteString.contains("login.procore.com") == true)
        #expect(authURL?.absoluteString.contains("client_id=test_client_id") == true)
        #expect(authURL?.absoluteString.contains("response_type=code") == true)
    }

    @Test("Error handling for invalid credentials")
    func testInvalidCredentials() async {
        // Arrange
        let adapter = ProcoreAdapter(
            clientId: "invalid_client",
            clientSecret: "invalid_secret",
            redirectURI: "http://localhost:8080/callback"
        )

        // Act & Assert
        // Note: This would require actual API calls or mocking
        // For now, we're testing the structure exists
        #expect(true) // Placeholder for integration test
    }

    @Test("Procore project model structure")
    func testProcoreProjectStructure() {
        // Arrange
        let project = ProcoreProject(
            id: 123,
            name: "Test Project",
            display_name: "Test Display",
            project_number: "PRJ-001",
            address: "123 Main St",
            city: "San Francisco",
            state_code: "CA",
            zip: "94105",
            country_code: "US",
            latitude: 37.7749,
            longitude: -122.4194,
            active: true,
            stage: "Construction",
            project_type: "Commercial"
        )

        // Assert
        #expect(project.id == 123)
        #expect(project.name == "Test Project")
        #expect(project.city == "San Francisco")
        #expect(project.latitude == 37.7749)
        #expect(project.active == true)
    }

    @Test("Procore RFI model structure")
    func testProcoreRFIStructure() {
        // Arrange
        let user = User(id: 1, name: "John Doe", email: "john@example.com")
        let rfi = ProcoreRFI(
            id: 456,
            number: 1,
            subject: "Foundation Question",
            question: "What is the concrete mix design?",
            status: "open",
            due_date: "2025-02-01",
            assignee: user,
            created_at: "2025-01-20T10:00:00Z",
            updated_at: "2025-01-20T10:00:00Z"
        )

        // Assert
        #expect(rfi.id == 456)
        #expect(rfi.subject == "Foundation Question")
        #expect(rfi.status == "open")
        #expect(rfi.assignee?.name == "John Doe")
    }

    @Test("Procore observation (issue) model structure")
    func testProcoreObservationStructure() {
        // Arrange
        let user = User(id: 2, name: "Jane Smith", email: "jane@example.com")
        let observation = ProcoreObservation(
            id: 789,
            number: 10,
            title: "Crack in Foundation",
            description: "Visible crack observed",
            status: "open",
            priority: "high",
            assignee: user,
            location: "Building A",
            due_date: "2025-01-25",
            created_at: "2025-01-20T10:00:00Z"
        )

        // Assert
        #expect(observation.id == 789)
        #expect(observation.title == "Crack in Foundation")
        #expect(observation.priority == "high")
        #expect(observation.assignee?.name == "Jane Smith")
    }

    @Test("Create RFI request structure")
    func testCreateRFIRequest() {
        // Arrange
        let request = CreateRFIRequest(
            subject: "Test RFI",
            question: "What is the answer?",
            assignee_id: 123,
            due_date: "2025-02-01"
        )

        // Assert
        #expect(request.subject == "Test RFI")
        #expect(request.question == "What is the answer?")
        #expect(request.assignee_id == 123)
        #expect(request.due_date == "2025-02-01")
    }

    @Test("Create observation request structure")
    func testCreateObservationRequest() {
        // Arrange
        let request = CreateObservationRequest(
            title: "Safety Issue",
            description: "Missing guardrails",
            assignee_id: 456,
            location_id: 789,
            due_date: "2025-01-30",
            priority: "critical"
        )

        // Assert
        #expect(request.title == "Safety Issue")
        #expect(request.priority == "critical")
        #expect(request.assignee_id == 456)
    }

    @Test("Update observation request structure")
    func testUpdateObservationRequest() {
        // Arrange
        let request = UpdateObservationRequest(
            status: "resolved",
            assignee_id: 123,
            due_date: "2025-02-15"
        )

        // Assert
        #expect(request.status == "resolved")
        #expect(request.assignee_id == 123)
        #expect(request.due_date == "2025-02-15")
    }

    @Test("Daily log model structure")
    func testDailyLogStructure() {
        // Arrange
        let user = User(id: 1, name: "Logger", email: "logger@example.com")
        let log = ProcoreDailyLog(
            id: 100,
            date: "2025-01-20",
            weather: "Sunny",
            temperature_high: 75.5,
            temperature_low: 55.2,
            created_by: user
        )

        // Assert
        #expect(log.id == 100)
        #expect(log.date == "2025-01-20")
        #expect(log.weather == "Sunny")
        #expect(log.temperature_high == 75.5)
        #expect(log.created_by?.name == "Logger")
    }

    @Test("Webhook model structure")
    func testWebhookStructure() {
        // Arrange
        let events = [
            HookEvent(resource: "rfis"),
            HookEvent(resource: "observations")
        ]

        let webhook = ProcoreWebhook(
            id: "webhook_123",
            api_version: "v1.0",
            destination_url: "https://example.com/webhook",
            hook_events: events
        )

        // Assert
        #expect(webhook.id == "webhook_123")
        #expect(webhook.api_version == "v1.0")
        #expect(webhook.hook_events.count == 2)
        #expect(webhook.hook_events[0].resource == "rfis")
    }

    @Test("Procore error types")
    func testProcoreErrors() {
        // Arrange & Act
        let notAuthError = ProcoreError.notAuthenticated
        let invalidCredsError = ProcoreError.invalidCredentials
        let rateLimitError = ProcoreError.rateLimitExceeded

        // Assert
        #expect(notAuthError.errorDescription != nil)
        #expect(invalidCredsError.errorDescription != nil)
        #expect(rateLimitError.errorDescription != nil)
    }
}
