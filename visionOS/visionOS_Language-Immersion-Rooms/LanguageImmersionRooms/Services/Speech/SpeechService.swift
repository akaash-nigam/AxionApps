//
//  SpeechService.swift
//  Language Immersion Rooms
//
//  Speech recognition and text-to-speech service
//

import Foundation
import Speech
import AVFoundation

class SpeechService: NSObject, SpeechServiceProtocol {
    // Speech Recognition
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // Text-to-Speech
    private let synthesizer = AVSpeechSynthesizer()

    // State
    private var isRecognizing = false
    private var recognitionContinuation: CheckedContinuation<String, Error>?

    override init() {
        // Initialize with Spanish for MVP
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
        super.init()

        synthesizer.delegate = self

        print("🎤 SpeechService initialized")
    }

    // MARK: - Speech Recognition

    func startRecognition(language: Language) async throws -> String {
        // Request authorization
        guard await requestAuthorization() else {
            throw ServiceError.speechRecognitionFailed
        }

        // Start recognition
        return try await withCheckedThrowingContinuation { continuation in
            self.recognitionContinuation = continuation
            Task {
                do {
                    try await self.startRecognitionInternal(language: language)
                } catch {
                    continuation.resume(throwing: error)
                    self.recognitionContinuation = nil
                }
            }
        }
    }

    private func startRecognitionInternal(language: Language) async throws {
        // Cancel previous task if any
        recognitionTask?.cancel()
        recognitionTask = nil

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw ServiceError.speechRecognitionFailed
        }

        recognitionRequest.shouldReportPartialResults = true

        // Get input node
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Install tap
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()

        isRecognizing = true

        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let transcription = result.bestTranscription.formattedString

                // If final result
                if result.isFinal {
                    print("🎤 Final transcription: \(transcription)")
                    self.recognitionContinuation?.resume(returning: transcription)
                    self.recognitionContinuation = nil
                    self.stopRecognition()
                }
            }

            if let error = error {
                print("❌ Recognition error: \(error)")
                self.recognitionContinuation?.resume(throwing: error)
                self.recognitionContinuation = nil
                self.stopRecognition()
            }
        }

        print("🎤 Started listening...")
    }

    func stopRecognition() {
        guard isRecognizing else { return }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecognizing = false

        print("🎤 Stopped listening")
    }

    private func requestAuthorization() async -> Bool {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    // MARK: - Text-to-Speech

    func speak(_ text: String, voice: String) async {
        let utterance = AVSpeechUtterance(string: text)

        // Configure voice
        // For MVP, use system Spanish voice
        utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
        utterance.rate = 0.5 // Slower for language learners
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        print("🔊 Speaking: \(text)")

        await withCheckedContinuation { continuation in
            // Store continuation to resume when done
            speechCompletionContinuation = continuation
            synthesizer.speak(utterance)
        }
    }

    private var speechCompletionContinuation: CheckedContinuation<Void, Never>?

    func playPronunciation(word: String, language: Language) async {
        await speak(word, voice: "es-ES")
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("🔊 Finished speaking")
        speechCompletionContinuation?.resume()
        speechCompletionContinuation = nil
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("🔊 Started speaking")
    }
}
