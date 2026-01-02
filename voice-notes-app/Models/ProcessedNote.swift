//
//  ProcessedNote.swift
//  voice-notes-app
//

import FoundationModels

@Generable
struct ProcessedNote {
    @Guide(description: "Der korrigierte deutsche Text einer Sprachaufnahme. Entferne Füllwörter wie 'ähm', 'also', 'halt' oder ähnliche Ausdrücke die beim Aufsprechen entstehen können. Korrigiere Grammatikfehler. Behalte den Inhalt bei.")
    var correctedText: String

    @Guide(description: "Eine prägnante Zusammenfassung des Inhalts in 1-2 Sätzen auf Deutsch. Verzichte auf Ausdrücke wie 'Der Benutzer beschreibt...'")
    var summary: String
}
