import Foundation
import Observation

@Observable
class ContentService {
    // Shared content in current meeting
    private(set) var sharedContent: [SharedContent] = []
    private(set) var selectedContent: SharedContent?

    init() {
        // Initialize content service
    }

    // MARK: - Content Sharing

    func shareContent(_ content: SharedContent) async throws {
        print("📤 Sharing content: \(content.title)")

        // In production: try await networkClient.post("/meetings/\(content.meetingId)/content", body: content)

        sharedContent.append(content)

        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3s

        print("✅ Content shared successfully")
    }

    func updateContent(_ content: SharedContent) async throws {
        guard let index = sharedContent.firstIndex(where: { $0.id == content.id }) else {
            throw ContentError.contentNotFound
        }

        content.version += 1
        content.modifiedAt = Date()

        sharedContent[index] = content

        print("💾 Content updated: \(content.title) (v\(content.version))")
    }

    func removeContent(_ contentId: UUID) async throws {
        sharedContent.removeAll { $0.id == contentId }
        print("🗑️ Content removed: \(contentId)")

        if selectedContent?.id == contentId {
            selectedContent = nil
        }
    }

    // MARK: - Content Selection

    func selectContent(_ content: SharedContent) {
        selectedContent = content
        print("👆 Content selected: \(content.title)")
    }

    func deselectContent() {
        selectedContent = nil
    }

    // MARK: - Content Manipulation

    func moveContent(_ contentId: UUID, to position: SpatialPosition) async throws {
        guard let index = sharedContent.firstIndex(where: { $0.id == contentId }) else {
            throw ContentError.contentNotFound
        }

        sharedContent[index].position = position
        sharedContent[index].modifiedAt = Date()

        // In production: sync with other participants
        print("📍 Content moved: \(sharedContent[index].title)")
    }

    func scaleContent(_ contentId: UUID, scale: Float) async throws {
        guard let index = sharedContent.firstIndex(where: { $0.id == contentId }) else {
            throw ContentError.contentNotFound
        }

        sharedContent[index].scale = scale
        sharedContent[index].modifiedAt = Date()

        print("📏 Content scaled: \(sharedContent[index].title) (scale: \(scale))")
    }

    func rotateContent(_ contentId: UUID, orientation: simd_quatf) async throws {
        guard let index = sharedContent.firstIndex(where: { $0.id == contentId }) else {
            throw ContentError.contentNotFound
        }

        sharedContent[index].orientation = orientation
        sharedContent[index].modifiedAt = Date()

        print("🔄 Content rotated: \(sharedContent[index].title)")
    }

    // MARK: - Annotations

    func addAnnotation(to contentId: UUID, annotation: Annotation) async throws {
        guard let index = sharedContent.firstIndex(where: { $0.id == contentId }) else {
            throw ContentError.contentNotFound
        }

        sharedContent[index].annotations.append(annotation)
        sharedContent[index].modifiedAt = Date()

        print("✏️ Annotation added to: \(sharedContent[index].title)")
    }

    func removeAnnotation(_ annotationId: UUID, from contentId: UUID) async throws {
        guard let index = sharedContent.firstIndex(where: { $0.id == contentId }) else {
            throw ContentError.contentNotFound
        }

        sharedContent[index].annotations.removeAll { $0.id == annotationId }
        print("🗑️ Annotation removed")
    }

    // MARK: - Content Types

    func createWhiteboard(meetingId: UUID, creatorId: UUID, title: String) -> SharedContent {
        let content = SharedContent(
            meetingId: meetingId,
            creatorId: creatorId,
            type: .whiteboard,
            title: title
        )

        // Position whiteboard in front of users
        content.position = SpatialPosition(x: 0, y: 1.5, z: -2.5)
        content.scale = 2.0

        return content
    }

    func createDocumentViewer(meetingId: UUID, creatorId: UUID, title: String, url: URL) -> SharedContent {
        let content = SharedContent(
            meetingId: meetingId,
            creatorId: creatorId,
            type: .document,
            title: title,
            url: url
        )

        content.position = SpatialPosition(x: 0, y: 1.5, z: -1.5)
        content.scale = 1.0

        return content
    }

    func create3DModel(meetingId: UUID, creatorId: UUID, title: String, url: URL) -> SharedContent {
        let content = SharedContent(
            meetingId: meetingId,
            creatorId: creatorId,
            type: .model3D,
            title: title,
            url: url
        )

        content.position = SpatialPosition(x: 0, y: 1.2, z: -2.0)
        content.scale = 1.5

        return content
    }
}

enum ContentError: LocalizedError {
    case contentNotFound
    case invalidContentType
    case uploadFailed
    case accessDenied

    var errorDescription: String? {
        switch self {
        case .contentNotFound: return "Content not found"
        case .invalidContentType: return "Invalid content type"
        case .uploadFailed: return "Upload failed"
        case .accessDenied: return "Access denied"
        }
    }
}
