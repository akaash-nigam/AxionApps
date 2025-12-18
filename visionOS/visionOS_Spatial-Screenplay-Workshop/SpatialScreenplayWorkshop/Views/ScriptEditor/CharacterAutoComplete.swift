//
//  CharacterAutoComplete.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import SwiftUI

/// Auto-complete view for character names
struct CharacterAutoComplete: View {
    let characters: [Character]
    let searchText: String
    let onSelect: (String) -> Void
    let onDismiss: () -> Void

    var filteredCharacters: [Character] {
        if searchText.isEmpty {
            return characters
        }
        return characters.filter { character in
            character.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        if !filteredCharacters.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(filteredCharacters.prefix(5)) { character in
                    Button {
                        onSelect(character.name)
                    } label: {
                        HStack {
                            Text(character.name)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.primary)

                            Spacer()

                            if character.metadata.lineCount > 0 {
                                Text("\(character.metadata.lineCount) lines")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(Color(.systemBackground))

                    if character.id != filteredCharacters.prefix(5).last?.id {
                        Divider()
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.2), radius: 8)
            .padding(.horizontal)
        }
    }
}

// MARK: - Character Extractor

/// Extract character names from text
struct CharacterExtractor {
    /// Extract all character names from script content
    static func extractCharacters(from content: SceneContent) -> Set<String> {
        var names = Set<String>()

        for element in content.elements {
            if case .dialogue(let dialogue) = element {
                names.insert(dialogue.characterName)
            }
        }

        return names
    }

    /// Extract character names from all scenes in project
    static func extractCharacters(from project: Project) -> [Character] {
        guard let scenes = project.scenes else { return [] }

        var characterNames = Set<String>()

        // Extract from dialogue
        for scene in scenes {
            for element in scene.content.elements {
                if case .dialogue(let dialogue) = element {
                    characterNames.insert(dialogue.characterName)
                }
            }
        }

        // Create Character objects for names not yet in database
        var characters: [Character] = []
        for name in characterNames.sorted() {
            let character = Character(name: name)
            characters.append(character)
        }

        return characters
    }

    /// Get current word being typed
    static func getCurrentWord(from text: String, at position: Int) -> String? {
        guard position > 0, position <= text.count else { return nil }

        let index = text.index(text.startIndex, offsetBy: position)
        let beforeCursor = text[..<index]

        // Get last line
        let lines = beforeCursor.components(separatedBy: .newlines)
        guard let currentLine = lines.last else { return nil }

        // Check if line looks like a character name (all caps)
        let trimmed = currentLine.trimmingCharacters(in: .whitespaces)
        if trimmed == trimmed.uppercased() && !trimmed.isEmpty {
            return trimmed
        }

        return nil
    }
}

// MARK: - Preview

#Preview {
    VStack {
        CharacterAutoComplete(
            characters: Character.sampleCharacters(),
            searchText: "AL",
            onSelect: { name in
                print("Selected: \(name)")
            },
            onDismiss: {}
        )

        Spacer()
    }
    .padding()
}
