import Foundation

/// Manages saving and loading of story state
@MainActor
class SaveSystem: @unchecked Sendable {
    // MARK: - Properties
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var saveDirectory: URL {
        get throws {
            try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("Saves", isDirectory: true)
        }
    }

    // MARK: - Initialization
    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601

        // Create saves directory if needed
        Task {
            await createSaveDirectory()
        }
    }

    private func createSaveDirectory() async {
        do {
            let directory = try saveDirectory
            if !fileManager.fileExists(atPath: directory.path) {
                try fileManager.createDirectory(
                    at: directory,
                    withIntermediateDirectories: true
                )
            }
        } catch {
            print("❌ Error creating save directory: \(error)")
        }
    }

    // MARK: - Auto Save
    func autoSave(_ state: StoryState) async {
        await saveToSlot(0, state: state)
        print("💾 Auto-saved")
    }

    // MARK: - Save to Slot
    func saveToSlot(_ slot: Int, state: StoryState) async {
        do {
            var updatedState = state
            updatedState.lastSaveDate = Date()

            let data = try encoder.encode(updatedState)
            let fileURL = try saveDirectory.appendingPathComponent("save_\(slot).json")

            try data.write(to: fileURL)
            print("💾 Saved to slot \(slot)")
        } catch {
            print("❌ Error saving: \(error)")
        }
    }

    // MARK: - Load from Slot
    func loadFromSlot(_ slot: Int) async -> StoryState? {
        do {
            let fileURL = try saveDirectory.appendingPathComponent("save_\(slot).json")

            guard fileManager.fileExists(atPath: fileURL.path) else {
                print("⚠️ No save found in slot \(slot)")
                return nil
            }

            let data = try Data(contentsOf: fileURL)
            let state = try decoder.decode(StoryState.self, from: data)

            print("📂 Loaded from slot \(slot)")
            return state
        } catch {
            print("❌ Error loading: \(error)")
            return nil
        }
    }

    // MARK: - Load Latest Save
    func loadLatestSave() async -> StoryState? {
        do {
            let directory = try saveDirectory
            let files = try fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: .skipsHiddenFiles
            )

            // Find most recent save
            let saves = files.filter { $0.pathExtension == "json" }
            guard let latestSave = saves.max(by: { url1, url2 in
                let date1 = try? url1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
                let date2 = try? url2.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
                return (date1 ?? Date.distantPast) < (date2 ?? Date.distantPast)
            }) else {
                return nil
            }

            let data = try Data(contentsOf: latestSave)
            let state = try decoder.decode(StoryState.self, from: data)

            print("📂 Loaded latest save")
            return state
        } catch {
            print("❌ Error loading latest save: \(error)")
            return nil
        }
    }

    // MARK: - Delete Save
    func deleteSave(slot: Int) async {
        do {
            let fileURL = try saveDirectory.appendingPathComponent("save_\(slot).json")

            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
                print("🗑️ Deleted save from slot \(slot)")
            }
        } catch {
            print("❌ Error deleting save: \(error)")
        }
    }

    // MARK: - List Saves
    func listSaves() async -> [SaveInfo] {
        do {
            let directory = try saveDirectory
            let files = try fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: .skipsHiddenFiles
            )

            let saves = files.filter { $0.pathExtension == "json" }

            return saves.compactMap { url in
                guard let slotString = url.deletingPathExtension().lastPathComponent.split(separator: "_").last,
                      let slot = Int(slotString),
                      let attributes = try? fileManager.attributesOfItem(atPath: url.path),
                      let modificationDate = attributes[.modificationDate] as? Date else {
                    return nil
                }

                return SaveInfo(slot: slot, date: modificationDate, url: url)
            }.sorted { $0.slot < $1.slot }
        } catch {
            print("❌ Error listing saves: \(error)")
            return []
        }
    }
}

// MARK: - Save Info
struct SaveInfo {
    let slot: Int
    let date: Date
    let url: URL
}
