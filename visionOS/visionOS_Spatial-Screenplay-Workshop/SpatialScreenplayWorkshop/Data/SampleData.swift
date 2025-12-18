//
//  SampleData.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation
import SwiftData

/// Helper for generating sample data for testing and previews
@MainActor
struct SampleData {
    /// Create a complete sample project with scenes and characters
    static func createSampleProject(in context: ModelContext) throws {
        // Create project
        let project = Project(
            title: "The Writer's Dilemma",
            logline: "A struggling writer discovers their stories come to life, but with dangerous consequences.",
            type: .featureFilm,
            author: "Jane Doe",
            metadata: ProjectMetadata(
                genre: "Thriller/Drama",
                targetPageCount: 110,
                status: .firstDraft,
                tags: ["thriller", "drama", "metafiction"]
            )
        )
        context.insert(project)

        // Create characters
        let alex = Character(
            name: "ALEX CHEN",
            age: 28,
            gender: "Non-binary",
            characterDescription: "A struggling writer with a secret. Introverted but passionate about storytelling.",
            metadata: CharacterMetadata(role: .protagonist)
        )

        let sarah = Character(
            name: "SARAH MARTINEZ",
            age: 32,
            gender: "Female",
            characterDescription: "Alex's best friend and confidant. Works as a librarian.",
            metadata: CharacterMetadata(role: .supporting)
        )

        let detective = Character(
            name: "DETECTIVE MORGAN",
            age: 45,
            gender: "Male",
            characterDescription: "Hardened detective investigating strange occurrences.",
            metadata: CharacterMetadata(role: .antagonist)
        )

        context.insert(alex)
        context.insert(sarah)
        context.insert(detective)

        // Create scenes
        let scenes = createSampleScenes(characters: [alex, sarah, detective])
        for scene in scenes {
            scene.project = project
            context.insert(scene)
        }

        project.updateMetadata()
        try context.save()
    }

