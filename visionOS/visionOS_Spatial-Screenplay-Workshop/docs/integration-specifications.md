# Integration Specifications

## Overview

This document specifies all external integrations for Spatial Screenplay Workshop, including file format support, API integrations, and third-party service connections.

## File Format Integrations

### 1. Final Draft (.fdx)

**Purpose**: Import/export industry-standard screenplay format

**Format**: XML-based

**Specification Version**: Final Draft 12+

#### Import Flow

```swift
class FinalDraftImporter {
    func importFDX(from url: URL) async throws -> Project {
        // 1. Parse XML
        let xmlData = try Data(contentsOf: url)
        let parser = FDXParser()
        let fdxDocument = try parser.parse(xmlData)

        // 2. Convert to internal model
        let project = try convertToProject(fdxDocument)

        // 3. Validate
        try validateProject(project)

        return project
    }
}
```

#### FDX Structure Mapping

```xml
<!-- FDX Document Structure -->
<FinalDraft>
  <Content>
    <Paragraph Type="Scene Heading">
      <Text>INT. COFFEE SHOP - DAY</Text>
    </Paragraph>
    <Paragraph Type="Action">
      <Text>ALEX sits across from SARAH.</Text>
    </Paragraph>
    <Paragraph Type="Character">
      <Text>ALEX</Text>
    </Paragraph>
    <Paragraph Type="Parenthetical">
      <Text>(nervous)</Text>
    </Paragraph>
    <Paragraph Type="Dialogue">
      <Text>I need to tell you something.</Text>
    </Paragraph>
  </Content>
  <ElementSettings>
    <!-- Character definitions -->
  </ElementSettings>
  <TitlePage>
    <Content>
      <Paragraph Type="Title">
        <Text>My Screenplay</Text>
      </Paragraph>
      <Paragraph Type="Author">
        <Text>John Smith</Text>
      </Paragraph>
    </Content>
  </TitlePage>
</FinalDraft>
```

#### Element Type Mapping

| FDX Type | Internal Type |
|----------|---------------|
| `Scene Heading` | `SlugLine` |
| `Action` | `ScriptElement.action` |
| `Character` | `DialogueElement.characterName` |
| `Parenthetical` | `DialogueElement.parenthetical` |
| `Dialogue` | `DialogueElement.lines` |
| `Transition` | `TransitionElement` |
| `Shot` | `ShotElement` |

#### Export Flow

```swift
class FinalDraftExporter {
    func exportFDX(project: Project) async throws -> URL {
        // 1. Convert to FDX structure
        let fdxDocument = FDXDocument()
        fdxDocument.titlePage = createTitlePage(project)

        for scene in project.scenes {
            fdxDocument.content.append(createSceneHeading(scene.slugLine))
            for element in scene.content.elements {
                fdxDocument.content.append(convertElement(element))
            }
        }

        // 2. Generate XML
        let xmlData = try XMLEncoder().encode(fdxDocument)

        // 3. Write to file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(project.title).fdx")
        try xmlData.write(to: tempURL)

        return tempURL
    }
}
```

#### Character Handling

**Import**:
- Extract character names from ElementSettings
- Deduplicate characters
- Create Character records with names
- Default voice settings applied

**Export**:
- Generate ElementSettings with all characters
- Include character appearance counts
- Preserve character order from first appearance

#### Revision Tracking

**FDX Revisions**:
```xml
<Paragraph>
  <Text RevisionID="1" RevisionColor="Blue">New line</Text>
</Paragraph>
```

**Mapping**:
```swift
RevisionColor mapping:
- White → .white
- Blue → .blue
- Pink → .pink
- Yellow → .yellow
- Green → .green
// ... etc
```

### 2. Fountain (.fountain)

**Purpose**: Plain-text screenplay format

**Specification**: Fountain Syntax 1.1

#### Syntax Overview

```fountain
Title: My Screenplay
Author: John Smith
Draft date: 2025-11-24

INT. COFFEE SHOP - DAY

ALEX sits across from SARAH, nervous.

ALEX
(hesitant)
I need to tell you something.

SARAH
What is it?

FADE OUT.
```

