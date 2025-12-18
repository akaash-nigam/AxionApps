# API Integration Specifications

## Overview

Language Immersion Rooms integrates with multiple external services for AI conversations, speech processing, translations, and analytics. This document specifies all API integrations, request/response formats, error handling, and fallback strategies.

## API Services

### 1. LLM Service (OpenAI GPT-4)

**Purpose**: Power natural AI conversations with context-aware responses

**Primary Provider**: OpenAI GPT-4 Turbo
**Fallback**: Anthropic Claude 3 (optional)

#### Configuration

```swift
struct LLMConfig {
    let apiKey: String // Stored in Keychain
    let baseURL: URL = URL(string: "https://api.openai.com/v1")!
    let model: String = "gpt-4-turbo-preview"
    let maxTokens: Int = 500
    let temperature: Double = 0.7
    let timeout: TimeInterval = 10.0
}
```

#### Chat Completion Request

```swift
struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
    let max_tokens: Int
    let user: String? // User ID for abuse monitoring

    // Conversation parameters
    let top_p: Double = 1.0
    let frequency_penalty: Double = 0.0
    let presence_penalty: Double = 0.0
}

struct ChatMessage: Codable {
    let role: String // "system", "user", "assistant"
    let content: String
    let name: String? // Character name
}
```

**Example Request**:

```json
{
  "model": "gpt-4-turbo-preview",
  "messages": [
    {
      "role": "system",
      "content": "You are Maria, a friendly Spanish barista from Madrid. Respond naturally in Spanish at B1 level. Keep responses conversational and under 50 words."
    },
    {
      "role": "user",
      "content": "Hola, quisiera un café con leche, por favor."
    }
  ],
  "temperature": 0.7,
  "max_tokens": 150,
  "user": "user_12345"
}
```

#### Chat Completion Response

```json
{
  "id": "chatcmpl-123",
  "object": "chat.completion",
  "created": 1677652288,
  "model": "gpt-4-turbo-preview",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "¡Claro! Un café con leche. ¿Lo quieres grande o pequeño?"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 45,
    "completion_tokens": 15,
    "total_tokens": 60
  }
}
```

#### Streaming Support

```swift
// For real-time responses
struct StreamingRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let stream: Bool = true
}

// Response: Server-Sent Events (SSE)
// data: {"choices":[{"delta":{"content":"¡Cl"}}]}
// data: {"choices":[{"delta":{"content":"aro!"}}]}
// data: [DONE]
```

#### Error Responses

```json
{
  "error": {
    "message": "Rate limit exceeded",
    "type": "rate_limit_error",
    "code": "rate_limit_exceeded"
  }
}
```

#### Rate Limits & Cost Management

- **Rate Limit**: 10,000 requests/day (adjust by tier)
- **Token Limit**: 500 tokens per conversation turn
- **Cost Tracking**: Log tokens per request
- **Budget Alert**: Notify at 80% of monthly budget

**Cost Estimation**:
- GPT-4 Turbo: $0.01 per 1K input tokens, $0.03 per 1K output tokens
- Average conversation: 50 turns × 200 tokens = 10K tokens
- Cost per conversation: ~$0.20
- Monthly cost (10K users, 5 conversations/month): ~$10,000

---

### 2. Text-to-Speech Service (ElevenLabs)

**Purpose**: Generate natural-sounding speech with regional accents

**Primary Provider**: ElevenLabs
**Fallback**: Azure Speech Services

#### Configuration

```swift
struct TTSConfig {
    let apiKey: String
    let baseURL: URL = URL(string: "https://api.elevenlabs.io/v1")!
    let voiceStability: Double = 0.75
    let similarityBoost: Double = 0.75
    let timeout: TimeInterval = 30.0
}
```

#### Text-to-Speech Request

```http
POST /v1/text-to-speech/{voice_id}
Content-Type: application/json
xi-api-key: {api_key}

{
  "text": "¡Claro! Un café con leche. ¿Lo quieres grande o pequeño?",
  "model_id": "eleven_multilingual_v2",
  "voice_settings": {
    "stability": 0.75,
    "similarity_boost": 0.75,
    "style": 0.5,
    "use_speaker_boost": true
  }
}
```

#### Response

- **Content-Type**: `audio/mpeg`
- **Response**: Binary audio data (MP3)
- **Latency**: ~2-5 seconds for 20-word sentence

#### Voice Mapping

```swift
struct VoiceMapping {
    static let voices: [String: String] = [
        "maria_spanish_es": "EXAVITQu4vr4xnSDxMaL", // Spanish (Spain)
        "juan_spanish_mx": "pNInz6obpgDQGcFmaJgB", // Spanish (Mexico)
        "jean_french_fr": "TxGEqnHWrfWFTfGW9XjX", // French
        "yuki_japanese": "XB0fDUnXU5powFXDhCwa", // Japanese
        "hans_german": "pqHfZKP75CvOlQylNhV4"  // German
    ]
}
```