    /// Create sample scenes
    private static func createSampleScenes(characters: [Character]) -> [Scene] {
        let alex = characters[0]
        let sarah = characters[1]
        let detective = characters[2]

        return [
            // Scene 1: Opening - Coffee Shop
            Scene(
                sceneNumber: 1,
                slugLine: SlugLine(setting: .INT, location: "COFFEE SHOP", timeOfDay: .morning),
                content: SceneContent(elements: [
                    .action(ActionElement(
                        text: "ALEX CHEN (28, non-binary, haunted eyes) sits across from SARAH MARTINEZ (32, warm smile). Morning light streams through windows. Coffee cups between them.",
                        isCharacterIntro: true
                    )),
                    .dialogue(DialogueElement(
                        characterName: "ALEX",
                        parenthetical: "hesitant",
                        lines: ["I need to tell you something.", "Something... impossible."]
                    )),
                    .action(ActionElement(
                        text: "Sarah leans forward, concerned."
                    )),
                    .dialogue(DialogueElement(
                        characterName: "SARAH",
                        lines: ["What is it? You're scaring me."]
                    )),
                    .dialogue(DialogueElement(
                        characterName: "ALEX",
                        lines: ["My stories. The ones I write...", "They're coming true."]
                    ))
                ]),
                pageLength: 2.5,
                status: .locked,
                position: ScenePosition(act: 1, spatialPosition: SpatialCoordinates(x: -1.8, y: 1.4, z: -2.0)),
                metadata: SceneMetadata(
                    summary: "Alex reveals to Sarah that their stories are manifesting in reality",
                    mood: "Tense, intimate",
                    importance: .critical
                )
            ),

            // Scene 2: Flashback - Writing at Night
            Scene(
                sceneNumber: 2,
                slugLine: SlugLine(setting: .INT, location: "ALEX'S APARTMENT", timeOfDay: .night),
                content: SceneContent(elements: [
                    .transition(TransitionElement(type: .dissolve)),
                    .action(ActionElement(
                        text: "FLASHBACK - ONE WEEK EARLIER\n\nAlex types furiously on laptop. Empty coffee cups litter the desk. City lights glow through the window."
                    )),
                    .dialogue(DialogueElement(
                        characterName: "ALEX",
                        parenthetical: "reading aloud",
                        lines: ["\"The detective entered the alley, gun drawn. He had no idea what awaited him in the shadows.\""]
                    )),
                    .action(ActionElement(
                        text: "Alex pauses, stares at the screen. Something feels different this time."
                    ))
                ]),
                pageLength: 1.0,
                status: .revised,
                position: ScenePosition(act: 1, spatialPosition: SpatialCoordinates(x: -1.2, y: 1.4, z: -2.0)),
                metadata: SceneMetadata(
                    summary: "Flashback showing Alex writing the story that will come true",
                    mood: "Focused, late-night creativity",
                    importance: .important
                )
            ),

            // Scene 3: News Report
            Scene(
                sceneNumber: 3,
                slugLine: SlugLine(setting: .INT, location: "ALEX'S APARTMENT", timeOfDay: .morning),
                content: SceneContent(elements: [
                    .action(ActionElement(
                        text: "Alex wakes on the couch. Laptop still open. Morning news plays on TV."
                    )),
                    .dialogue(DialogueElement(
                        characterName: "NEWS ANCHOR (V.O.)",
                        lines: ["Breaking news: A detective was found unconscious in an alley downtown last night..."]
                    )),
                    .action(ActionElement(
                        text: "Alex's eyes widen. They grab the laptop, scroll to last night's writing. Word for word."
                    )),
                    .dialogue(DialogueElement(
                        characterName: "ALEX",
                        parenthetical: "whispered",
                        lines: ["No. No, no, no..."]
                    ))
                ]),
                pageLength: 1.5,
                status: .locked,
                position: ScenePosition(act: 1, spatialPosition: SpatialCoordinates(x: -0.6, y: 1.4, z: -2.0)),
                metadata: SceneMetadata(
                    summary: "Alex discovers their story came true",
                    mood: "Shocking realization",
                    importance: .critical
                )
            ),

            // Scene 4: Back to Coffee Shop
            Scene(
                sceneNumber: 4,
                slugLine: SlugLine(setting: .INT, location: "COFFEE SHOP", timeOfDay: .morning),
                content: SceneContent(elements: [
                    .transition(TransitionElement(type: .cutTo)),
                    .action(ActionElement(
                        text: "BACK TO PRESENT\n\nSarah stares at Alex, processing."
                    )),
                    .dialogue(DialogueElement(
                        characterName: "SARAH",
                        lines: ["That's... Alex, that's impossible."]
                    )),
                    .dialogue(DialogueElement(
                        characterName: "ALEX",
                        lines: ["I know how it sounds. But I can prove it."]
                    )),
                    .action(ActionElement(
                        text: "Alex pulls out a notebook, slides it across the table."
                    ))
                ]),
                pageLength: 1.0,
                status: .revised,
                position: ScenePosition(act: 1, spatialPosition: SpatialCoordinates(x: 0, y: 1.4, z: -2.0)),
                metadata: SceneMetadata(
                    summary: "Sarah struggles to believe Alex's claim",
                    mood: "Disbelief, tension",
                    importance: .important
                )
            ),

            // Scene 5: Detective Arrives
            Scene(
                sceneNumber: 5,
                slugLine: SlugLine(setting: .INT, location: "COFFEE SHOP", timeOfDay: .morning),
                content: SceneContent(elements: [
                    .action(ActionElement(
                        text: "The bell above the door CHIMES. DETECTIVE MORGAN (45, weathered face, sharp eyes) enters. He scans the room, spots Alex."
                    )),
                    .dialogue(DialogueElement(
                        characterName: "DETECTIVE MORGAN",
                        lines: ["Alex Chen?"]
                    )),
                    .action(ActionElement(
                        text: "Alex freezes. Sarah looks between them."
                    )),
                    .dialogue(DialogueElement(
                        characterName: "ALEX",
                        parenthetical: "nervous",
                        lines: ["Yes?"]
                    )),
                    .dialogue(DialogueElement(
                        characterName: "DETECTIVE MORGAN",
                        lines: ["We need to talk.", "About your stories."]
                    ))
                ]),
                pageLength: 1.5,
                status: .draft,
                position: ScenePosition(act: 1, spatialPosition: SpatialCoordinates(x: 0.6, y: 1.4, z: -2.0)),
                metadata: SceneMetadata(
                    summary: "Detective Morgan confronts Alex about the connection to recent events",
                    mood: "Suspenseful, threatening",
                    importance: .critical
                )
            )
        ]
    }

    /// Create minimal sample project
    static func createMinimalProject(in context: ModelContext) throws {
        let project = Project(
            title: "Untitled Project",
            type: .featureFilm,
            author: "New Writer"
        )
        context.insert(project)

        let scene = Scene.blank(number: 1, act: 1)
        scene.project = project
        context.insert(scene)

        project.updateMetadata()
        try context.save()
    }

    /// Populate with multiple sample projects
    static func populateWithSamples(in context: ModelContext) throws {
        try createSampleProject(in: context)

        // Add a few more projects
        let featureProject = Project.blank(
            title: "Summer Road Trip",
            type: .featureFilm,
            author: "Alex Johnson"
        )
        featureProject.metadata.status = .outline
        context.insert(featureProject)

        let tvProject = Project.blank(
            title: "The Last Detective",
            type: .tvPilotOneHour,
            author: "Sarah Williams"
        )
        tvProject.metadata.status = .firstDraft
        context.insert(tvProject)

        let shortProject = Project.blank(
            title: "Coffee Break",
            type: .shortFilm,
            author: "Mike Chen"
        )
        shortProject.metadata.status = .locked
        context.insert(shortProject)

        try context.save()
    }
}