#### Parser Rules

```swift
class FountainParser {
    func parse(_ text: String) -> Project {
        let lines = text.components(separatedBy: .newlines)

        var inTitlePage = true
        var elements: [ScriptElement] = []

        for line in lines {
            if inTitlePage && !line.isEmpty {
                parseTitlePageLine(line)
            } else if line.isEmpty {
                inTitlePage = false
            } else if isSceneHeading(line) {
                elements.append(parseSceneHeading(line))
            } else if isCharacter(line) {
                elements.append(parseDialogue(line))
            } else if isTransition(line) {
                elements.append(parseTransition(line))
            } else {
                elements.append(parseAction(line))
            }
        }

        return createProject(elements)
    }

    private func isSceneHeading(_ line: String) -> Bool {
        // Starts with INT, EXT, INT./EXT, or begins with .
        return line.uppercased().hasPrefix("INT.") ||
               line.uppercased().hasPrefix("EXT.") ||
               line.hasPrefix(".")
    }

    private func isCharacter(_ line: String) -> Bool {
        // All uppercase, or preceded by @
        return line == line.uppercased() && !line.isEmpty ||
               line.hasPrefix("@")
    }

    private func isTransition(_ line: String) -> Bool {
        // Ends with TO: or starts with >
        return line.hasSuffix("TO:") || line.hasPrefix(">")
    }
}
```

#### Fountain Features Support

| Feature | Support | Notes |
|---------|---------|-------|
| Title Page | ✅ Full | All standard fields |
| Scene Headings | ✅ Full | INT/EXT detection |
| Action | ✅ Full | |
| Character | ✅ Full | @force character |
| Dialogue | ✅ Full | Including parentheticals |
| Parenthetical | ✅ Full | |
| Dual Dialogue | ✅ Full | ^ syntax |
| Lyrics | ✅ Full | ~ syntax |
| Transition | ✅ Full | > force transition |
| Centered Text | ✅ Full | > text < |
| Page Breaks | ⚠️ Partial | === supported |
| Line Breaks | ✅ Full | Preserved |
| Emphasis | ❌ None | Stripped on import |
| Bold/Italic/Underline | ❌ None | Stripped on import |
| Title Page | ✅ Full | Key: Value syntax |
| Sections/Synopsis | ⚠️ Partial | Imported as notes |
| Notes | ✅ Full | [[ ]] syntax → Scene notes |
| Boneyard | ❌ None | /* */ ignored |

#### Export Flow

```swift
class FountainExporter {
    func exportFountain(project: Project) -> String {
        var output = ""

        // Title page
        output += "Title: \(project.title)\n"
        output += "Author: \(project.author)\n"
        output += "Draft date: \(project.modifiedAt.formatted())\n\n"

        // Scenes
        for scene in project.scenes {
            output += formatSlugLine(scene.slugLine) + "\n\n"

            for element in scene.content.elements {
                output += formatElement(element) + "\n"
            }
            output += "\n"
        }

        return output
    }
}
```

### 3. PDF Export

**Purpose**: Production-ready screenplay PDFs

**Format**: PDF 1.7

**Page Setup**:
- Size: US Letter (8.5" × 11")
- Margins: Top 1", Bottom 0.5", Left 1.5", Right 1"
- Font: Courier 12pt
- Line spacing: Single (12pt)

#### PDF Generation

```swift
import PDFKit

class PDFExporter {
    func exportPDF(project: Project) async throws -> URL {
        let pageSize = CGSize(width: 612, height: 792) // US Letter

        let renderer = PDFRenderer(pageSize: pageSize)

        // Title page
        if let titlePage = createTitlePage(project) {
            renderer.addPage(titlePage)
        }

        // Script pages
        let formatter = ScreenplayFormatter()
        let pages = formatter.paginateScript(project.scenes)

        for page in pages {
            let pdfPage = createPDFPage(page, size: pageSize)
            renderer.addPage(pdfPage)
        }

        // Generate PDF
        let pdfData = renderer.render()
        let url = savePDF(pdfData, title: project.title)

        return url
    }

    private func createTitlePage(_ project: Project) -> PDFPage {
        // Centered title page layout
        // Title: Center, 1/3 down page
        // Author: Center, below title
        // Contact: Bottom right
    }
}
```

