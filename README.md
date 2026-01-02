# Sprachnotizen App

Eine iOS-App für Sprachnotizen mit automatischer Transkription, KI-gestützter Textkorrektur und Zusammenfassung.

## Features

- Sprachaufnahme mit Echtzeit-Transkription
- Automatische Textkorrektur durch On-Device LLM
- KI-generierte Zusammenfassungen
- Persistente Speicherung mit SwiftData
- Export als Markdown oder PDF
- Teilen einzelner Notizen

## Voraussetzungen

- **iOS 26** oder höher
- **iPhone 16** oder neuer (für Apple Intelligence)
- **Apple Intelligence** muss aktiviert sein
- **Sprache:** Deutsch (de-DE)

## Build-Anleitung

1. Repository klonen
2. Projekt in Xcode 26 öffnen
3. Simulator oder Gerät auswählen (iPhone 16+)
4. Mit `Cmd + R` starten

## Architektur

```
voice-notes-app/
├── Models/
│   ├── VoiceNote.swift         # SwiftData Model
│   └── ProcessedNote.swift     # @Generable LLM Output
├── Services/
│   ├── SpeechRecognitionService.swift
│   ├── FoundationModelsService.swift
│   └── ExportService.swift
├── Views/
│   ├── ContentView.swift       # Hauptansicht mit Liste
│   ├── RecordingView.swift     # Aufnahme-UI
│   ├── ProcessingView.swift    # Verarbeitungs-UI
│   ├── VoiceNoteCard.swift
│   ├── ExportView.swift
│   └── ...
└── Utilities/
    ├── AppError.swift
    └── HapticFeedback.swift
```

## Bekannte Einschränkungen

- Die App funktioniert nur mit aktivierter Apple Intelligence
- Spracherkennung ist auf Deutsch (de-DE) optimiert
- On-Device LLM-Verarbeitung kann bei längeren Texten einige Sekunden dauern
- Kein Cloud-Sync - Daten werden nur lokal gespeichert

## Tests

Das Projekt enthält Unit- und Integration-Tests:

```bash
# Tests in Xcode ausführen
xcodebuild test -scheme voice-notes-app -destination 'platform=iOS Simulator,name=iPhone 17'
```
