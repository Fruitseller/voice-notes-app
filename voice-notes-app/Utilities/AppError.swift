//
//  AppError.swift
//  voice-notes-app
//

import Foundation

enum AppError: LocalizedError {
    case speechRecognitionNotAuthorized
    case microphoneNotAuthorized
    case transcriptionEmpty
    case processingFailed(Error)
    case modelUnavailable(String)
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .speechRecognitionNotAuthorized:
            return "Spracherkennung nicht erlaubt. Bitte in den Einstellungen aktivieren."
        case .microphoneNotAuthorized:
            return "Mikrofonzugriff nicht erlaubt. Bitte in den Einstellungen aktivieren."
        case .transcriptionEmpty:
            return "Keine Sprache erkannt. Bitte erneut versuchen."
        case .processingFailed(let error):
            return "Verarbeitung fehlgeschlagen: \(error.localizedDescription)"
        case .modelUnavailable(let reason):
            return "Sprachmodell nicht verfügbar: \(reason)"
        case .exportFailed:
            return "Export fehlgeschlagen."
        }
    }
}