#### Screenplay Formatting

**Element Positioning**:

```swift
struct ScreenplayLayout {
    static let leftMargin: CGFloat = 108        // 1.5"
    static let rightMargin: CGFloat = 72        // 1"
    static let topMargin: CGFloat = 72          // 1"
    static let bottomMargin: CGFloat = 36       // 0.5"

    static let slugLineIndent: CGFloat = 108    // 1.5"
    static let actionIndent: CGFloat = 108      // 1.5"
    static let characterIndent: CGFloat = 266   // 3.7"
    static let parentheticalIndent: CGFloat = 223 // 3.1"
    static let dialogueIndent: CGFloat = 180    // 2.5"
    static let dialogueRightMargin: CGFloat = 144 // 2" from right

    static let lineHeight: CGFloat = 12         // Single space
}
```

#### Page Numbering

- Page numbers: Top right, 0.5" from top, 0.5" from right
- Format: "42."
- Title page: Not numbered
- First script page: "1."

#### Scene Numbers

```
7.  INT. COFFEE SHOP - DAY                    7.
```
- Left: After scene heading, 1.5" from left
- Right: At right margin

### 4. Text-to-Speech Integration

#### Option A: Apple Neural Voices (Primary)

**Framework**: AVFoundation

**Implementation**:

```swift
import AVFoundation

class AppleVoiceService: VoiceService {
    private let synthesizer = AVSpeechSynthesizer()

    func synthesize(
        text: String,
        settings: VoiceSettings
    ) async throws -> AVAudioBuffer {

        let utterance = AVSpeechUtterance(string: text)

        // Voice selection
        utterance.voice = AVSpeechSynthesisVoice(
            identifier: settings.voiceId
        )

        // Voice customization
        utterance.rate = settings.rate                    // 0.0 - 1.0
        utterance.pitchMultiplier = settings.pitch        // 0.5 - 2.0
        utterance.volume = settings.volume                // 0.0 - 1.0
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.2

        // Synthesize to buffer
        return try await withCheckedThrowingContinuation { continuation in
            let delegate = SynthesisDelegate { buffer in
                continuation.resume(returning: buffer)
            }
            synthesizer.delegate = delegate
            synthesizer.speak(utterance)
        }
    }

    func availableVoices() -> [VoiceOption] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.quality == .enhanced }
            .map { voice in
                VoiceOption(
                    id: voice.identifier,
                    name: voice.name,
                    language: voice.language,
                    gender: inferGender(voice.name)
                )
            }
    }
}
```

**Available Voices** (iOS 17+):
- English (US): Samantha, Alex, Ava, Nathan, Reed, etc.
- English (UK): Daniel, Kate, etc.
- Other languages: 50+ voices

**Quality Levels**:
- Default: Basic synthesis
- Enhanced: Neural voices (preferred)
- Premium: Highest quality (if available)

#### Option B: ElevenLabs API (Premium Feature)

**API Endpoint**: `https://api.elevenlabs.io/v1/text-to-speech`

**Authentication**: API Key (stored in Keychain)

**Implementation**:

```swift
class ElevenLabsService: VoiceService {
    private let apiKey: String
    private let baseURL = "https://api.elevenlabs.io/v1"

    func synthesize(
        text: String,
        settings: VoiceSettings
    ) async throws -> AVAudioBuffer {

        let request = ElevenLabsRequest(
            text: text,
            voiceId: settings.voiceId,
            modelId: "eleven_monolingual_v1",
            voiceSettings: ElevenLabsVoiceSettings(
                stability: 0.5,
                similarityBoost: 0.75
            )
        )

        let response = try await apiClient.post(
            "\(baseURL)/text-to-speech/\(settings.voiceId)",
            body: request,
            headers: ["xi-api-key": apiKey]
        )

        let audioData = response.data
        return try AVAudioBuffer(data: audioData, format: .mp3)
    }
}

struct ElevenLabsRequest: Codable {
    let text: String
    let voiceId: String
    let modelId: String
    let voiceSettings: ElevenLabsVoiceSettings
}

struct ElevenLabsVoiceSettings: Codable {
    let stability: Float          // 0.0 - 1.0
    let similarityBoost: Float    // 0.0 - 1.0
}
```

