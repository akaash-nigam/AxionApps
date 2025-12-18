//
//  PhotoGalleryView.swift
//  PhysicalDigitalTwins
//
//  Gallery view for displaying item photos
//

import SwiftUI
import PhotosUI

struct PhotoGalleryView: View {
    let item: InventoryItem
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var loadedPhotos: [LoadedPhoto] = []
    @State private var isLoading = true
    @State private var selectedPhoto: LoadedPhoto?
    @State private var photoToDelete: LoadedPhoto?
    @State private var showingDeleteAlert = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var isAddingPhoto = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading photos...")
                } else if loadedPhotos.isEmpty {
                    emptyState
                } else {
                    photoGrid
                }
            }
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    PhotosPicker(
                        selection: $selectedPhotoItems,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        Label("Add Photos", systemImage: "plus")
                    }
                }
            }
            .task {
                await loadPhotos()
            }
            .onChange(of: selectedPhotoItems) { oldValue, newValue in
                Task {
                    await addSelectedPhotos()
                }
            }
            .sheet(item: $selectedPhoto) { photo in
                FullScreenPhotoView(photo: photo, onDelete: {
                    photoToDelete = photo
                    showingDeleteAlert = true
                })
            }
            .alert("Delete Photo?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let photo = photoToDelete {
                        Task {
                            await deletePhoto(photo)
                        }
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No Photos Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add photos to visually document your items")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            PhotosPicker(
                selection: $selectedPhotoItems,
                maxSelectionCount: 5,
                matching: .images
            ) {
                Label("Add Photos", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(.blue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }

    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(loadedPhotos) { photo in
                    PhotoThumbnail(photo: photo)
                        .onTapGesture {
                            selectedPhoto = photo
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                photoToDelete = photo
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }

    private func loadPhotos() async {
        isLoading = true
        defer { isLoading = false }

        guard let photoPaths = item.photosPaths else {
            return
        }

        var photos: [LoadedPhoto] = []
        for path in photoPaths {
            if let image = try? await appState.dependencies.photoService.loadPhoto(path: path) {
                photos.append(LoadedPhoto(path: path, image: image))
            }
        }

        loadedPhotos = photos
    }

    private func addSelectedPhotos() async {
        isAddingPhoto = true
        defer { isAddingPhoto = false }

        var newPaths = item.photosPaths ?? []

        for photoItem in selectedPhotoItems {
            if let data = try? await photoItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {

                do {
                    let path = try await appState.dependencies.photoService.savePhoto(uiImage, itemId: item.id)
                    newPaths.append(path)
                    HapticManager.shared.photoAdded()
                } catch {
                    print("Failed to save photo: \(error)")
                    HapticManager.shared.error()
                }
            }
        }

        // Update item with new photo paths
        var updatedItem = item
        updatedItem.photosPaths = newPaths

        await appState.updateItem(updatedItem)

        // Clear selection and reload
        selectedPhotoItems = []
        await loadPhotos()
    }

    private func deletePhoto(_ photo: LoadedPhoto) async {
        // Delete from file system
        try? await appState.dependencies.photoService.deletePhoto(path: photo.path)

        // Update item to remove path
        var updatedItem = item
        updatedItem.photosPaths = item.photosPaths?.filter { $0 != photo.path }

        await appState.updateItem(updatedItem)
        HapticManager.shared.photoDeleted()

        // Reload photos
        await loadPhotos()
    }
}

// MARK: - Supporting Views

struct PhotoThumbnail: View {
    let photo: LoadedPhoto

    var body: some View {
        Image(uiImage: photo.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct FullScreenPhotoView: View {
    let photo: LoadedPhoto
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                Image(uiImage: photo.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        onDelete()
                        dismiss()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}

// MARK: - Models

struct LoadedPhoto: Identifiable {
    let id = UUID()
    let path: String
    let image: UIImage
}
