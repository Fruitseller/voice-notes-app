//
//  ProcessedNote.swift
//  voice-notes-app
//

import FoundationModels

@Generable
struct ProcessedNote {
    @Guide(description: "Der korrigierte deutsche Text. Entferne Füllwörter wie 'ähm', 'also', 'halt'. Korrigiere Grammatikfehler. Behalte den Inhalt bei.")
    var correctedText: String

    @Guide(description: "Eine prägnante Zusammenfassung des Inhalts in 1-2 Sätzen auf Deutsch.")
    var summary: String
}
