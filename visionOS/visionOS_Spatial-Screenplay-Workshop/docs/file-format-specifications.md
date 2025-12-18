# File Format Specifications

## Overview

This document defines all file formats used by Spatial Screenplay Workshop for project storage, import/export, and interchange with other applications.

## Native Project Format

### .screenplay File Format

**Purpose**: Native project file format for Spatial Screenplay Workshop

**Format**: Compressed ZIP archive containing JSON and assets

**Extension**: `.screenplay`

**MIME Type**: `application/vnd.screenplay-workshop.project`

### Archive Structure

```
MyScript.screenplay (ZIP)
├── manifest.json                    # Project metadata
├── project.json                     # Complete project data
├── scenes/
│   ├── scene_001.json
│   ├── scene_002.json
│   └── ...
├── characters/
│   ├── character_001.json
│   ├── character_002.json
│   └── ...
├── locations/
│   ├── location_001.json
│   └── ...
├── storyboards/
│   ├── storyboard_001/
│   │   ├── metadata.json
│   │   └── frames/
│   │       ├── frame_001.png
│   │       ├── frame_002.png
│   │       └── ...
│   └── ...
├── assets/
│   ├── custom-avatars/
│   │   └── custom_avatar_001.usdz
│   ├── custom-locations/
│   │   └── custom_location_001.usdz
│   └── reference-images/
│       └── reference_001.jpg
├── versions/
│   ├── v001.snapshot.json
│   ├── v002.snapshot.json
│   └── ...
└── spatial-layout.json              # Saved spatial positions
```

### manifest.json

```json
{
  "format": "screenplay-workshop",
  "version": "1.0",
  "schema_version": 2,
  "created_at": "2025-11-24T10:30:00Z",
  "modified_at": "2025-11-24T15:45:00Z",
  "app_version": "1.0.0",
  "metadata": {
    "title": "My Screenplay",
    "author": "John Smith",
    "project_type": "featureFilm",
    "total_scenes": 45,
    "total_pages": 105.5,
    "character_count": 12,
    "location_count": 18
  },
  "files": {
    "project": "project.json",
    "scenes_directory": "scenes/",
    "characters_directory": "characters/",
    "locations_directory": "locations/",
    "storyboards_directory": "storyboards/",
    "assets_directory": "assets/",
    "versions_directory": "versions/"
  },
  "checksum": "sha256:abc123...",
  "compression": "zip"
}
```

### project.json

Complete project data serialized as JSON:

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "My Screenplay",
  "logline": "A writer discovers their stories come to life.",
  "type": "featureFilm",
  "created_at": "2025-11-24T10:30:00Z",
  "modified_at": "2025-11-24T15:45:00Z",
  "author": "John Smith",
  "metadata": {
    "genre": "Drama",
    "target_page_count": 110,
    "current_page_count": 105.5,
    "word_count": 25000,
    "scene_count": 45,
    "character_count": 12,
    "status": "firstDraft",
    "tags": ["drama", "writer", "metafiction"]
  },
  "settings": {
    "default_font": "Courier",
    "font_size": 12,
    "page_size": "letter",
    "color_coding_mode": "location",
    "auto_save_interval": 300,
    "revision_color": "white"
  },
  "scenes": [
    {
      "id": "scene_001_id",
      "$ref": "scenes/scene_001.json"
    }
  ],
  "characters": [
    {
      "id": "character_001_id",
      "$ref": "characters/character_001.json"
    }
  ],
  "locations": [
    {
      "id": "location_001_id",
      "$ref": "locations/location_001.json"
    }
  ],
  "storyboards": [
    {
      "id": "storyboard_001_id",
      "$ref": "storyboards/storyboard_001/metadata.json"
    }
  ],
  "collaborators": [],
  "version_history": [
    {
      "id": "version_001_id",
      "$ref": "versions/v001.snapshot.json"
    }
  ]
}
```

### Scene File (scene_001.json)

```json
{
  "id": "scene_001_id",
  "scene_number": 1,
  "slug_line": {
    "setting": "INT",
    "location": "COFFEE SHOP",
    "time_of_day": "DAY"
  },
  "content": {
    "elements": [
      {
        "type": "action",
        "data": {
          "text": "ALEX sits across from SARAH, nervous.",
          "is_character_intro": true
        }
      },
      {
        "type": "dialogue",
        "data": {
          "character_id": "alex_id",
          "character_name": "ALEX",
          "parenthetical": "hesitant",
          "lines": ["I need to tell you something."],
          "is_dual_dialogue": false
        }
      }
    ]
  },
  "characters": ["alex_id", "sarah_id"],
  "location_id": "coffee_shop_id",
  "page_length": 2.5,
  "status": "locked",
  "position": {
    "act": 1,
    "sequence": 1,
    "spatial_position": {
      "x": -1.5,
      "y": 1.4,
      "z": -2.0,
      "rotation": 0.0
    }
  },
  "metadata": {
    "summary": "Alex reveals secret to Sarah",
    "mood": "tense",
    "story_thread": "main",
    "importance": "critical",
    "estimated_duration": 150,
    "shot_count": 5
  },
  "notes": [],
  "revisions": [],
  "created_at": "2025-11-24T10:35:00Z",
  "modified_at": "2025-11-24T12:20:00Z"
}
```

### Version Snapshot (v001.snapshot.json)

```json
{
  "id": "version_001_id",
  "version_number": 1,
  "revision_color": "white",
  "snapshot": {
    "scenes_data": "base64_encoded_compressed_data",
    "checksum": "sha256:xyz789..."
  },
  "change_description": "First draft complete",
  "author": "John Smith",
  "created_at": "2025-11-24T17:00:00Z",
  "is_auto_save": false
}
```

### Implementation

```swift
class ScreenplayArchiver {
    func save(project: Project, to url: URL) async throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Write manifest
        let manifest = createManifest(project: project)
        try writeJSON(manifest, to: tempDir.appendingPathComponent("manifest.json"))

