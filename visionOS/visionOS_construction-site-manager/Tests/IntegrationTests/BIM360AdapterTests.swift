import Testing
@testable import ConstructionSiteManager

@Suite("BIM 360 Adapter Tests")
struct BIM360AdapterTests {

    @Test("BIM 360 hub model structure")
    func testBIM360HubStructure() {
        // Arrange
        let hubData = HubData(
            id: "hub123",
            type: "hubs",
            attributes: HubAttributes(
                name: "Test Company",
                region: "US"
            )
        )

        // Act
        let hub = BIM360Hub(from: hubData)

        // Assert
        #expect(hub.id == "hub123")
        #expect(hub.name == "Test Company")
        #expect(hub.region == "US")
    }

    @Test("BIM 360 project model structure")
    func testBIM360ProjectStructure() {
        // Arrange
        let projectData = ProjectData(
            id: "project456",
            type: "projects",
            attributes: ProjectAttributes(
                name: "Construction Project",
                startDate: "2025-01-01",
                endDate: "2025-12-31"
            )
        )

        // Act
        let project = BIM360Project(from: projectData)

        // Assert
        #expect(project.id == "project456")
        #expect(project.name == "Construction Project")
        #expect(project.startDate == "2025-01-01")
        #expect(project.endDate == "2025-12-31")
    }

    @Test("BIM 360 folder model structure")
    func testBIM360FolderStructure() {
        // Arrange
        let folderData = FolderData(
            id: "folder789",
            type: "folders",
            attributes: FolderAttributes(
                name: "Plans",
                createTime: "2025-01-15T10:00:00Z"
            )
        )

        // Act
        let folder = BIM360Folder(from: folderData)

        // Assert
        #expect(folder.id == "folder789")
        #expect(folder.name == "Plans")
        #expect(folder.createTime == "2025-01-15T10:00:00Z")
    }

    @Test("BIM 360 file model structure")
    func testBIM360FileStructure() {
        // Arrange
        let fileData = FileData(
            id: "file001",
            type: "items",
            attributes: FileAttributes(
                name: "Floor Plan.rvt",
                displayName: "Floor Plan",
                createTime: "2025-01-20T09:00:00Z",
                storageSize: 5_242_880 // 5MB
            ),
            relationships: nil
        )

        // Act
        let file = BIM360File(from: fileData)

        // Assert
        #expect(file.id == "file001")
        #expect(file.name == "Floor Plan.rvt")
        #expect(file.displayName == "Floor Plan")
        #expect(file.fileSize == 5_242_880)
    }

    @Test("BIM 360 issue model structure")
    func testBIM360IssueStructure() {
        // Arrange
        let issueData = IssueData(
            id: "issue123",
            type: "quality-issues",
            attributes: IssueAttributes(
                title: "Concrete Quality Issue",
                description: "Visible cracks in foundation",
                status: "open",
                assignedTo: "john.doe@example.com",
                dueDate: "2025-01-30",
                priority: "high"
            )
        )

        // Act
        let issue = BIM360Issue(from: issueData)

        // Assert
        #expect(issue.id == "issue123")
        #expect(issue.title == "Concrete Quality Issue")
        #expect(issue.status == "open")
        #expect(issue.priority == "high")
        #expect(issue.assignedTo == "john.doe@example.com")
    }

    @Test("Folder contents structure")
    func testFolderContentsStructure() {
        // Arrange
        let folders = [
            BIM360Folder(from: FolderData(
                id: "f1",
                type: "folders",
                attributes: FolderAttributes(name: "Folder 1", createTime: nil)
            ))
        ]

        let files = [
            BIM360File(from: FileData(
                id: "file1",
                type: "items",
                attributes: FileAttributes(
                    name: "File 1.pdf",
                    displayName: "File 1",
                    createTime: nil,
                    storageSize: 1024
                ),
                relationships: nil
            ))
        ]

        // Act
        let contents = BIM360FolderContents(folders: folders, files: files)

        // Assert
        #expect(contents.folders.count == 1)
        #expect(contents.files.count == 1)
        #expect(contents.folders[0].id == "f1")
        #expect(contents.files[0].id == "file1")
    }

    @Test("Create issue request structure")
    func testCreateIssueRequest() {
        // Arrange
        let request = CreateIssueRequest(
            title: "Safety Hazard",
            description: "Missing guardrails on scaffolding",
            status: "open",
            assignedTo: "safety@example.com",
            dueDate: "2025-01-25"
        )

        // Assert
        #expect(request.title == "Safety Hazard")
        #expect(request.description == "Missing guardrails on scaffolding")
        #expect(request.status == "open")
        #expect(request.assignedTo == "safety@example.com")
    }

    @Test("Update issue request structure")
    func testUpdateIssueRequest() {
        // Arrange
        let request = UpdateIssueRequest(
            status: "resolved",
            assignedTo: "engineer@example.com"
        )

        // Assert
        #expect(request.status == "resolved")
        #expect(request.assignedTo == "engineer@example.com")
    }

    @Test("JSONAPI structure")
    func testJSONAPIStructure() {
        // Arrange
        let jsonapi = JSONAPI(version: "1.0")

        // Assert
        #expect(jsonapi.version == "1.0")
    }

