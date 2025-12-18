import SwiftUI
import SwiftData
import Observation

/// ViewModel for site management and overview
/// Handles site data operations, filtering, and business logic
@MainActor
@Observable
final class SiteViewModel {
    // MARK: - Properties

    private(set) var sites: [Site] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    var selectedSite: Site?
    var searchText = ""
    var filterStatus: SiteStatus?
    var sortOrder: SortOrder = .name

    enum SortOrder {
        case name, progress, status, location
    }

    // MARK: - Dependencies

    private let modelContext: ModelContext
    private let syncService: SyncService

    // MARK: - Initialization

    init(modelContext: ModelContext, syncService: SyncService) {
        self.modelContext = modelContext
        self.syncService = syncService
    }

    // MARK: - Public Methods

    /// Load all sites from local database
    func loadSites() {
        isLoading = true
        errorMessage = nil

        do {
            let descriptor = FetchDescriptor<Site>(sortBy: [SortDescriptor(\.name)])
            sites = try modelContext.fetch(descriptor)
            isLoading = false
        } catch {
            errorMessage = "Failed to load sites: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Create a new site
    func createSite(
        name: String,
        address: Address,
        latitude: Double,
        longitude: Double,
        boundary: [SiteCoordinate]? = nil
    ) throws {
        let site = Site(
            name: name,
            address: address,
            gpsLatitude: latitude,
            gpsLongitude: longitude
        )

        if let boundary = boundary {
            site.boundaryPoints = boundary
        }

        modelContext.insert(site)
        try modelContext.save()

        // Queue for sync
        syncService.queueChange(Change(type: .create, entityType: "Site", entityId: site.id))

        sites.append(site)
    }

    /// Update an existing site
    func updateSite(_ site: Site) throws {
        site.lastModifiedDate = Date()
        try modelContext.save()

        // Queue for sync
        syncService.queueChange(Change(type: .update, entityType: "Site", entityId: site.id))
    }

    /// Delete a site
    func deleteSite(_ site: Site) throws {
        let siteId = site.id
        modelContext.delete(site)
        try modelContext.save()

        // Queue for sync
        syncService.queueChange(Change(type: .delete, entityType: "Site", entityId: siteId))

        sites.removeAll { $0.id == siteId }
        if selectedSite?.id == siteId {
            selectedSite = nil
        }
    }

    /// Get filtered and sorted sites
    func filteredSites() -> [Site] {
        var filtered = sites

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.address.city.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply status filter
        if let status = filterStatus {
            filtered = filtered.filter { $0.status == status }
        }

        // Apply sorting
        switch sortOrder {
        case .name:
            filtered.sort { $0.name < $1.name }
        case .progress:
            filtered.sort { $0.overallProgress > $1.overallProgress }
        case .status:
            filtered.sort { $0.status.rawValue < $1.status.rawValue }
        case .location:
            filtered.sort { $0.address.city < $1.address.city }
        }

        return filtered
    }

    /// Calculate statistics for all sites
    func calculateStatistics() -> SiteStatistics {
        let totalSites = sites.count
        let activeSites = sites.filter { $0.status == .active }.count
        let totalProjects = sites.flatMap { $0.projects }.count
        let averageProgress = sites.isEmpty ? 0.0 :
            sites.reduce(0.0) { $0 + $1.overallProgress } / Double(sites.count)

        return SiteStatistics(
            totalSites: totalSites,
            activeSites: activeSites,
            totalProjects: totalProjects,
            averageProgress: averageProgress
        )
    }

    /// Sync site with server
    func syncSite(_ site: Site) async throws {
        isLoading = true
        defer { isLoading = false }

        try await syncService.sync(modelContext: modelContext)
    }

    /// Export site data
    func exportSiteData(_ site: Site) -> Data? {
        // TODO: Implement data export (JSON, CSV, etc.)
        return nil
    }
}

// MARK: - Supporting Types

struct SiteStatistics {
    let totalSites: Int
    let activeSites: Int
    let totalProjects: Int
    let averageProgress: Double
}
