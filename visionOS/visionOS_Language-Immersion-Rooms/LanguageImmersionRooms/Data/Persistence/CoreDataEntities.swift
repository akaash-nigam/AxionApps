//
//  CoreDataEntities.swift
//  Language Immersion Rooms
//
//  CoreData entity definitions (NSManagedObject subclasses)
//

import CoreData
import Foundation

// MARK: - User Entity

@objc(UserEntity)
public class UserEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var username: String
    @NSManaged public var email: String
    @NSManaged public var createdAt: Date
    @NSManaged public var nativeLanguageCode: String
    @NSManaged public var targetLanguageCode: String
    @NSManaged public var currentStreak: Int32
    @NSManaged public var longestStreak: Int32
    @NSManaged public var totalStudyMinutes: Int64
    @NSManaged public var wordsEncounteredToday: Int32
    @NSManaged public var lastActiveDate: Date

    // Relationships
    @NSManaged public var vocabularyWords: Set<VocabularyEntity>
    @NSManaged public var conversations: Set<ConversationEntity>
}

extension UserEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    func toModel() -> UserProfile {
        return UserProfile(
            id: id,
            username: username,
            email: email,
            nativeLanguage: Language(rawValue: nativeLanguageCode) ?? .english,
            targetLanguage: Language(rawValue: targetLanguageCode) ?? .spanish
        )
    }

    func update(from profile: UserProfile) {
        self.id = profile.id
        self.username = profile.username
        self.email = profile.email
        self.nativeLanguageCode = profile.nativeLanguage.rawValue
        self.targetLanguageCode = profile.targetLanguage.rawValue
        self.createdAt = profile.createdAt
    }
}

// MARK: - Vocabulary Entity

@objc(VocabularyEntity)
public class VocabularyEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var word: String
    @NSManaged public var translation: String
    @NSManaged public var languageCode: String
    @NSManaged public var category: String
    @NSManaged public var audioURL: String?
    @NSManaged public var encounterCount: Int32
    @NSManaged public var lastEncountered: Date?
    @NSManaged public var isMastered: Bool

    // Relationship
    @NSManaged public var user: UserEntity?
}

extension VocabularyEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<VocabularyEntity> {
        return NSFetchRequest<VocabularyEntity>(entityName: "VocabularyEntity")
    }

    func toModel() -> VocabularyWord {
        return VocabularyWord(
            id: id,
            word: word,
            translation: translation,
            language: Language(rawValue: languageCode) ?? .spanish,
            category: category,
            audioURL: audioURL
        )
    }

    func update(from word: VocabularyWord) {
        self.id = word.id
        self.word = word.word
        self.translation = word.translation
        self.languageCode = word.language.rawValue
        self.category = word.category
        self.audioURL = word.audioURL
    }
}

// MARK: - Conversation Entity

@objc(ConversationEntity)
public class ConversationEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var characterID: String
    @NSManaged public var languageCode: String
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date?
    @NSManaged public var duration: Double
    @NSManaged public var messageCount: Int32
    @NSManaged public var messagesJSON: String? // JSON serialized messages

    // Relationship
    @NSManaged public var user: UserEntity?
}

extension ConversationEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConversationEntity> {
        return NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
    }

    func getMessages() -> [ConversationMessage] {
        guard let json = messagesJSON,
              let data = json.data(using: .utf8) else {
            return []
        }

        do {
            return try JSONDecoder().decode([ConversationMessage].self, from: data)
        } catch {
            print("❌ Failed to decode messages: \(error)")
            return []
        }
    }

    func setMessages(_ messages: [ConversationMessage]) {
        do {
            let data = try JSONEncoder().encode(messages)
            messagesJSON = String(data: data, encoding: .utf8)
            messageCount = Int32(messages.count)
        } catch {
            print("❌ Failed to encode messages: \(error)")
        }
    }
}

// MARK: - Learning Session Entity

@objc(SessionEntity)
public class SessionEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var languageCode: String
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date?
    @NSManaged public var wordsEncountered: Int32
    @NSManaged public var conversationCount: Int32

    // Relationship
    @NSManaged public var user: UserEntity?
}

extension SessionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionEntity> {
        return NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
    }

    func toModel() -> LearningSession {
        return LearningSession(
            id: id,
            language: Language(rawValue: languageCode) ?? .spanish,
            startTime: startTime
        )
    }
}

// MARK: - CoreData Model Configuration

/*
 To create the actual .xcdatamodeld file in Xcode:

 1. File > New > File > Data Model
 2. Name it "LanguageImmersionRooms.xcdatamodeld"

 3. Add Entities:
    - UserEntity
      - id: UUID
      - username: String
      - email: String
      - createdAt: Date
      - nativeLanguageCode: String
      - targetLanguageCode: String
      - currentStreak: Integer 32
      - longestStreak: Integer 32
      - totalStudyMinutes: Integer 64
      - wordsEncounteredToday: Integer 32
      - lastActiveDate: Date
      - Relationships: vocabularyWords (to VocabularyEntity, one-to-many)
      - Relationships: conversations (to ConversationEntity, one-to-many)

    - VocabularyEntity
      - id: UUID
      - word: String
      - translation: String
      - languageCode: String
      - category: String
      - audioURL: String (optional)
      - encounterCount: Integer 32
      - lastEncountered: Date (optional)
      - isMastered: Boolean
      - Relationships: user (to UserEntity, inverse: vocabularyWords)

    - ConversationEntity
      - id: UUID
      - characterID: String
      - languageCode: String
      - startTime: Date
      - endTime: Date (optional)
      - duration: Double
      - messageCount: Integer 32
      - messagesJSON: String (optional)
      - Relationships: user (to UserEntity, inverse: conversations)

    - SessionEntity
      - id: UUID
      - languageCode: String
      - startTime: Date
      - endTime: Date (optional)
      - wordsEncountered: Integer 32
      - conversationCount: Integer 32
      - Relationships: user (to UserEntity)

 4. Configure each entity:
    - Class: Set to the class name (e.g., "UserEntity")
    - Module: Current Product Module
    - Codegen: Manual/None (since we're defining classes manually)
 */