        // Write project
        try writeJSON(project, to: tempDir.appendingPathComponent("project.json"))

        // Write scenes
        let scenesDir = tempDir.appendingPathComponent("scenes")
        try FileManager.default.createDirectory(at: scenesDir, withIntermediateDirectories: true)
        for (index, scene) in project.scenes.enumerated() {
            let sceneFile = scenesDir.appendingPathComponent("scene_\(String(format: "%03d", index + 1)).json")
            try writeJSON(scene, to: sceneFile)
        }

        // Write characters, locations, etc.
        // ...

        // Compress to ZIP
        try zipDirectory(tempDir, to: url)

        // Cleanup
        try FileManager.default.removeItem(at: tempDir)
    }

    func load(from url: URL) async throws -> Project {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        // Unzip
        try unzipArchive(url, to: tempDir)

        // Read manifest
        let manifestURL = tempDir.appendingPathComponent("manifest.json")
        let manifest = try readJSON(Manifest.self, from: manifestURL)

        // Validate version
        guard manifest.schemaVersion <= currentSchemaVersion else {
            throw ArchiveError.unsupportedVersion(manifest.schemaVersion)
        }

        // Read project
        let projectURL = tempDir.appendingPathComponent(manifest.files.project)
        var project = try readJSON(Project.self, from: projectURL)

        // Load scenes
        project.scenes = try loadScenes(from: tempDir, manifest: manifest)

        // Load characters, locations, etc.
        // ...

        // Cleanup
        try FileManager.default.removeItem(at: tempDir)

        return project
    }
}
```

## Export Formats

### PDF Export

**Purpose**: Production-ready screenplay PDF

**Specification**: PDF 1.7, US Letter, Courier 12pt

See `integration-specifications.md` for detailed PDF generation.

**File naming**: `{ProjectTitle}.pdf`

**Metadata**:
```
Title: Project title
Author: Author name
Subject: Screenplay
Creator: Spatial Screenplay Workshop 1.0
Keywords: screenplay, script
CreationDate: ISO 8601 timestamp
```

### Final Draft (.fdx)

**Purpose**: Interchange with Final Draft software

**Format**: XML

See `integration-specifications.md` for FDX structure and conversion.

**File naming**: `{ProjectTitle}.fdx`

### Fountain (.fountain)

**Purpose**: Plain-text screenplay format

**Format**: Plain text with Markdown-like syntax

See `integration-specifications.md` for Fountain syntax.

**File naming**: `{ProjectTitle}.fountain`

**Encoding**: UTF-8

**Line endings**: Unix (LF) or Windows (CRLF)

### HTML Export

**Purpose**: Web-viewable screenplay

**Format**: HTML5 with embedded CSS

**Structure**:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Screenplay</title>
    <style>
        body {
            font-family: 'Courier New', monospace;
            font-size: 12pt;
            line-height: 1.0;
            max-width: 6in;
            margin: 0 auto;
            padding: 1in;
        }
        .slug-line {
            font-weight: bold;
            margin-top: 2em;
        }
        .action {
            margin: 1em 0;
        }
        .character {
            margin-left: 2.2in;
            margin-top: 1em;
        }
        .parenthetical {
            margin-left: 1.6in;
        }
        .dialogue {
            margin-left: 1.0in;
            margin-right: 1.5in;
        }
    </style>
</head>
<body>
    <div class="slug-line">INT. COFFEE SHOP - DAY</div>
    <div class="action">ALEX sits across from SARAH, nervous.</div>
    <div class="character">ALEX</div>
    <div class="parenthetical">(hesitant)</div>
    <div class="dialogue">I need to tell you something.</div>
    <!-- ... -->
</body>
</html>
```

