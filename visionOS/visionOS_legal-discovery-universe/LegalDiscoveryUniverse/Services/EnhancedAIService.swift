//
//  EnhancedAIService.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation
import NaturalLanguage

/// Enhanced AI service using NaturalLanguage framework
class EnhancedAIService: AIService {

    // MARK: - Relevance Analysis

    func analyzeRelevance(_ document: Document) async throws -> Double {
        let text = document.extractedText

        // Check if document is empty
        guard !text.isEmpty else { return 0.0 }

        var score: Double = 0.0

        // 1. Length score (longer documents might be more relevant)
        let wordCount = text.wordCount
        let lengthScore = min(Double(wordCount) / 1000.0, 1.0) * 0.2

        // 2. Legal term density
        let legalTermScore = calculateLegalTermDensity(text) * 0.3

        // 3. Entity presence
        let entityScore = await calculateEntityScore(text) * 0.3

        // 4. Keyword matching (if we have case keywords)
        let keywordScore = 0.2 // Placeholder

        score = lengthScore + legalTermScore + entityScore + keywordScore

        return min(max(score, 0.0), 1.0)
    }

    private func calculateLegalTermDensity(_ text: String) -> Double {
        let legalTerms = [
            "contract", "agreement", "plaintiff", "defendant",
            "lawsuit", "litigation", "evidence", "testimony",
            "affidavit", "deposition", "discovery", "trial",
            "settlement", "damages", "liability", "negligence",
            "breach", "clause", "provision", "statute"
        ]

        let lowercaseText = text.lowercased()
        var termCount = 0

        for term in legalTerms {
            termCount += lowercaseText.components(separatedBy: term).count - 1
        }

        let wordCount = text.wordCount
        guard wordCount > 0 else { return 0.0 }

        let density = Double(termCount) / Double(wordCount)
        return min(density * 10.0, 1.0) // Scale density
    }

    private func calculateEntityScore(_ text: String) async -> Double {
        let entities = await extractEntitiesInternal(text)
        let entityCount = entities.count

        // More entities typically means more relevant
        return min(Double(entityCount) / 20.0, 1.0)
    }

    // MARK: - Privilege Detection

    func detectPrivilege(_ document: Document) async throws -> PrivilegeStatus {
        let text = document.extractedText.lowercased()

        // Check for privilege markers
        let privilegeMarkers = AppConstants.privilegeKeywords

        var privilegeScore = 0.0

        for marker in privilegeMarkers {
            if text.contains(marker) {
                privilegeScore += 0.3
            }
        }

        // Check metadata
        if let metadata = document.metadata {
            // Check if from/to attorneys
            if let from = metadata.from?.lowercased(), isLikelyAttorney(from) {
                privilegeScore += 0.2
            }

            if let subject = metadata.subject?.lowercased(), subject.contains("privileged") {
                privilegeScore += 0.2
            }
        }

        // Determine privilege status based on score
        if privilegeScore >= 0.8 {
            return .attorneyClient
        } else if privilegeScore >= 0.5 {
            if text.contains("work product") {
                return .workProduct
            } else if text.contains("confidential") {
                return .confidential
            }
            return .contested // Unclear privilege status
        }

        return .notPrivileged
    }

    private func isLikelyAttorney(_ email: String) -> Bool {
        let attorneyIndicators = ["esq", "attorney", "lawyer", "counsel", "legal"]
        return attorneyIndicators.contains { email.contains($0) }
    }

    // MARK: - Entity Extraction

    func extractEntities(_ document: Document) async throws -> [Entity] {
        let entities = await extractEntitiesInternal(document.extractedText)
        return entities
    }

    private func extractEntitiesInternal(_ text: String) async -> [Entity] {
        var entities: [Entity] = []

        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text

        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag, tags.contains(tag) {
                let name = String(text[tokenRange])

                let entityType: EntityType = switch tag {
                case .personalName: .person
                case .placeName: .location
                case .organizationName: .organization
                default: .other
                }

                let entity = Entity(name: name, type: entityType)
                entities.append(entity)
            }

            return true
        }

