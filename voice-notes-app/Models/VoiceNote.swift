//
//  VoiceNote.swift
//  voice-notes-app
//

import Foundation
import SwiftData

@Model
final class VoiceNote {
    var id: UUID = UUID()
    var timestamp: Date = Date.now
    var originalTranscription: String
    var correctedText: String
    var summary: String

    init(originalTranscription: String, correctedText: String, summary: String) {
        self.originalTranscription = originalTranscription
        self.correctedText = correctedText
        self.summary = summary
    }
}