**Exporter**:
```swift
class HTMLExporter {
    func exportHTML(project: Project) -> String {
        var html = htmlHeader(project: project)

        for scene in project.scenes {
            html += "<div class=\"slug-line\">\(scene.slugLine.formatted)</div>\n"

            for element in scene.content.elements {
                html += formatElement(element)
            }
        }

        html += htmlFooter()
        return html
    }

    private func formatElement(_ element: ScriptElement) -> String {
        switch element {
        case .action(let action):
            return "<div class=\"action\">\(htmlEscape(action.text))</div>\n"

        case .dialogue(let dialogue):
            var html = "<div class=\"character\">\(dialogue.characterName)</div>\n"
            if let paren = dialogue.parenthetical {
                html += "<div class=\"parenthetical\">(\(htmlEscape(paren)))</div>\n"
            }
            for line in dialogue.lines {
                html += "<div class=\"dialogue\">\(htmlEscape(line))</div>\n"
            }
            return html

        case .transition(let transition):
            return "<div class=\"transition\">\(transition.type.rawValue)</div>\n"

        case .shot(let shot):
            return "<div class=\"shot\">\(htmlEscape(shot.text))</div>\n"
        }
    }
}
```

### JSON Export

**Purpose**: Data interchange, API integration

**Format**: JSON

**Structure**:
```json
{
  "project": {
    "title": "My Screenplay",
    "author": "John Smith",
    "type": "featureFilm",
    "page_count": 105.5
  },
  "scenes": [
    {
      "number": 1,
      "slug_line": "INT. COFFEE SHOP - DAY",
      "page_length": 2.5,
      "elements": [
        {
          "type": "action",
          "text": "ALEX sits across from SARAH, nervous."
        },
        {
          "type": "dialogue",
          "character": "ALEX",
          "parenthetical": "hesitant",
          "lines": ["I need to tell you something."]
        }
      ]
    }
  ]
}
```

## Storyboard Formats

### Individual Frames

**Format**: PNG

**Resolution**: 1920×1080 (HD) or 3840×2160 (4K)

**Naming**: `frame_{number}.png` (e.g., `frame_001.png`)

**Metadata** (PNG text chunks):
- `Scene`: Scene number
- `Shot`: Shot type
- `Duration`: Frame duration in seconds
- `Dialogue`: Associated dialogue

### Animatic Video

**Format**: MP4 (H.264)

**Resolution**: 1920×1080 @ 24 fps

**Audio**: AAC, 48kHz, stereo

**Structure**:
- Each frame displayed for specified duration
- Transitions between frames
- Optional temp dialogue audio
- Optional temp music

**Exporter**:
```swift
import AVFoundation

class AnimaticExporter {
    func exportVideo(storyboard: Storyboard) async throws -> URL {
        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )!

        var currentTime = CMTime.zero

        for frame in storyboard.frames {
            // Load frame image
            let image = try loadImage(frame: frame)

            // Create video from image
            let videoAsset = try createVideoAsset(
                from: image,
                duration: frame.duration
            )

            // Insert into composition
            let timeRange = CMTimeRange(
                start: .zero,
                duration: CMTime(seconds: frame.duration, preferredTimescale: 600)
            )
            try videoTrack.insertTimeRange(
                timeRange,
                of: videoAsset.tracks(withMediaType: .video)[0],
                at: currentTime
            )

            currentTime = CMTimeAdd(currentTime, timeRange.duration)
        }

        // Export
        let exporter = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        )!
        exporter.outputFileType = .mp4
        exporter.outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(storyboard.id).mp4")

        await exporter.export()

        return exporter.outputURL!
    }
}
```

