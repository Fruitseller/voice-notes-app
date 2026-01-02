//
//  VoiceNoteTests.swift
//  voice-notes-appTests
//

import Testing
import Foundation
@testable import voice_notes_app

struct VoiceNoteTests {

    @Test func voiceNoteCreation() {
        let note = VoiceNote(
            originalTranscription: "Test original transcription",
            correctedText: "Test corrected text",
            summary: "Test summary"
        )

        #expect(note.originalTranscription == "Test original transcription")
        #expect(note.correctedText == "Test corrected text")
        #expect(note.summary == "Test summary")
    }

    @Test func defaultValuesAreSet() {
        let beforeCreation = Date()

        let note = VoiceNote(
            originalTranscription: "Test",
            correctedText: "Test",
            summary: "Test"
        )

        let afterCreation = Date()

        // ID should be set
        #expect(note.id != UUID(uuidString: "00000000-0000-0000-0000-000000000000"))

        // Timestamp should be between before and after creation
        #expect(note.timestamp >= beforeCreation)
        #expect(note.timestamp <= afterCreation)
    }

    @Test func voiceNoteFieldsAreModifiable() {
        let note = VoiceNote(
            originalTranscription: "Original",
            correctedText: "Corrected",
            summary: "Summary"
        )

        note.correctedText = "Updated corrected"
        note.summary = "Updated summary"

        #expect(note.correctedText == "Updated corrected")
        #expect(note.summary == "Updated summary")
    }
}
