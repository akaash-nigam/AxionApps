import SwiftUI
import SwiftData

/// Detailed view for creating, viewing, and editing construction issues
/// Supports full CRUD operations with spatial context and collaboration
struct IssueDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var issue: Issue

    @State private var showingCommentSheet = false
    @State private var showingPhotoCapture = false
    @State private var newComment = ""
    @State private var selectedAssignee: TeamMember?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with status and priority
                headerSection

                // Core information
                detailsSection

                // Spatial context
                locationSection

                // Assignment and dates
                managementSection

                // Impact assessment
                impactSection

                // Comments and collaboration
                commentsSection

                // Photos and documentation
                photosSection

                // Action buttons
                actionsSection
            }
            .padding()
        }
        .navigationTitle(issue.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .sheet(isPresented: $showingCommentSheet) {
            commentSheet
        }
        .sheet(isPresented: $showingPhotoCapture) {
            PhotoCaptureView(issue: issue)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(spacing: 16) {
            // Priority indicator
            VStack {
                Image(systemName: issue.priority.icon)
                    .font(.title2)
                    .foregroundStyle(issue.priority.color)
                Text(issue.priority.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80)

            Divider()

            // Status
            VStack(alignment: .leading, spacing: 4) {
                Text("Status")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("Status", selection: $issue.status) {
                    ForEach(IssueStatus.allCases, id: \.self) { status in
                        Label(status.rawValue.capitalized, systemImage: status.icon)
                            .tag(status)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
            }

            Spacer()

            // Overdue indicator
            if issue.isOverdue {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                    Text("Overdue")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            TextField("Issue Title", text: $issue.title)
                .textFieldStyle(.roundedBorder)

            TextField("Description", text: $issue.issueDescription, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(5...10)

            // Priority picker
            HStack {
                Text("Priority:")
                    .foregroundStyle(.secondary)
                Picker("Priority", selection: $issue.priority) {
                    ForEach(IssuePriority.allCases, id: \.self) { priority in
                        Label(priority.rawValue.capitalized, systemImage: priority.icon)
                            .tag(priority)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Category
            HStack {
                Text("Category:")
                    .foregroundStyle(.secondary)
                Picker("Category", selection: $issue.type) {
                    ForEach(IssueCategory.allCases, id: \.self) { category in
                        Text(category.rawValue.capitalized).tag(category)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Location Section

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Spatial Location", systemImage: "location.fill")
                .font(.headline)

            if let position = issue.position {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("X:")
                        Text(String(format: "%.2f m", position.x))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Y:")
                        Text(String(format: "%.2f m", position.y))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Z:")
                        Text(String(format: "%.2f m", position.z))
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)

                    Button(action: { /* Navigate to 3D view */ }) {
                        Label("View in 3D Space", systemImage: "cube.transparent")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                Text("No spatial location set")
                    .foregroundStyle(.secondary)
                    .italic()

                Button(action: { /* Set location in 3D */ }) {
                    Label("Set Location in AR", systemImage: "arkit")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            // Related BIM elements
            if !issue.relatedElementIDs.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Related Elements")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(issue.relatedElementIDs.count) element(s)")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Management Section

    private var managementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Assignment & Scheduling")
                .font(.headline)

            // Assignee
            HStack {
                Text("Assigned to:")
                    .foregroundStyle(.secondary)

                if !issue.assignedTo.isEmpty {
                    Text(issue.assignedTo)
                } else {
                    Text("Unassigned")
                        .foregroundStyle(.secondary)
                        .italic()
                }

                Spacer()

                Button("Change") {
                    // Show team member picker
                }
                .buttonStyle(.bordered)
            }

            // Dates
            DatePicker("Due Date:", selection: $issue.dueDate, displayedComponents: .date)

            HStack {
                let days = issue.daysUntilDue
                if days < 0 {
                    Label("\(abs(days)) days overdue", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                } else if days == 0 {
                    Label("Due today", systemImage: "clock.fill")
                        .foregroundStyle(.orange)
                } else {
                    Label("\(days) days remaining", systemImage: "calendar")
                        .foregroundStyle(days <= 3 ? .orange : .secondary)
                }
            }
            .font(.caption)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Impact Section

    private var impactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Impact Assessment")
                .font(.headline)

            // Cost impact
            HStack {
                Label("Cost Impact", systemImage: "dollarsign.circle")
                Spacer()
                if let cost = issue.costImpact {
                    Text(cost, format: .currency(code: "USD"))
                        .foregroundStyle(.secondary)
                } else {
                    Text("None")
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // Schedule impact
            HStack {
                Label("Schedule Impact", systemImage: "calendar.badge.exclamationmark")
                Spacer()
                if let scheduleImpact = issue.scheduleImpact {
                    let days = Int(scheduleImpact / 86400)
                    Text("\(days) day(s)")
                        .foregroundStyle(.secondary)
                } else {
                    Text("None")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Comments Section

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Comments", systemImage: "bubble.left.and.bubble.right")
                    .font(.headline)

                Spacer()

                Button(action: { showingCommentSheet = true }) {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }

            if issue.comments.isEmpty {
                Text("No comments yet")
                    .foregroundStyle(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(issue.comments.sorted(by: { $0.timestamp > $1.timestamp })) { comment in
                    CommentRow(comment: comment)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Photos Section

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Photos", systemImage: "photo.on.rectangle")
                    .font(.headline)

                Spacer()

                Button(action: { showingPhotoCapture = true }) {
                    Label("Add", systemImage: "camera")
                }
                .buttonStyle(.bordered)
            }

            if issue.photoURLs.isEmpty {
                Text("No photos attached")
                    .foregroundStyle(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(issue.photoURLs, id: \.self) { photoURL in
                            PhotoThumbnailURL(url: photoURL)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: 12) {
            if issue.status != .resolved {
                Button(action: resolveIssue) {
                    Label("Resolve Issue", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            Button(action: shareIssue) {
                Label("Share Issue Report", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive, action: deleteIssue) {
                Label("Delete Issue", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    // MARK: - Comment Sheet

    private var commentSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Add a comment...", text: $newComment, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...10)
                    .padding()

                Spacer()
            }
            .navigationTitle("Add Comment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingCommentSheet = false
                        newComment = ""
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        addComment()
                    }
                    .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Actions

    private func addComment() {
        let comment = IssueComment(
            text: newComment,
            author: "Current User", // TODO: Get from auth service
            timestamp: Date()
        )
        issue.comments.append(comment)

        newComment = ""
        showingCommentSheet = false
    }

    private func resolveIssue() {
        issue.status = .resolved
        issue.resolvedDate = Date()
    }

    private func shareIssue() {
        // TODO: Implement share functionality
        // Generate PDF report with issue details, photos, comments
    }

    private func deleteIssue() {
        modelContext.delete(issue)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Supporting Views

struct CommentRow: View {
    let comment: IssueComment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.author)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(comment.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(comment.text)
                .font(.body)
        }
        .padding(12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct PhotoThumbnail: View {
    let photo: PhotoReference

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.quaternary)
            .frame(width: 100, height: 100)
            .overlay {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
    }
}

struct PhotoThumbnailURL: View {
    let url: String

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.quaternary)
            .frame(width: 100, height: 100)
            .overlay {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
    }
}

struct PhotoCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    let issue: Issue

    var body: some View {
        NavigationStack {
            VStack {
                Text("Photo capture would integrate with camera here")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Capture Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var issue: Issue = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Issue.self, configurations: config)

        let issue = Issue(
            title: "Concrete Pour Quality Issue",
            description: "Visible cracks in foundation slab",
            type: .quality,
            priority: .high,
            status: .open,
            assignedTo: "John Smith",
            reporter: "Jane Doe",
            dueDate: Date().addingTimeInterval(86400 * 3)
        )
        issue.positionX = 10
        issue.positionY = 0
        issue.positionZ = 5
        issue.costImpact = 5000
        issue.scheduleImpact = 2 * 86400

        container.mainContext.insert(issue)
        return issue
    }()

    @Previewable @State var container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: Issue.self, configurations: config)
    }()

    NavigationStack {
        IssueDetailView(issue: issue)
    }
    .modelContainer(container)
}