**Voice Library**:
- 50+ pre-made voices
- Custom voice cloning (premium)
- Multi-language support

**Pricing**:
- Free tier: 10,000 characters/month
- Creator: $5/month - 30,000 characters
- Pro: $22/month - 100,000 characters
- Included in app's Pro subscription

**Error Handling**:
```swift
enum VoiceSynthesisError: Error {
    case rateLimitExceeded
    case quotaExceeded
    case invalidVoice
    case networkError(Error)
}

func handleSynthesisError(_ error: Error) {
    switch error {
    case VoiceSynthesisError.quotaExceeded:
        // Fall back to Apple voices
        fallbackToAppleVoice()
    case VoiceSynthesisError.networkError:
        // Retry with exponential backoff
        retryWithBackoff()
    default:
        // Show error to user
        showError(error)
    }
}
```

### 5. AI Image Generation (Optional)

#### DALL-E 3 Integration

**API**: OpenAI DALL-E 3

**Endpoint**: `https://api.openai.com/v1/images/generations`

**Implementation**:

```swift
class DALLEImageService: ImageGenerationService {
    private let apiKey: String

    func generateImage(
        prompt: String,
        style: ImageStyle = .natural
    ) async throws -> UIImage {

        let request = DALLERequest(
            model: "dall-e-3",
            prompt: enhancePrompt(prompt, style: style),
            size: "1024x1792",  // Storyboard aspect ratio
            quality: "standard",
            n: 1
        )

        let response = try await apiClient.post(
            "https://api.openai.com/v1/images/generations",
            body: request,
            headers: ["Authorization": "Bearer \(apiKey)"]
        )

        let imageURL = response.data.first?.url
        let imageData = try await URLSession.shared.data(from: imageURL)
        return UIImage(data: imageData)!
    }

    private func enhancePrompt(_ prompt: String, style: ImageStyle) -> String {
        let stylePrefix = switch style {
        case .natural: "Photorealistic cinematic still: "
        case .sketch: "Black and white storyboard sketch: "
        case .comic: "Comic book style panel: "
        case .realistic: "Film still, professional cinematography: "
        }

        return stylePrefix + prompt + ", wide angle, film lighting"
    }
}

struct DALLERequest: Codable {
    let model: String
    let prompt: String
    let size: String
    let quality: String
    let n: Int
}
```

**Pricing** (as of 2025):
- Standard: $0.040 per image (1024×1024)
- HD: $0.080 per image

**Rate Limits**:
- 50 images per minute
- 5 concurrent requests

**Content Policy**:
- No copyrighted characters
- No violent/explicit content
- Filter prompts before submission

### 6. CloudKit Integration

**Purpose**: Project sync and collaboration

**Configuration**:

```swift
import CloudKit

class CloudKitService {
    let container = CKContainer(identifier: "iCloud.com.example.screenplayworkshop")
    let privateDatabase: CKDatabase
    let sharedDatabase: CKDatabase
    let publicDatabase: CKDatabase

    init() {
        privateDatabase = container.privateCloudDatabase
        sharedDatabase = container.sharedCloudDatabase
        publicDatabase = container.publicCloudDatabase
    }
}
```

#### Record Types

**Project Record**:
```swift
let projectRecord = CKRecord(recordType: "Project")
projectRecord["title"] = project.title as CKRecordValue
projectRecord["type"] = project.type.rawValue as CKRecordValue
projectRecord["createdAt"] = project.createdAt as CKRecordValue
projectRecord["modifiedAt"] = project.modifiedAt as CKRecordValue
projectRecord["data"] = try JSONEncoder().encode(project) as CKRecordValue
```

