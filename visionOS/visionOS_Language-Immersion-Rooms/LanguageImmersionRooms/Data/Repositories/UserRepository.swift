//
//  UserRepository.swift
//  Language Immersion Rooms
//
//  User data repository
//

import CoreData
import Foundation

class UserRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    // MARK: - Create

    func createUser(_ profile: UserProfile) throws {
        let entity = UserEntity(context: context)
        entity.update(from: profile)
        entity.createdAt = Date()
        entity.currentStreak = 0
        entity.longestStreak = 0
        entity.totalStudyMinutes = 0
        entity.wordsEncounteredToday = 0
        entity.lastActiveDate = Date()

        try context.save()
        print("💾 User created: \(profile.username)")
    }

    // MARK: - Read

    func getUser(byID id: UUID) -> UserProfile? {
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            let entities = try context.fetch(request)
            return entities.first?.toModel()
        } catch {
            print("❌ Fetch user error: \(error)")
            return nil
        }
    }

    func getCurrentUser() -> UserProfile? {
        let request = UserEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.fetchLimit = 1

        do {
            let entities = try context.fetch(request)
            return entities.first?.toModel()
        } catch {
            print("❌ Fetch current user error: \(error)")
            return nil
        }
    }

    // MARK: - Update

    func updateUser(_ profile: UserProfile) throws {
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", profile.id as CVarArg)
        request.fetchLimit = 1

        let entities = try context.fetch(request)
        if let entity = entities.first {
            entity.update(from: profile)
            try context.save()
            print("💾 User updated: \(profile.username)")
        }
    }

    func updateProgress(userID: UUID, wordsEncountered: Int, studyMinutes: Int, currentStreak: Int) throws {
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", userID as CVarArg)
        request.fetchLimit = 1

        let entities = try context.fetch(request)
        if let entity = entities.first {
            entity.wordsEncounteredToday = Int32(wordsEncountered)
            entity.totalStudyMinutes = Int64(studyMinutes)
            entity.currentStreak = Int32(currentStreak)
            entity.lastActiveDate = Date()

            if currentStreak > entity.longestStreak {
                entity.longestStreak = Int32(currentStreak)
            }

            try context.save()
            print("💾 Progress updated for user")
        }
    }

    // MARK: - Delete

    func deleteUser(byID id: UUID) throws {
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        let entities = try context.fetch(request)
        for entity in entities {
            context.delete(entity)
        }

        try context.save()
        print("💾 User deleted")
    }

    // MARK: - Stats

    func getUserStats(userID: UUID) -> (wordsToday: Int, totalMinutes: Int, streak: Int)? {
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", userID as CVarArg)
        request.fetchLimit = 1

        do {
            if let entity = try context.fetch(request).first {
                return (
                    wordsToday: Int(entity.wordsEncounteredToday),
                    totalMinutes: Int(entity.totalStudyMinutes),
                    streak: Int(entity.currentStreak)
                )
            }
        } catch {
            print("❌ Fetch stats error: \(error)")
        }

        return nil
    }
}
