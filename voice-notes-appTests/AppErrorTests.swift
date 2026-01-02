//
//  AppErrorTests.swift
//  voice-notes-appTests
//

import Testing
import Foundation
@testable import voice_notes_app

struct AppErrorTests {

    @Test func speechRecognitionNotAuthorizedHasDescription() {
        let error = AppError.speechRecognitionNotAuthorized

        #expect(error.errorDescription != nil)
        #expect(!error.errorDescription!.isEmpty)
        #expect(error.errorDescription!.contains("Spracherkennung"))
    }

    @Test func microphoneNotAuthorizedHasDescription() {
        let error = AppError.microphoneNotAuthorized

        #expect(error.errorDescription != nil)
        #expect(!error.errorDescription!.isEmpty)
        #expect(error.errorDescription!.contains("Mikrofon"))
    }

    @Test func transcriptionEmptyHasDescription() {
        let error = AppError.transcriptionEmpty

        #expect(error.errorDescription != nil)
        #expect(!error.errorDescription!.isEmpty)
        #expect(error.errorDescription!.contains("Sprache"))
    }

    @Test func processingFailedHasDescription() {
        let underlyingError = NSError(domain: "TestDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let error = AppError.processingFailed(underlyingError)

        #expect(error.errorDescription != nil)
        #expect(!error.errorDescription!.isEmpty)
        #expect(error.errorDescription!.contains("Verarbeitung"))
    }

    @Test func modelUnavailableHasDescription() {
        let error = AppError.modelUnavailable("Test reason")

        #expect(error.errorDescription != nil)
        #expect(!error.errorDescription!.isEmpty)
        #expect(error.errorDescription!.contains("Sprachmodell"))
        #expect(error.errorDescription!.contains("Test reason"))
    }

    @Test func exportFailedHasDescription() {
        let error = AppError.exportFailed

        #expect(error.errorDescription != nil)
        #expect(!error.errorDescription!.isEmpty)
        #expect(error.errorDescription!.contains("Export"))
    }

    @Test func allErrorCasesHaveNonEmptyDescription() {
        let errors: [AppError] = [
            .speechRecognitionNotAuthorized,
            .microphoneNotAuthorized,
            .transcriptionEmpty,
            .processingFailed(NSError(domain: "", code: 0)),
            .modelUnavailable("reason"),
            .exportFailed
        ]

        for error in errors {
            #expect(error.errorDescription != nil, "Error \(error) should have a description")
            #expect(!error.errorDescription!.isEmpty, "Error \(error) should have non-empty description")
        }
    }
}
