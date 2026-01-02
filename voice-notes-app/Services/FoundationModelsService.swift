//
//  FoundationModelsService.swift
//  voice-notes-app
//

import Foundation
import FoundationModels

@Observable
@MainActor
class FoundationModelsService {
    private var session: LanguageModelSession?

    // MARK: - Availability Check

    func checkAvailability() -> SystemLanguageModel.Availability {
        SystemLanguageModel.default.availability
    }

    // MARK: - Processing

    func processTranscription(_ text: String) async throws -> ProcessedNote {
        let session = try getOrCreateSession()
        let prompt = buildPrompt(for: text)

        let response = try await session.respond(to: prompt, generating: ProcessedNote.self)
        return response.content
    }

    func processTranscriptionStream(_ text: String) async throws -> AsyncThrowingStream<ProcessedNote.PartiallyGenerated, Error> {
        let session = try getOrCreateSession()
        let prompt = buildPrompt(for: text)

        let stream = session.streamResponse(to: prompt, generating: ProcessedNote.self)
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await snapshot in stream {
                        continuation.yield(snapshot.content)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Private Helpers

    private func getOrCreateSession() throws -> LanguageModelSession {
        if let session = session {
            return session
        }

        guard case .available = checkAvailability() else {
            throw FoundationModelsError.modelUnavailable
        }

        let newSession = LanguageModelSession()
        self.session = newSession
        return newSession
    }

    private func buildPrompt(for text: String) -> String {
        "Verarbeite die folgende deutsche Sprachnotiz:\n\n\(text)"
    }
}

// MARK: - Error Types

enum FoundationModelsError: LocalizedError {
    case modelUnavailable

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Das Sprachmodell ist nicht verfügbar."
        }
    }
}
