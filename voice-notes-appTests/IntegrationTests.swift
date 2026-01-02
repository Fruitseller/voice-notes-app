//
//  IntegrationTests.swift
//  voice-notes-appTests
//

import Testing
import Foundation
import SwiftData
@testable import voice_notes_app

@MainActor
struct IntegrationTests {

    // MARK: - Helper

    private func makeTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: VoiceNote.self, configurations: config)
    }

    // MARK: - Tests

    @Test func saveAndLoadVoiceNote() throws {
        let container = try makeTestContainer()
        let context = container.mainContext

        // Create and save note
        let note = VoiceNote(
            originalTranscription: "Test original",
            correctedText: "Test corrected",
            summary: "Test summary"
        )
        context.insert(note)
        try context.save()

        // Fetch notes
        let descriptor = FetchDescriptor<VoiceNote>()
        let fetchedNotes = try context.fetch(descriptor)

        #expect(fetchedNotes.count == 1)
        #expect(fetchedNotes.first?.originalTranscription == "Test original")
        #expect(fetchedNotes.first?.correctedText == "Test corrected")
        #expect(fetchedNotes.first?.summary == "Test summary")
    }

    @Test func deleteVoiceNote() throws {
        let container = try makeTestContainer()
        let context = container.mainContext

        // Create and save note
        let note = VoiceNote(
            originalTranscription: "To be deleted",
            correctedText: "Corrected",
            summary: "Summary"
        )
        context.insert(note)
        try context.save()

        // Verify it exists
        let descriptorBefore = FetchDescriptor<VoiceNote>()
        let notesBefore = try context.fetch(descriptorBefore)
        #expect(notesBefore.count == 1)

        // Delete
        context.delete(note)
        try context.save()

        // Verify deletion
        let descriptorAfter = FetchDescriptor<VoiceNote>()
        let notesAfter = try context.fetch(descriptorAfter)
        #expect(notesAfter.count == 0)
    }

    @Test func saveMultipleVoiceNotes() throws {
        let container = try makeTestContainer()
        let context = container.mainContext

        // Create and save multiple notes
        for i in 1...5 {
            let note = VoiceNote(
                originalTranscription: "Original \(i)",
                correctedText: "Corrected \(i)",
                summary: "Summary \(i)"
            )
            context.insert(note)
        }
        try context.save()

        // Fetch all notes
        let descriptor = FetchDescriptor<VoiceNote>()
        let fetchedNotes = try context.fetch(descriptor)

        #expect(fetchedNotes.count == 5)
    }

    @Test func voiceNotesSortedByTimestamp() async throws {
        let container = try makeTestContainer()
        let context = container.mainContext

        // Create notes with slight time delay
        let note1 = VoiceNote(
            originalTranscription: "First",
            correctedText: "First corrected",
            summary: "First summary"
        )
        context.insert(note1)

        // Small delay to ensure different timestamps
        try await Task.sleep(nanoseconds: 10_000_000) // 10ms

        let note2 = VoiceNote(
            originalTranscription: "Second",
            correctedText: "Second corrected",
            summary: "Second summary"
        )
        context.insert(note2)
        try context.save()

        // Fetch sorted by timestamp descending (newest first)
        let descriptor = FetchDescriptor<VoiceNote>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let fetchedNotes = try context.fetch(descriptor)

        #expect(fetchedNotes.count == 2)
        #expect(fetchedNotes.first?.originalTranscription == "Second")
        #expect(fetchedNotes.last?.originalTranscription == "First")
    }
}
