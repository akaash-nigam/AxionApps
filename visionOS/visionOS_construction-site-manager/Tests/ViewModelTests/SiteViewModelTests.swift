import Testing
import SwiftData
@testable import ConstructionSiteManager

@Suite("SiteViewModel Tests")
struct SiteViewModelTests {
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    let viewModel: SiteViewModel

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Site.self, Project.self,
            configurations: config
        )
        modelContext = modelContainer.mainContext
        viewModel = SiteViewModel(modelContext: modelContext)
    }

    @Test("Load sites from empty database")
    func testLoadSitesEmpty() {
        // Act
        viewModel.loadSites()

        // Assert
        #expect(viewModel.sites.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Create new site")
    func testCreateSite() throws {
        // Arrange
        let name = "Test Site"
        let address = Address(
            street: "123 Main St",
            city: "San Francisco",
            state: "CA",
            zipCode: "94105",
            country: "USA"
        )
        let latitude = 37.7749
        let longitude = -122.4194

        // Act
        try viewModel.createSite(
            name: name,
            address: address,
            latitude: latitude,
            longitude: longitude
        )

        // Assert
        #expect(viewModel.sites.count == 1)
        #expect(viewModel.sites.first?.name == name)
        #expect(viewModel.sites.first?.gpsLatitude == latitude)
        #expect(viewModel.sites.first?.gpsLongitude == longitude)
    }

    @Test("Update existing site")
    func testUpdateSite() throws {
        // Arrange
        let site = Site(
            name: "Original Name",
            address: Address(
                street: "123 Main St",
                city: "SF",
                state: "CA",
                zipCode: "94105",
                country: "USA"
            ),
            gpsLatitude: 37.0,
            gpsLongitude: -122.0
        )
        modelContext.insert(site)
        try modelContext.save()

        viewModel.loadSites()

        // Act
        site.name = "Updated Name"
        try viewModel.updateSite(site)

        // Assert
        viewModel.loadSites()
        #expect(viewModel.sites.first?.name == "Updated Name")
    }

    @Test("Delete site")
    func testDeleteSite() throws {
        // Arrange
        let site = Site(
            name: "To Delete",
            address: Address(
                street: "123 Main St",
                city: "SF",
                state: "CA",
                zipCode: "94105",
                country: "USA"
            ),
            gpsLatitude: 37.0,
            gpsLongitude: -122.0
        )
        modelContext.insert(site)
        try modelContext.save()

        viewModel.loadSites()
        #expect(viewModel.sites.count == 1)

        // Act
        try viewModel.deleteSite(site)

        // Assert
        viewModel.loadSites()
        #expect(viewModel.sites.isEmpty)
    }

    @Test("Filter sites by status")
    func testFilterByStatus() throws {
        // Arrange
        let activeSite = Site(
            name: "Active Site",
            address: Address(street: "123", city: "SF", state: "CA", zipCode: "94105", country: "USA"),
            gpsLatitude: 37.0,
            gpsLongitude: -122.0
        )
        activeSite.status = .active

        let planningSite = Site(
            name: "Planning Site",
            address: Address(street: "456", city: "SF", state: "CA", zipCode: "94105", country: "USA"),
            gpsLatitude: 37.1,
            gpsLongitude: -122.1
        )
        planningSite.status = .planning

        modelContext.insert(activeSite)
        modelContext.insert(planningSite)
        try modelContext.save()

        viewModel.loadSites()

        // Act
        viewModel.filterStatus = .active
        let filtered = viewModel.filteredSites()

        // Assert
        #expect(filtered.count == 1)
        #expect(filtered.first?.name == "Active Site")
    }

    @Test("Search sites by name")
    func testSearchByName() throws {
        // Arrange
        let site1 = Site(
            name: "Downtown Project",
            address: Address(street: "123", city: "SF", state: "CA", zipCode: "94105", country: "USA"),
            gpsLatitude: 37.0,
            gpsLongitude: -122.0
        )

        let site2 = Site(
            name: "Uptown Development",
            address: Address(street: "456", city: "SF", state: "CA", zipCode: "94105", country: "USA"),
            gpsLatitude: 37.1,
            gpsLongitude: -122.1
        )

        modelContext.insert(site1)
        modelContext.insert(site2)
        try modelContext.save()

        viewModel.loadSites()

        // Act
        viewModel.searchText = "Downtown"
        let filtered = viewModel.filteredSites()

        // Assert
        #expect(filtered.count == 1)
        #expect(filtered.first?.name == "Downtown Project")
    }

    @Test("Calculate statistics")
    func testCalculateStatistics() throws {
        // Arrange
        let site1 = Site(
            name: "Site 1",
            address: Address(street: "123", city: "SF", state: "CA", zipCode: "94105", country: "USA"),
            gpsLatitude: 37.0,
            gpsLongitude: -122.0
        )
        site1.status = .active

        let project1 = Project(name: "Project 1", projectType: .commercial)
        project1.progress = 0.5
        site1.projects.append(project1)

        let site2 = Site(
            name: "Site 2",
            address: Address(street: "456", city: "SF", state: "CA", zipCode: "94105", country: "USA"),
            gpsLatitude: 37.1,
            gpsLongitude: -122.1
        )
        site2.status = .active

        let project2 = Project(name: "Project 2", projectType: .residential)
        project2.progress = 0.7
        site2.projects.append(project2)

        modelContext.insert(site1)
        modelContext.insert(site2)
        try modelContext.save()

        viewModel.loadSites()

        // Act
        let stats = viewModel.calculateStatistics()

        // Assert
        #expect(stats.totalSites == 2)
        #expect(stats.activeSites == 2)
        #expect(stats.totalProjects == 2)
        #expect(abs(stats.averageProgress - 0.6) < 0.001) // (0.5 + 0.7) / 2
    }

    @Test("Sort sites by name")
    func testSortByName() throws {
        // Arrange
        let siteB = Site(
            name: "B Site",
            address: Address(street: "123", city: "SF", state: "CA", zipCode: "94105", country: "USA"),
            gpsLatitude: 37.0,
            gpsLongitude: -122.0
        )

        let siteA = Site(
            name: "A Site",
            address: Address(street: "456", city: "SF", state: "CA", zipCode: "94105", country: "USA"),
            gpsLatitude: 37.1,
            gpsLongitude: -122.1
        )

        modelContext.insert(siteB)
        modelContext.insert(siteA)
        try modelContext.save()

        viewModel.loadSites()

        // Act
        viewModel.sortOrder = .name
        let sorted = viewModel.filteredSites()

        // Assert
        #expect(sorted[0].name == "A Site")
        #expect(sorted[1].name == "B Site")
    }

    @Test("Sort sites by progress")
    func testSortByProgress() throws {
        // Arrange
        let site1 = Site(
            name: "Low Progress",
            address: Address(street: "123", city: "SF", state: "CA", zipCode: "94105", country: "USA"),
            gpsLatitude: 37.0,
            gpsLongitude: -122.0
        )
        let project1 = Project(name: "P1", projectType: .commercial)
        project1.progress = 0.3
        site1.projects.append(project1)

        let site2 = Site(
            name: "High Progress",
            address: Address(street: "456", city: "SF", state: "CA", zipCode: "94105", country: "USA"),
            gpsLatitude: 37.1,
            gpsLongitude: -122.1
        )
        let project2 = Project(name: "P2", projectType: .commercial)
        project2.progress = 0.8
        site2.projects.append(project2)

        modelContext.insert(site1)
        modelContext.insert(site2)
        try modelContext.save()

        viewModel.loadSites()

        // Act
        viewModel.sortOrder = .progress
        let sorted = viewModel.filteredSites()

        // Assert
        #expect(sorted[0].name == "High Progress")
        #expect(sorted[1].name == "Low Progress")
    }
}