#### Caching Strategy

```swift
// Cache generated audio to reduce API calls
struct AudioCache {
    let cacheDirectory: URL
    let maxCacheSize: Int64 = 500_000_000 // 500MB

    func cacheKey(text: String, voiceID: String) -> String {
        // SHA256 hash of text + voiceID
        return "\(text.sha256())_\(voiceID)"
    }
}
```

---

### 3. Speech-to-Text Service (Apple Speech Framework + Azure Fallback)

**Purpose**: Transcribe user speech to text with language detection

**Primary**: Apple's on-device Speech Framework
**Fallback**: Azure Speech Services (for unsupported languages)

#### Apple Speech Framework

```swift
import Speech

class SpeechRecognizer {
    private let recognizer: SFSpeechRecognizer
    private let audioEngine = AVAudioEngine()

    func startRecognition(language: String) {
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: language)) else {
            // Fallback to Azure
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.taskHint = .dictation

        recognizer.recognitionTask(with: request) { result, error in
            // Handle transcription
        }
    }
}
```

#### Azure Speech-to-Text (Fallback)

```http
POST /speech/recognition/conversation/cognitiveservices/v1
Content-Type: audio/wav
Ocp-Apim-Subscription-Key: {subscription_key}

# Query Parameters:
?language=es-ES
&format=detailed
&profanity=masked
```

**Response**:

```json
{
  "RecognitionStatus": "Success",
  "DisplayText": "Hola, quisiera un café con leche.",
  "Offset": 0,
  "Duration": 25000000,
  "NBest": [
    {
      "Confidence": 0.95,
      "Lexical": "hola quisiera un cafe con leche",
      "ITN": "hola quisiera un café con leche",
      "MaskedITN": "hola quisiera un café con leche",
      "Display": "Hola, quisiera un café con leche."
    }
  ]
}
```

---

### 4. Translation Service (Internal Database + Google Translate Fallback)

**Purpose**: Translate words and phrases between languages

**Primary**: Internal translation database (100K+ words)
**Fallback**: Google Cloud Translation API

#### Internal Database Query

```swift
protocol TranslationService {
    func translate(
        _ text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> TranslationResult
}

struct TranslationResult {
    let translatedText: String
    let sourceLanguage: Language
    let targetLanguage: Language
    let confidence: Double
    let alternatives: [String]
}
```

#### Google Cloud Translation API (Fallback)

```http
POST /language/translate/v2
Content-Type: application/json

{
  "q": "table",
  "source": "en",
  "target": "es",
  "format": "text"
}
```

**Response**:

```json
{
  "data": {
    "translations": [
      {
        "translatedText": "mesa",
        "detectedSourceLanguage": "en"
      }
    ]
  }
}
```

---

### 5. Grammar Analysis Service (Custom NLP + LanguageTool)

**Purpose**: Detect grammar errors and provide corrections

**Primary**: Custom NLP using Apple's Natural Language framework
**Fallback**: LanguageTool API

#### Apple Natural Language Framework

```swift
import NaturalLanguage

class GrammarAnalyzer {
    func analyzeGrammar(text: String, language: String) -> [GrammarError] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text

        // Custom grammar rules per language
        return detectErrors(in: text, language: language)
    }
}
```

#### LanguageTool API (Fallback)

```http
POST /v2/check
Content-Type: application/x-www-form-urlencoded

text=Yo+va+al+parque&language=es
```

**Response**:

```json
{
  "matches": [
    {
      "message": "Possible agreement error: Use 'voy' instead of 'va'",
      "shortMessage": "Agreement error",
      "offset": 3,
      "length": 2,
      "replacements": [
        { "value": "voy" }
      ],
      "context": {
        "text": "Yo va al parque",
        "offset": 3,
        "length": 2
      },
      "rule": {
        "id": "VERB_AGREEMENT",
        "category": {
          "id": "GRAMMAR",
          "name": "Grammar"
        }
      }
    }
  ]
}
```

---

### 6. Analytics Service (Custom Backend)

**Purpose**: Track learning progress, usage analytics, and app health

#### Events Schema

```json
{
  "event_type": "conversation_completed",
  "timestamp": "2025-01-15T10:30:00Z",
  "user_id": "user_12345",
  "session_id": "session_abc",
  "properties": {
    "language": "es",
    "scenario_id": "cafe_order",
    "duration_seconds": 300,
    "message_count": 12,
    "grammar_errors": 3,
    "overall_score": 85.5
  }
}
```

#### Batch Upload

```http
POST /api/v1/events/batch
Content-Type: application/json
Authorization: Bearer {api_token}

{
  "events": [
    { /* event 1 */ },
    { /* event 2 */ },
    { /* event 3 */ }
  ]
}
```

---

## Error Handling

### Error Categories

```swift
enum APIError: Error {
    case networkError(URLError)
    case rateLimitExceeded(retryAfter: TimeInterval)
    case unauthorized
    case invalidResponse
    case serverError(statusCode: Int)
    case timeout
    case quotaExceeded
}
```