        return entities
    }

    // MARK: - Relationship Discovery

    func findRelationships(between documents: [Document]) async throws -> [DocumentRelationship] {
        var relationships: [DocumentRelationship] = []

        // Find email threads
        let emailDocs = documents.filter { $0.fileType == .email }
        for i in 0..<emailDocs.count {
            for j in (i+1)..<emailDocs.count {
                if areRelatedEmails(emailDocs[i], emailDocs[j]) {
                    relationships.append(DocumentRelationship(
                        sourceId: emailDocs[i].id,
                        targetId: emailDocs[j].id,
                        type: .reply,
                        confidence: 0.9
                    ))
                }
            }
        }

        // Find similar documents
        for i in 0..<documents.count {
            for j in (i+1)..<documents.count {
                let similarity = await calculateSimilarity(documents[i], documents[j])
                if similarity > 0.7 {
                    relationships.append(DocumentRelationship(
                        sourceId: documents[i].id,
                        targetId: documents[j].id,
                        type: .similar,
                        confidence: similarity
                    ))
                }
            }
        }

        return relationships
    }

    private func areRelatedEmails(_ doc1: Document, _ doc2: Document) -> Bool {
        guard let meta1 = doc1.metadata, let meta2 = doc2.metadata else { return false }
        guard let subject1 = meta1.subject, let subject2 = meta2.subject else { return false }

        // Simple subject matching (could be more sophisticated)
        let normalized1 = subject1.replacingOccurrences(of: "Re: ", with: "").replacingOccurrences(of: "Fwd: ", with: "")
        let normalized2 = subject2.replacingOccurrences(of: "Re: ", with: "").replacingOccurrences(of: "Fwd: ", with: "")

        return normalized1.lowercased() == normalized2.lowercased()
    }

    private func calculateSimilarity(_ doc1: Document, _ doc2: Document) async -> Double {
        let text1 = doc1.extractedText
        let text2 = doc2.extractedText

        // Use NLEmbedding for semantic similarity
        guard let embedding = NLEmbedding.sentenceEmbedding(for: .english) else {
            return 0.0
        }

        // Get embeddings
        guard let vector1 = embedding.vector(for: text1.summary()),
              let vector2 = embedding.vector(for: text2.summary()) else {
            return 0.0
        }

        // Calculate cosine similarity
        var dotProduct: Double = 0.0
        var magnitude1: Double = 0.0
        var magnitude2: Double = 0.0

        for i in 0..<min(vector1.count, vector2.count) {
            dotProduct += Double(vector1[i]) * Double(vector2[i])
            magnitude1 += Double(vector1[i]) * Double(vector1[i])
            magnitude2 += Double(vector2[i]) * Double(vector2[i])
        }

        magnitude1 = sqrt(magnitude1)
        magnitude2 = sqrt(magnitude2)

        guard magnitude1 > 0 && magnitude2 > 0 else { return 0.0 }

        return dotProduct / (magnitude1 * magnitude2)
    }

    // MARK: - Insights Generation

    func generateInsights(for legalCase: LegalCase) async throws -> CaseInsights {
        var insights = CaseInsights(
            keyFindings: [],
            importantDocuments: [],
            criticalDates: [],
            riskAreas: [],
            suggestions: []
        )

        // Analyze documents
        let documents = legalCase.documents

        // Find key documents (high relevance)
        let keyDocs = documents.filter { $0.relevanceScore > AppConstants.highRelevanceThreshold }
        insights.importantDocuments = keyDocs.map { $0.id }

        // Extract critical dates
        var dates: [Date] = []
        for document in documents {
            if let docDate = document.documentDate {
                dates.append(docDate)
            }
        }
        insights.criticalDates = Array(Set(dates)).sorted()

        // Identify risk areas
        let privilegedDocs = documents.filter { $0.isPrivileged }
        if privilegedDocs.count > 0 {
            insights.riskAreas.append("Found \(privilegedDocs.count) privileged documents requiring special handling")
        }

        // Generate key findings
        if keyDocs.count > 0 {
            insights.keyFindings.append("Identified \(keyDocs.count) highly relevant documents")
        }

        let emailCount = documents.filter { $0.fileType == .email }.count
        if emailCount > 0 {
            insights.keyFindings.append("Case contains \(emailCount) email communications")
        }

        // Generate suggestions
        let unreviewed = documents.filter { !$0.isReviewed }.count
        if unreviewed > 0 {
            insights.suggestions.append("Review remaining \(unreviewed) documents")
        }

        if let timeline = legalCase.timelines.first, timeline.events.isEmpty {
            insights.suggestions.append("Create timeline of events for better case visualization")
        }

        return insights
    }

    // MARK: - Full Document Analysis

    func analyzeDocument(_ document: Document) async throws -> AIAnalysis {
        var analysis = AIAnalysis()

        // Extract text for analysis
        let text = document.extractedText

        // 1. Relevance scoring
        analysis.relevanceScore = try await analyzeRelevance(document)

        // 2. Privilege detection
        let privilegeStatus = try await detectPrivilege(document)
        analysis.privilegeConfidence = privilegeStatus != .notPrivileged ? 0.8 : 0.0

        // 3. Entity extraction
        let entities = await extractEntitiesInternal(text)
        analysis.entities = entities.map { $0.name }

        // 4. Key phrase extraction
        analysis.keyPhrases = extractKeyPhrases(text)

        // 5. Sentiment analysis
        analysis.sentiment = analyzeSentiment(text)

        // 6. Topic modeling
        analysis.topics = extractTopics(text)

        // 7. Language detection
        analysis.language = detectLanguage(text)

        // 8. Summary generation
        analysis.summary = text.summary(sentences: 3)

        // 9. Suggested tags
        analysis.suggestedTags = generateTags(from: analysis)

        analysis.analyzedDate = Date()
        analysis.modelVersion = "1.0-NaturalLanguage"

        return analysis
    }

    // MARK: - Helper Methods

    private func extractKeyPhrases(_ text: String) -> [String] {
        var phrases: [String] = []

        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text

        var currentPhrase: [String] = []

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
            let word = String(text[tokenRange])

            if tag == .noun || tag == .adjective {
                currentPhrase.append(word)
            } else {
                if currentPhrase.count >= 2 {
                    phrases.append(currentPhrase.joined(separator: " "))
                }
                currentPhrase = []
            }

            return true
        }

        // Return top phrases
        return Array(Set(phrases)).prefix(10).map { String($0) }
    }

    private func analyzeSentiment(_ text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text

        var totalSentiment: Double = 0.0
        var count = 0

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .paragraph, scheme: .sentimentScore) { tag, _ in
            if let tag = tag, let score = Double(tag.rawValue) {
                totalSentiment += score
                count += 1
            }
            return true
        }

        return count > 0 ? totalSentiment / Double(count) : 0.0
    }

    private func extractTopics(_ text: String) -> [String] {
        // Simple topic extraction based on frequent nouns
        var topics: [String] = []

        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text

        var nounCounts: [String: Int] = [:]

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
            if tag == .noun {
                let word = String(text[tokenRange]).lowercased()
                if word.count > 3 { // Filter short words
                    nounCounts[word, default: 0] += 1
                }
            }
            return true
        }

        // Get top nouns as topics
        let sorted = nounCounts.sorted { $0.value > $1.value }
        topics = sorted.prefix(5).map { $0.key.capitalized }

        return topics
    }

    private func detectLanguage(_ text: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)

        guard let language = recognizer.dominantLanguage else {
            return "en" // Default to English
        }

        return language.rawValue
    }

    private func generateTags(from analysis: AIAnalysis) -> [String] {
        var tags: [String] = []

        // Add relevance-based tag
        if analysis.relevanceScore > 0.9 {
            tags.append("Highly Relevant")
        } else if analysis.relevanceScore > 0.7 {
            tags.append("Relevant")
        }

        // Add sentiment-based tag
        if analysis.sentiment > 0.3 {
            tags.append("Positive Tone")
        } else if analysis.sentiment < -0.3 {
            tags.append("Negative Tone")
        }

        // Add topic-based tags
        tags.append(contentsOf: analysis.topics.prefix(3))

        return tags
    }
}