    @Test("Storage request structure")
    func testStorageRequestStructure() {
        // Arrange
        let request = CreateStorageRequest(
            jsonapi: JSONAPI(version: "1.0"),
            data: StorageData(
                type: "objects",
                attributes: StorageAttributes(name: "test.pdf"),
                relationships: StorageRelationships(
                    target: Target(
                        data: TargetData(type: "folders", id: "folder123")
                    )
                )
            )
        )

        // Assert
        #expect(request.jsonapi.version == "1.0")
        #expect(request.data.type == "objects")
        #expect(request.data.attributes.name == "test.pdf")
        #expect(request.data.relationships.target.data.id == "folder123")
    }

    @Test("Item request structure")
    func testItemRequestStructure() {
        // Arrange
        let request = CreateItemRequest(
            jsonapi: JSONAPI(version: "1.0"),
            data: ItemData(
                type: "items",
                attributes: ItemAttributes(
                    displayName: "Test Document",
                    extension: ItemExtension(
                        type: "items:autodesk.core:File",
                        version: "1.0"
                    )
                ),
                relationships: ItemRelationships(
                    tip: Tip(
                        data: TipData(type: "versions", id: "1")
                    ),
                    parent: Parent(
                        data: ParentData(type: "folders", id: "parent123")
                    )
                )
            )
        )

        // Assert
        #expect(request.data.attributes.displayName == "Test Document")
        #expect(request.data.attributes.extension.type == "items:autodesk.core:File")
        #expect(request.data.relationships.parent.data.id == "parent123")
    }

    @Test("Model manifest structure")
    func testModelManifestStructure() {
        // Arrange
        let manifest = ModelManifest(
            type: "manifest",
            hasThumbnail: "true",
            status: "success",
            progress: "complete",
            region: "US",
            urn: "urn:adsk.objects:os.object:bucket/model.rvt",
            derivatives: [
                Derivative(
                    name: "Model View",
                    hasThumbnail: "true",
                    status: "success",
                    progress: "complete"
                )
            ]
        )

        // Assert
        #expect(manifest.type == "manifest")
        #expect(manifest.status == "success")
        #expect(manifest.urn == "urn:adsk.objects:os.object:bucket/model.rvt")
        #expect(manifest.derivatives?.count == 1)
        #expect(manifest.derivatives?[0].name == "Model View")
    }

    @Test("BIM 360 error types")
    func testBIM360Errors() {
        // Arrange & Act
        let notAuthError = BIM360Error.notAuthenticated
        let invalidCredsError = BIM360Error.invalidCredentials
        let downloadError = BIM360Error.downloadFailed
        let uploadError = BIM360Error.uploadFailed

        // Assert
        #expect(notAuthError.errorDescription != nil)
        #expect(invalidCredsError.errorDescription != nil)
        #expect(downloadError.errorDescription != nil)
        #expect(uploadError.errorDescription != nil)
        #expect(downloadError.errorDescription == "Failed to download file")
    }

    @Test("Auth response structure")
    func testAuthResponseStructure() {
        // Arrange
        let response = AuthResponse(
            access_token: "token123",
            expires_in: 3600,
            token_type: "Bearer"
        )

        // Assert
        #expect(response.access_token == "token123")
        #expect(response.expires_in == 3600)
        #expect(response.token_type == "Bearer")
    }

    @Test("Hubs response structure")
    func testHubsResponseStructure() {
        // Arrange
        let response = HubsResponse(
            data: [
                HubData(
                    id: "hub1",
                    type: "hubs",
                    attributes: HubAttributes(name: "Company A", region: "US")
                ),
                HubData(
                    id: "hub2",
                    type: "hubs",
                    attributes: HubAttributes(name: "Company B", region: "EU")
                )
            ]
        )

        // Assert
        #expect(response.data.count == 2)
        #expect(response.data[0].attributes.name == "Company A")
        #expect(response.data[1].attributes.region == "EU")
    }

    @Test("Projects response structure")
    func testProjectsResponseStructure() {
        // Arrange
        let response = ProjectsResponse(
            data: [
                ProjectData(
                    id: "p1",
                    type: "projects",
                    attributes: ProjectAttributes(
                        name: "Project Alpha",
                        startDate: "2025-01-01",
                        endDate: "2025-06-30"
                    )
                )
            ]
        )

        // Assert
        #expect(response.data.count == 1)
        #expect(response.data[0].attributes.name == "Project Alpha")
        #expect(response.data[0].attributes.startDate == "2025-01-01")
    }

    @Test("File relationships structure")
    func testFileRelationshipsStructure() {
        // Arrange
        let relationships = FileRelationships(
            storage: Storage(
                meta: StorageMeta(
                    link: Link(href: "https://example.com/download")
                )
            )
        )

        // Assert
        #expect(relationships.storage?.meta?.link?.href == "https://example.com/download")
    }

    @Test("Model metadata structure")
    func testModelMetadataStructure() {
        // Arrange
        let metadata = ModelMetadata(
            data: MetadataData(
                type: "metadata",
                metadata: [
                    Metadata(name: "Model View", guid: "guid123"),
                    Metadata(name: "Section View", guid: "guid456")
                ]
            )
        )

        // Assert
        #expect(metadata.data.metadata.count == 2)
        #expect(metadata.data.metadata[0].name == "Model View")
        #expect(metadata.data.metadata[1].guid == "guid456")
    }
}