### Retry Strategy

```swift
struct RetryPolicy {
    let maxAttempts: Int = 3
    let baseDelay: TimeInterval = 1.0
    let maxDelay: TimeInterval = 32.0

    func shouldRetry(error: APIError, attempt: Int) -> Bool {
        switch error {
        case .networkError, .timeout, .serverError:
            return attempt < maxAttempts
        case .rateLimitExceeded:
            return true // Retry after delay
        case .unauthorized, .invalidResponse, .quotaExceeded:
            return false // Don't retry
        }
    }

    func retryDelay(for attempt: Int) -> TimeInterval {
        // Exponential backoff: 1s, 2s, 4s, 8s, ...
        let delay = baseDelay * pow(2.0, Double(attempt - 1))
        return min(delay, maxDelay)
    }
}
```

### Circuit Breaker Pattern

```swift
actor CircuitBreaker {
    enum State {
        case closed // Normal operation
        case open // Failing, reject requests
        case halfOpen // Testing if recovered
    }

    private var state: State = .closed
    private var failureCount: Int = 0
    private var lastFailureTime: Date?

    let failureThreshold: Int = 5
    let timeout: TimeInterval = 60.0

    func recordSuccess() {
        state = .closed
        failureCount = 0
    }

    func recordFailure() {
        failureCount += 1
        lastFailureTime = Date()

        if failureCount >= failureThreshold {
            state = .open
        }
    }

    func canAttempt() -> Bool {
        switch state {
        case .closed:
            return true
        case .open:
            // Check if timeout passed
            if let lastFailure = lastFailureTime,
               Date().timeIntervalSince(lastFailure) > timeout {
                state = .halfOpen
                return true
            }
            return false
        case .halfOpen:
            return true
        }
    }
}
```

---

## Rate Limiting

### Client-Side Rate Limiting

```swift
actor RateLimiter {
    private var tokens: Int
    private let maxTokens: Int
    private let refillRate: TimeInterval // Seconds per token
    private var lastRefill: Date

    init(maxTokens: Int, refillRate: TimeInterval) {
        self.maxTokens = maxTokens
        self.tokens = maxTokens
        self.refillRate = refillRate
        self.lastRefill = Date()
    }

    func acquire() async throws {
        refillTokens()

        if tokens > 0 {
            tokens -= 1
        } else {
            // Wait for next token
            try await Task.sleep(nanoseconds: UInt64(refillRate * 1_000_000_000))
            tokens -= 1
        }
    }

    private func refillTokens() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastRefill)
        let newTokens = Int(elapsed / refillRate)

        if newTokens > 0 {
            tokens = min(tokens + newTokens, maxTokens)
            lastRefill = now
        }
    }
}
```

---

## API Keys Management

### Secure Storage

```swift
import Security

class KeychainManager {
    func storeAPIKey(_ key: String, for service: String) throws {
        let data = key.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unableToStore
        }
    }

    func retrieveAPIKey(for service: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            throw KeychainError.notFound
        }

        return key
    }
}
```

### Environment Configuration

```swift
enum Environment {
    case development
    case staging
    case production

    var openAIKey: String {
        switch self {
        case .development:
            return ProcessInfo.processInfo.environment["OPENAI_DEV_KEY"] ?? ""
        case .staging:
            return ProcessInfo.processInfo.environment["OPENAI_STAGING_KEY"] ?? ""
        case .production:
            // Retrieved from Keychain in production
            return try! KeychainManager().retrieveAPIKey(for: "OpenAI")
        }
    }
}
```

---

## Caching Strategy

### HTTP Caching

```swift
let cache = URLCache(
    memoryCapacity: 50_000_000, // 50MB
    diskCapacity: 200_000_000,  // 200MB
    directory: nil
)

URLSession.shared.configuration.urlCache = cache
URLSession.shared.configuration.requestCachePolicy = .returnCacheDataElseLoad
```

### Response Caching

```swift
// Cache translations for 7 days
// Cache audio files for 30 days
// Cache API responses based on Cache-Control headers
```

---

## Monitoring & Logging

### API Call Logging

```swift
struct APILog {
    let timestamp: Date
    let endpoint: String
    let method: String
    let statusCode: Int
    let duration: TimeInterval
    let error: Error?

    func send() {
        // Send to analytics service
    }
}
```

### Performance Metrics

- **95th percentile response time** < 2 seconds
- **Error rate** < 1%
- **Availability** > 99.5%

---

## Offline Mode

### Cached Responses
- Store last 100 conversation messages
- Cache translations for learned vocabulary
- Pre-download audio for common phrases

### Offline Capabilities
- Object labeling: ✅ (local database)
- Conversations: ❌ (requires LLM API)
- Pronunciation: ✅ (local analysis)
- Grammar checking: ⚠️ (basic rules only)

### Sync Strategy
- Queue failed API calls
- Retry when network available
- Merge conflicts: last-write-wins