**Scene Record**:
```swift
let sceneRecord = CKRecord(recordType: "Scene")
sceneRecord["projectID"] = CKRecord.Reference(
    recordID: projectRecord.recordID,
    action: .deleteSelf
)
sceneRecord["sceneNumber"] = scene.sceneNumber as CKRecordValue
sceneRecord["data"] = try JSONEncoder().encode(scene) as CKRecordValue
```

#### Sync Strategy

**Upload**:
```swift
func syncProject(_ project: Project) async throws {
    let records = createRecords(from: project)

    let operation = CKModifyRecordsOperation(
        recordsToSave: records,
        recordIDsToDelete: nil
    )

    operation.savePolicy = .changedKeys  // Only sync changed fields
    operation.qualityOfService = .userInitiated

    try await privateDatabase.perform(operation)
}
```

**Download**:
```swift
func fetchChanges() async throws -> [Change] {
    let query = CKQuery(
        recordType: "Project",
        predicate: NSPredicate(
            format: "modifiedAt > %@",
            lastSyncDate as CVarArg
        )
    )

    let results = try await privateDatabase.records(matching: query)
    return results.map { convertToChange($0) }
}
```

#### Sharing

**Share Project**:
```swift
func shareProject(projectID: UUID, with emails: [String]) async throws {
    let projectRecord = try await fetchRecord(projectID)

    let share = CKShare(rootRecord: projectRecord)
    share[CKShare.SystemFieldKey.title] = "Screenplay Project" as CKRecordValue

    // Set permissions
    share.publicPermission = .none

    for email in emails {
        let participant = CKShare.Participant()
        participant.permission = .readWrite
        // Lookup user by email
        let userID = try await lookupUserID(email: email)
        participant.userIdentity = CKUserIdentity(userRecordID: userID)
        share.addParticipant(participant)
    }

    try await sharedDatabase.save(share)
}
```

### 7. 3D Model Import

**Supported Formats**:
- USDZ (primary)
- USD
- REALITY (Reality Composer)
- OBJ (converted to USDZ)
- FBX (converted to USDZ)

#### USDZ Import

```swift
import RealityKit

class ModelImporter {
    func importModel(from url: URL) async throws -> Entity {
        // Load USDZ
        let entity = try await Entity.load(contentsOf: url)

        // Validate
        guard entity.components.has(ModelComponent.self) else {
            throw ImportError.invalidModel
        }

        // Optimize
        optimizeModel(entity)

        return entity
    }

    private func optimizeModel(_ entity: Entity) {
        // Reduce polygon count if too high
        // Compress textures
        // Generate LODs
        // Add collision shapes
    }
}
```

#### Format Conversion (OBJ → USDZ)

```swift
import ModelIO

func convertOBJtoUSDZ(objURL: URL) throws -> URL {
    let asset = MDLAsset(url: objURL)

    // Optimize mesh
    let allocator = MTKMeshBufferAllocator(device: MTLCreateSystemDefaultDevice()!)
    let meshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]

    for mesh in meshes {
        mesh.addNormals(withAttributeNamed: MDLVertexAttributeNormal)
        mesh.addTangentBasis(
            forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
            tangentAttributeNamed: MDLVertexAttributeTangent,
            bitangentAttributeNamed: MDLVertexAttributeBitangent
        )
    }

    // Export as USDZ
    let usdzURL = objURL.deletingPathExtension().appendingPathExtension("usdz")
    try asset.export(to: usdzURL)

    return usdzURL
}
```

### 8. Movie Magic Scheduling Export

**Purpose**: Export scene data for production scheduling

**Format**: CSV

**Structure**:
```csv
Scene #,Int/Ext,Location,Time,Pages,Characters,Synopsis
1,INT,COFFEE SHOP,DAY,2.5,"ALEX, SARAH",Alex reveals secret
2,EXT,PARKING LOT,DAY,1.0,ALEX,Alex walks to car
```

