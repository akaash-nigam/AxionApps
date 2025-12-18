//
//  ProjectService.swift
//  Molecular Design Platform
//
//  Service for managing research projects
//

import Foundation
import SwiftData

// MARK: - Project Service

@Observable
class ProjectService {
    // MARK: - Properties

    private let modelContext: ModelContext

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CRUD Operations

    /// Create a new project
    func createProject(name: String, description: String, owner: Researcher) async throws -> Project {
        let project = Project(name: name, description: description, owner: owner)

        modelContext.insert(project)
        try modelContext.save()

        return project
    }

    /// Fetch a specific project by ID
    func fetchProject(id: UUID) async throws -> Project? {
        let predicate = #Predicate<Project> { project in
            project.id == id
        }

        let descriptor = FetchDescriptor(predicate: predicate)
        let projects = try modelContext.fetch(descriptor)

        return projects.first
    }

    /// Fetch all projects for a user
    func fetchAllProjects() async throws -> [Project] {
        let descriptor = FetchDescriptor<Project>(
            sortBy: [SortDescriptor(\.modifiedDate, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    /// Update project
    func updateProject(_ project: Project) async throws {
        project.modifiedDate = Date()
        try modelContext.save()
    }

    /// Delete project
    func deleteProject(id: UUID) async throws {
        guard let project = try await fetchProject(id: id) else {
            throw ProjectServiceError.projectNotFound
        }

        modelContext.delete(project)
        try modelContext.save()
    }

    // MARK: - Collaboration

    /// Add collaborator to project
    func addCollaborator(_ collaborator: Researcher, to project: Project) async throws {
        guard !project.collaborators.contains(where: { $0.id == collaborator.id }) else {
            throw ProjectServiceError.collaboratorAlreadyExists
        }

        project.collaborators.append(collaborator)
        try await updateProject(project)
    }

    /// Remove collaborator from project
    func removeCollaborator(_ collaboratorID: UUID, from project: Project) async throws {
        project.collaborators.removeAll { $0.id == collaboratorID }
        try await updateProject(project)
    }

    /// Check if user has permission for action
    func checkPermission(user: Researcher, project: Project, action: ProjectAction) -> Bool {
        switch action {
        case .read:
            return project.owner.id == user.id ||
                   project.collaborators.contains(where: { $0.id == user.id }) ||
                   project.permissions.isPublic

        case .write:
            return project.owner.id == user.id ||
                   project.collaborators.contains { $0.id == user.id && $0.role.canEdit }

        case .delete:
            return project.owner.id == user.id

        case .share:
            return project.owner.id == user.id
        }
    }

    // MARK: - Molecules

    /// Add molecule to project
    func addMolecule(_ molecule: Molecule, to project: Project) async throws {
        molecule.project = project
        try modelContext.save()
    }

    /// Remove molecule from project
    func removeMolecule(_ molecule: Molecule, from project: Project) async throws {
        molecule.project = nil
        try modelContext.save()
    }

    // MARK: - Milestones

    /// Add milestone to project
    func addMilestone(_ milestone: Milestone, to project: Project) async throws {
        project.milestones.append(milestone)
        try await updateProject(project)
    }

    /// Complete milestone
    func completeMilestone(id: UUID, in project: Project) async throws {
        guard let index = project.milestones.firstIndex(where: { $0.id == id }) else {
            throw ProjectServiceError.milestoneNotFound
        }

        project.milestones[index].isCompleted = true
        project.milestones[index].completedDate = Date()
        try await updateProject(project)
    }
}

// MARK: - Project Action

enum ProjectAction {
    case read
    case write
    case delete
    case share
}

// MARK: - Project Service Errors

enum ProjectServiceError: LocalizedError {
    case projectNotFound
    case collaboratorAlreadyExists
    case milestoneNotFound
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .projectNotFound:
            return "Project not found"
        case .collaboratorAlreadyExists:
            return "Collaborator already exists in project"
        case .milestoneNotFound:
            return "Milestone not found"
        case .permissionDenied:
            return "Permission denied for this action"
        }
    }
}