### PDF Storyboard

**Format**: PDF

**Layout**: 2×3 grid (6 frames per page)

**Content**:
- Frame image
- Shot number
- Shot type
- Duration
- Dialogue (if any)

**Page Structure**:
```
┌─────────────────┬─────────────────┬─────────────────┐
│   Frame 1       │   Frame 2       │   Frame 3       │
│   [Image]       │   [Image]       │   [Image]       │
│   Shot: WS      │   Shot: MS      │   Shot: CU      │
│   3s            │   2s            │   4s            │
├─────────────────┼─────────────────┼─────────────────┤
│   Frame 4       │   Frame 5       │   Frame 6       │
│   [Image]       │   [Image]       │   [Image]       │
│   Shot: OTS     │   Shot: WS      │   Shot: CU      │
│   3s            │   2s            │   3s            │
└─────────────────┴─────────────────┴─────────────────┘
```

## Import Formats

### Supported Import Formats

| Format | Extension | Read | Write | Notes |
|--------|-----------|------|-------|-------|
| Native | .screenplay | ✅ | ✅ | Full fidelity |
| Final Draft | .fdx | ✅ | ✅ | Industry standard |
| Fountain | .fountain | ✅ | ✅ | Plain text |
| PDF | .pdf | ⚠️ | ✅ | OCR-based, limited accuracy |
| Plain Text | .txt | ⚠️ | ❌ | Heuristic parsing |
| Celtx | .celtx | ⚠️ | ❌ | Limited support |

### Import Pipeline

```swift
class ImportManager {
    func detectFormat(url: URL) -> ImportFormat {
        let ext = url.pathExtension.lowercased()

        switch ext {
        case "screenplay":
            return .native
        case "fdx":
            return .finalDraft
        case "fountain":
            return .fountain
        case "pdf":
            return .pdf
        case "txt":
            return .plainText
        default:
            throw ImportError.unsupportedFormat(ext)
        }
    }

    func importProject(from url: URL) async throws -> Project {
        let format = detectFormat(url: url)

        switch format {
        case .native:
            return try await ScreenplayArchiver().load(from: url)

        case .finalDraft:
            return try await FinalDraftImporter().importFDX(from: url)

        case .fountain:
            let text = try String(contentsOf: url, encoding: .utf8)
            return FountainParser().parse(text)

        case .pdf:
            return try await PDFImporter().importPDF(from: url)

        case .plainText:
            let text = try String(contentsOf: url, encoding: .utf8)
            return HeuristicParser().parse(text)
        }
    }
}
```

### PDF Import (OCR)

```swift
import Vision
import PDFKit

class PDFImporter {
    func importPDF(from url: URL) async throws -> Project {
        let pdfDocument = PDFDocument(url: url)!

        var extractedText = ""

        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }

            // Extract text using Vision
            let pageText = try await extractText(from: page)
            extractedText += pageText + "\n"
        }

        // Parse extracted text
        let parser = HeuristicParser()
        return parser.parse(extractedText)
    }

    private func extractText(from page: PDFPage) async throws -> String {
        // Use Vision framework for OCR
        guard let image = page.thumbnail(of: page.bounds(for: .mediaBox).size, for: .mediaBox) else {
            return ""
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        guard let observations = request.results else {
            return ""
        }

        return observations.compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")
    }
}
```

## Interchange Formats

### Movie Magic Scheduling

**Format**: CSV

**Purpose**: Export scene data for production scheduling

See `integration-specifications.md` for detailed CSV structure.

### Shot List

**Format**: CSV or PDF

**Structure**:
```csv
Scene,Shot,Type,Description,Duration,Camera,Notes
1,1A,WS,"Establish coffee shop",3s,Static,"Natural lighting"
1,1B,MS,"Alex and Sarah at table",2s,Dolly in,""
1,1C,CU,"Alex nervous",4s,Handheld,"Focus on hands"
```

### Character Breakdown

**Format**: PDF or JSON

**Content**:
- Character name
- Age, gender, description
- Scene appearances
- Line count
- First/last appearance

## Backup Formats

### Auto-Save