**Implementation**:

```swift
func exportToMovieMagic(project: Project) throws -> URL {
    var csv = "Scene #,Int/Ext,Location,Time,Pages,Characters,Synopsis\n"

    for scene in project.scenes {
        let row = [
            "\(scene.sceneNumber)",
            scene.slugLine.setting.rawValue,
            "\"\(scene.slugLine.location)\"",
            scene.slugLine.timeOfDay.rawValue,
            "\(scene.pageLength)",
            "\"\(scene.characters.map { $0.name }.joined(separator: ", "))\"",
            "\"\(scene.metadata.summary ?? "")\""
        ].joined(separator: ",")

        csv += row + "\n"
    }

    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("\(project.title)_scenes.csv")
    try csv.write(to: url, atomically: true, encoding: .utf8)

    return url
}
```

## API Rate Limiting & Quotas

### Rate Limit Handler

```swift
actor RateLimiter {
    private var requests: [Date] = []
    private let maxRequests: Int
    private let timeWindow: TimeInterval

    init(maxRequests: Int, per timeWindow: TimeInterval) {
        self.maxRequests = maxRequests
        self.timeWindow = timeWindow
    }

    func checkAndWait() async throws {
        // Remove old requests outside time window
        let cutoff = Date().addingTimeInterval(-timeWindow)
        requests = requests.filter { $0 > cutoff }

        if requests.count >= maxRequests {
            // Calculate wait time
            let oldestRequest = requests.first!
            let waitTime = timeWindow - Date().timeIntervalSince(oldestRequest)
            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
        }

        requests.append(Date())
    }
}
```

### Quota Management

```swift
struct APIQuota {
    var used: Int
    var limit: Int
    var resetsAt: Date

    var remaining: Int { limit - used }
    var isExceeded: Bool { used >= limit }
}

actor QuotaManager {
    private var quotas: [String: APIQuota] = [:]

    func checkQuota(for service: String) throws {
        guard let quota = quotas[service], !quota.isExceeded else {
            throw APIError.quotaExceeded(service)
        }
    }

    func incrementUsage(for service: String, by amount: Int = 1) {
        quotas[service]?.used += amount
    }
}
```

## Error Handling & Retry Logic

### Retry Strategy

```swift
func retryWithExponentialBackoff<T>(
    maxAttempts: Int = 4,
    initialDelay: TimeInterval = 2.0,
    operation: () async throws -> T
) async throws -> T {

    var attempt = 0
    var delay = initialDelay

    while attempt < maxAttempts {
        do {
            return try await operation()
        } catch {
            attempt += 1

            if attempt >= maxAttempts {
                throw error
            }

            // Check if error is retryable
            guard isRetryable(error) else {
                throw error
            }

            // Wait with exponential backoff
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            delay *= 2
        }
    }

    fatalError("Unreachable")
}

func isRetryable(_ error: Error) -> Bool {
    if let urlError = error as? URLError {
        switch urlError.code {
        case .networkConnectionLost, .timedOut, .cannotConnectToHost:
            return true
        default:
            return false
        }
    }
    return false
}
```

## Security Best Practices

### API Key Management

```swift
import Security

class KeychainService {
    func storeAPIKey(_ key: String, for service: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: key.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func retrieveAPIKey(for service: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            throw KeychainError.retrieveFailed(status)
        }

        return key
    }
}
```

### Request Signing

```swift
func signRequest(_ request: URLRequest, with apiKey: String) -> URLRequest {
    var signedRequest = request
    let timestamp = Date().timeIntervalSince1970
    let signature = "\(apiKey):\(timestamp)".sha256Hash()

    signedRequest.setValue(signature, forHTTPHeaderField: "X-Signature")
    signedRequest.setValue("\(timestamp)", forHTTPHeaderField: "X-Timestamp")

    return signedRequest
}
```

---

**Document Version**: 1.0
**Last Updated**: 2025-11-24
**Author**: Integration Team