**Location**: `~/Library/Application Support/SpatialScreenplayWorkshop/AutoSave/`

**Format**: Same as `.screenplay` format

**Naming**: `{ProjectID}_autosave_{timestamp}.screenplay`

**Frequency**: Every 5 minutes (configurable)

**Retention**: Keep last 10 auto-saves, delete older

### iCloud Backup

**Location**: iCloud Drive

**Path**: `iCloud/SpatialScreenplayWorkshop/Projects/`

**Sync**: Automatic via CloudKit

## Version Migration

### Schema Versioning

```swift
enum SchemaVersion: Int, Codable {
    case v1 = 1
    case v2 = 2
    // Future versions

    static var current: SchemaVersion { .v2 }
}

class ProjectMigrator {
    func migrate(data: Data, from: SchemaVersion, to: SchemaVersion) throws -> Data {
        var migratedData = data

        for version in (from.rawValue + 1)...to.rawValue {
            guard let schemaVersion = SchemaVersion(rawValue: version) else {
                throw MigrationError.unsupportedVersion(version)
            }

            migratedData = try migrateToVersion(migratedData, version: schemaVersion)
        }

        return migratedData
    }

    private func migrateToVersion(_ data: Data, version: SchemaVersion) throws -> Data {
        switch version {
        case .v1:
            return data  // Initial version

        case .v2:
            return try migrateV1toV2(data)
        }
    }

    private func migrateV1toV2(_ data: Data) throws -> Data {
        // V1 → V2: Add collaboration features
        var project = try JSONDecoder().decode(ProjectV1.self, from: data)

        let projectV2 = ProjectV2(
            id: project.id,
            title: project.title,
            // ... copy existing fields
            collaborators: [],  // New field
            versionHistory: []  // New field
        )

        return try JSONEncoder().encode(projectV2)
    }
}
```

## File Validation

### Validation Rules

```swift
struct FileValidator {
    func validate(archive: URL) throws {
        // 1. Check file exists
        guard FileManager.default.fileExists(atPath: archive.path) else {
            throw ValidationError.fileNotFound
        }

        // 2. Check is valid ZIP
        guard isValidZIP(archive) else {
            throw ValidationError.invalidArchive
        }

        // 3. Verify manifest exists
        let manifest = try extractManifest(from: archive)

        // 4. Verify schema version
        guard manifest.schemaVersion <= SchemaVersion.current.rawValue else {
            throw ValidationError.unsupportedVersion(manifest.schemaVersion)
        }

        // 5. Verify checksum
        let computedChecksum = try computeChecksum(archive)
        guard computedChecksum == manifest.checksum else {
            throw ValidationError.checksumMismatch
        }

        // 6. Verify required files exist
        try verifyRequiredFiles(archive, manifest: manifest)
    }

    private func verifyRequiredFiles(_ archive: URL, manifest: Manifest) throws {
        let requiredFiles = [
            manifest.files.project,
            manifest.files.scenesDirectory,
            manifest.files.charactersDirectory
        ]

        for file in requiredFiles {
            // Verify file exists in archive
        }
    }
}
```

## Performance Considerations

### Streaming

For large projects, stream data instead of loading entirely into memory:

```swift
class StreamingReader {
    func streamScenes(from archive: URL) -> AsyncStream<Scene> {
        AsyncStream { continuation in
            Task {
                // Open archive
                let unzipper = try Unzipper(url: archive)

                // Find scene files
                let sceneFiles = unzipper.entries.filter { $0.hasPrefix("scenes/") }

                for sceneFile in sceneFiles {
                    let data = try unzipper.extract(sceneFile)
                    let scene = try JSONDecoder().decode(Scene.self, from: data)
                    continuation.yield(scene)
                }

                continuation.finish()
            }
        }
    }
}
```

### Compression

Use appropriate compression for different data types:

```swift
enum CompressionMethod {
    case none        // Already compressed (images, etc.)
    case deflate     // Text, JSON (good ratio)
    case lzma        // Maximum compression (slower)
}

func compress(data: Data, method: CompressionMethod) throws -> Data {
    switch method {
    case .none:
        return data
    case .deflate:
        return try (data as NSData).compressed(using: .zlib) as Data
    case .lzma:
        return try (data as NSData).compressed(using: .lzma) as Data
    }
}
```

---

**Document Version**: 1.0
**Last Updated**: 2025-11-24
**Author**: File Format Team
