# VoiceNotes App – Entwicklungsplan

## App-Übersicht

**Zweck:** iOS-App zur Aufnahme von Sprachnotizen, die automatisch transkribiert, korrigiert und zusammengefasst werden.

**Workflow:**
1. Nutzer tippt auf Aufnahme-Button und spricht
2. Speech Recognition transkribiert live (de-DE)
3. Nach Stop: On-Device LLM (Foundation Models) korrigiert Füllwörter/Grammatik und erstellt Zusammenfassung
4. Notiz wird gespeichert und in Liste angezeigt
5. Notizen können gelöscht oder gesammelt als Markdown/PDF exportiert werden

**Technologie-Stack:**
- iOS 26, SwiftUI, SwiftData
- Foundation Models Framework (Apple Intelligence)
- Speech Framework + AVFoundation
- PDFKit für Export

**Zielgeräte:** iPhone 16, iPhone 16 Pro (Foundation Models immer verfügbar)

**Sprache:** Deutsch (de-DE)

---

## Phase 1: Projekt-Setup & Grundgerüst

**Ziel:** Lauffähige App mit Datenmodell und leerer Liste

### Tasks

**1.1 Xcode-Projekt erstellen**
- Neues iOS App Projekt
- Target: iOS 26.0
- Interface: SwiftUI
- Storage: SwiftData
- Bundle Identifier festlegen

**1.2 Info.plist konfigurieren**
- `NSSpeechRecognitionUsageDescription`: "Diese App benötigt Zugriff auf die Spracherkennung, um Ihre Sprachnotizen zu transkribieren."
- `NSMicrophoneUsageDescription`: "Diese App benötigt Zugriff auf das Mikrofon, um Sprachnotizen aufzunehmen."

**1.3 Frameworks importieren**
- FoundationModels
- Speech
- AVFoundation
- PDFKit

Hinweis: Alle sind System-Frameworks, kein SPM/CocoaPods nötig.

**1.4 VoiceNote Model erstellen**
- @Model Annotation für SwiftData
- Eigenschaften:
  - `id`: UUID (Standardwert: UUID())
  - `timestamp`: Date (Standardwert: Date.now)
  - `originalTranscription`: String
  - `correctedText`: String
  - `summary`: String

**1.5 App-Struktur mit ModelContainer**
- ModelContainer für VoiceNote in App-Struct konfigurieren
- modelContainer Modifier an ContentView

**1.6 Basis-UI erstellen**
- ContentView mit NavigationStack
- @Query für VoiceNotes, sortiert nach timestamp (descending)
- EmptyStateView: Icon + "Keine Notizen" + Hinweistext
- FAB (Floating Action Button) unten rechts als Platzhalter

### Akzeptanzkriterien
- [ ] App startet auf Simulator (iOS 26)
- [ ] Empty State wird angezeigt
- [ ] Build ohne Fehler
- [ ] FAB ist sichtbar (noch ohne Funktion)

---

## Phase 2: Speech Recognition + Recording UI

**Ziel:** Funktionierende Aufnahme mit Live-Transkription

### Tasks

**2.1 SpeechRecognitionService erstellen**
- Klasse mit ObservableObject
- Published Properties:
  - `transcription`: String (aktueller Text)
  - `isRecording`: Bool
  - `error`: Error?
- Private Properties:
  - SFSpeechRecognizer für Locale "de-DE"
  - AVAudioEngine
  - SFSpeechAudioBufferRecognitionRequest
  - SFSpeechRecognitionTask
- Methoden:
  - `requestPermissions() async -> Bool`: Speech + Mikrofon Berechtigung anfragen
  - `startRecording() throws`: Audio Session konfigurieren, Recognition starten, Live-Updates
  - `stopRecording() -> String`: Engine stoppen, finale Transkription zurückgeben

**2.2 Audio Session Konfiguration**
- Category: .record
- Mode: .measurement
- Aktivieren vor Aufnahme

**2.3 Recognition Request Setup**
- shouldReportPartialResults = true
- requiresOnDeviceRecognition = true (für Offline-Fähigkeit)
- Input Node Tap installieren
- Buffer an Recognition Request anhängen

**2.4 RecordingView erstellen**
- @StateObject für SpeechRecognitionService
- @Environment(\.dismiss) für Sheet-Schließung
- @Environment(\.modelContext) für Speicherung
- Layout:
  - Überschrift "Aufnahme"
  - ScrollView mit Live-Transkription
  - Placeholder "Sprechen Sie jetzt..." wenn leer
  - RecordButton unten zentriert

**2.5 RecordButton Component**
- Großer kreisförmiger Button (80x80)
- Farbe: Rot bei Aufnahme, Blau im Idle
- Icon: mic.fill im Idle, stop.fill bei Aufnahme
- Tap-Handler: Toggle zwischen Start/Stop

**2.6 Permission Handling**
- Bei erstem Tap: Berechtigungen anfragen
- Bei Ablehnung: Alert mit Hinweis auf Einstellungen

**2.7 Integration in ContentView**
- @State für showRecordingSheet
- FAB öffnet Sheet mit RecordingView
- Sheet Modifier mit RecordingView

### Akzeptanzkriterien
- [ ] Mikrofon-Permission wird angefragt
- [ ] Speech-Permission wird angefragt
- [ ] Live-Transkription erscheint während Sprechen
- [ ] Button wechselt visuell zwischen Idle/Recording
- [ ] Stop gibt finale Transkription zurück
- [ ] Bei Permission-Ablehnung: verständlicher Hinweis

### Ergebnis nach Phase 2
Nutzbare App – Aufnahme und Transkription funktionieren (noch ohne KI-Verarbeitung und Speicherung)

---

## Phase 3: Foundation Models Integration

**Ziel:** Korrektur und Zusammenfassung via On-Device LLM

### Tasks

**3.1 ProcessedNote Struktur definieren**
- @Generable Macro
- Eigenschaften:
  - `correctedText`: String mit @Guide(description: "Der korrigierte deutsche Text. Entferne Füllwörter wie 'ähm', 'also', 'halt'. Korrigiere Grammatikfehler. Behalte den Inhalt bei.")
  - `summary`: String mit @Guide(description: "Eine prägnante Zusammenfassung des Inhalts in 1-2 Sätzen auf Deutsch.")

**3.2 FoundationModelsService erstellen**
- Klasse für LLM-Interaktion
- Property: LanguageModelSession
- Methode `checkAvailability() -> Bool`:
  - SystemLanguageModel.default.availability prüfen
  - Bei .unavailable: Grund auswerten (appleIntelligenceNotEnabled, modelNotReady, etc.)
- Methode `processTranscription(_ text: String) async throws -> ProcessedNote`:
  - Session erstellen falls nötig
  - Prompt: "Verarbeite die folgende deutsche Sprachnotiz:"
  - session.respond(to: prompt, generating: ProcessedNote.self)
- Methode `processTranscriptionStream(_ text: String) -> AsyncThrowingStream<PartiallyGenerated<ProcessedNote>, Error>`:
  - Für progressive UI-Updates während Generierung
  - session.streamResponse(to: prompt, generating: ProcessedNote.self)

**3.3 Verfügbarkeitsprüfung in UI**
- Beim App-Start oder vor erster Nutzung prüfen
- Bei .unavailable(.appleIntelligenceNotEnabled): Hinweis "Bitte aktiviere Apple Intelligence in den Einstellungen"
- Bei .unavailable(.modelNotReady): Hinweis "Das Sprachmodell wird noch heruntergeladen"

**3.4 RecordingView erweitern**
- @StateObject für FoundationModelsService
- @State für processingState: idle | processing | done
- @State für partialResult: ProcessedNote? (für Streaming)
- Nach Stop-Button:
  1. Guard: Transkription nicht leer
  2. processingState = .processing
  3. Streaming starten, partialResult updaten
  4. Bei Completion: VoiceNote erstellen und speichern
  5. Sheet dismisses

**3.5 ProcessingView Component**
- ProgressView mit "Verarbeitung läuft..."
- Anzeige von Partial Results sobald verfügbar:
  - "Zusammenfassung:" + partialResult?.summary
  - "Korrigierter Text:" + partialResult?.correctedText
- Visuelles Feedback dass Generierung läuft

**3.6 VoiceNote speichern**
- Nach erfolgreicher Verarbeitung:
  - VoiceNote mit originalTranscription, correctedText, summary erstellen
  - In modelContext einfügen
  - try modelContext.save()
- Sheet schließen

### Akzeptanzkriterien
- [ ] ProcessedNote wird korrekt generiert
- [ ] Streaming zeigt Zwischenergebnisse
- [ ] VoiceNote wird in SwiftData gespeichert
- [ ] Nach Speicherung: Sheet schließt, Notiz erscheint in Liste
- [ ] Bei deaktivierter Apple Intelligence: verständliche Fehlermeldung

### Ergebnis nach Phase 3
Kernfunktionalität komplett – Aufnahme → Transkription → KI-Verarbeitung → Speicherung

---

## Phase 4: Haupt-UI mit Card-Liste

**Ziel:** Vollständige Listenansicht mit Interaktionen

### Tasks

**4.1 VoiceNoteCard Component erstellen**
- Parameter: VoiceNote, onDelete: () -> Void, onShare: () -> Void
- Layout:
  - Datum/Zeit oben (caption, sekundäre Farbe), formatiert: "dd.MM.yyyy, HH:mm"
  - "Zusammenfassung" Label (subheadline, semibold)
  - Summary Text (subheadline)
  - Divider
  - Korrigierter Text (body)
- Styling: Padding, abgerundete Ecken, leichter Schatten

**4.2 Card-Style ViewModifier**
- Padding: 16
- Background: Color(.systemBackground)
- ClipShape: RoundedRectangle(cornerRadius: 12)
- Shadow: radius 4, y 2, opacity 0.1

**4.3 ContentView Liste implementieren**
- ScrollView mit LazyVStack (spacing: 12, padding: 16)
- ForEach über @Query Ergebnisse
- VoiceNoteCard für jede Notiz
- swipeActions für Delete (trailing, destructive)

**4.4 Delete-Funktionalität**
- @State für noteToDelete: VoiceNote?
- @State für showDeleteConfirmation: Bool
- Swipe-Action setzt noteToDelete und zeigt Alert
- Alert: "Notiz löschen?" mit Abbrechen/Löschen Buttons
- Bei Bestätigung: modelContext.delete(note)

**4.5 Share-Funktionalität für einzelne Notiz**
- @State für noteToShare: VoiceNote?
- @State für showShareSheet: Bool
- Share-Button in Card oder als Swipe-Action
- ShareSheet mit formatiertem Text:
  ```
  Sprachnotiz vom [Datum]
  
  Zusammenfassung:
  [summary]
  
  [correctedText]
  ```

**4.6 Accessibility**
- FAB: accessibilityLabel("Neue Aufnahme starten")
- Cards: accessibilityElement(children: .combine) oder sinnvolle Gruppierung
- Delete-Button: accessibilityLabel("Notiz löschen")
- Share-Button: accessibilityLabel("Notiz teilen")

### Akzeptanzkriterien
- [ ] Alle Notizen werden als Cards angezeigt
- [ ] Neueste Notiz oben
- [ ] Datum, Zusammenfassung, Text sichtbar
- [ ] Swipe-to-Delete mit Bestätigung funktioniert
- [ ] Einzelne Notiz kann geteilt werden
- [ ] Empty State bei keinen Notizen
- [ ] VoiceOver funktioniert sinnvoll

---

## Phase 5: Export-Funktionalität

**Ziel:** Alle Notizen als Markdown oder PDF exportieren

### Tasks

**5.1 ExportFormat Enum**
- case markdown
- case pdf
- Computed Property für Dateiendung und UTType

**5.2 ExportService erstellen**
- Statische Methoden oder Singleton
- `generateMarkdown(_ notes: [VoiceNote]) -> String`:
  ```
  # Sprachnotizen Export
  Exportiert am [Datum]
  
  ---
  
  ## [Datum der Notiz]
  
  **Zusammenfassung:** [summary]
  
  [correctedText]
  
  ---
  ```
- `generatePDF(_ notes: [VoiceNote]) -> Data`:
  - UIGraphicsPDFRenderer
  - Seitengröße: A4 (595 x 842 Punkte)
  - Margins: 40pt
  - Pro Notiz: Datum, Zusammenfassung, Text
  - Neue Seite wenn Platz nicht reicht oder nach jeder Notiz

**5.3 PDF-Rendering Details**
- Titel-Font: .boldSystemFont(ofSize: 12) für Datum
- Body-Font: .systemFont(ofSize: 11)
- Zeilenabstand berechnen mit boundingRect
- Seitenumbruch-Logik

**5.4 ExportView erstellen**
- NavigationStack mit Form
- Picker für Format (Segmented Style): Markdown | PDF
- Info-Text: "X Notizen werden exportiert"
- Export-Button
- Cancel-Button in Toolbar
- @State für selectedFormat
- @State für exportData: ExportData?
- @State für showShareSheet

**5.5 ExportData Struktur**
- data: Data
- filename: String (z.B. "sprachnotizen_2025-01-15.md")
- utType: UTType

**5.6 ShareSheet Component**
- UIViewControllerRepresentable
- UIActivityViewController wrappen
- Temporäre Datei erstellen für korrekten Dateinamen im Share Dialog
- Cleanup nach Dismiss

**5.7 Integration in ContentView**
- @State für showExportSheet
- Toolbar-Button (nur wenn notes.count > 0): square.and.arrow.up Icon
- Sheet mit ExportView

### Akzeptanzkriterien
- [ ] Export-Button nur sichtbar wenn Notizen vorhanden
- [ ] Markdown-Export enthält alle Notizen korrekt formatiert
- [ ] PDF-Export ist lesbar und korrekt formatiert
- [ ] Share Sheet zeigt korrekten Dateinamen
- [ ] Export kann in Dateien, Mail, etc. geteilt werden

---

## Phase 6: Error Handling & Polish

**Ziel:** Robuste App mit gutem UX

### Tasks

**6.1 AppError Enum definieren**
- Konformität zu LocalizedError
- Cases:
  - `speechRecognitionNotAuthorized`: "Spracherkennung nicht erlaubt. Bitte in den Einstellungen aktivieren."
  - `microphoneNotAuthorized`: "Mikrofonzugriff nicht erlaubt. Bitte in den Einstellungen aktivieren."
  - `transcriptionEmpty`: "Keine Sprache erkannt. Bitte erneut versuchen."
  - `processingFailed(Error)`: "Verarbeitung fehlgeschlagen: [Beschreibung]"
  - `modelUnavailable(String)`: "Sprachmodell nicht verfügbar: [Grund]"
  - `exportFailed`: "Export fehlgeschlagen."
- errorDescription Property für jeden Case

**6.2 Error Handling in SpeechRecognitionService**
- Permission-Fehler korrekt werfen
- Recognition-Fehler abfangen und in error Property setzen
- Audio Session Fehler behandeln

**6.3 Error Handling in FoundationModelsService**
- Availability-Check vor Verarbeitung
- Session-Fehler abfangen
- Timeout-Handling falls nötig

**6.4 Error Handling in RecordingView**
- @State für currentError: AppError?
- Alert bei Fehlern mit verständlicher Meldung
- Möglichkeit zum erneuten Versuch

**6.5 Edge Cases behandeln**
- Leere Transkription: Nicht verarbeiten, Hinweis anzeigen
- App-Wechsel während Aufnahme: Aufnahme stoppen
- Sehr lange Aufnahmen: Ggf. Hinweis oder Limit

**6.6 Animationen hinzufügen**
- RecordButton: scaleEffect(isRecording ? 1.1 : 1.0) mit Animation(.easeInOut.repeatForever(autoreverses: true))
- Card-Liste: .animation(.spring, value: notes.count)
- Processing-View: Subtile Puls-Animation

**6.7 Haptic Feedback**
- UIImpactFeedbackGenerator
- Recording Start: .medium
- Recording Stop: .medium
- Delete: .heavy (nach Bestätigung)
- Export erfolgreich: .success (UINotificationFeedbackGenerator)

**6.8 Dark Mode verifizieren**
- Alle Farben als System-Farben (Color.primary, Color.secondary, Color(.systemBackground))
- Cards in beiden Modi testen
- Kontrast prüfen

**6.9 Kleine UX-Verbesserungen**
- Disabled-State für Buttons während Processing
- Loading-Indicator in FAB während Processing optional
- Bestätigungs-Feedback nach erfolgreichem Speichern (kurzer Text oder Haptic)

### Akzeptanzkriterien
- [ ] Alle Fehler zeigen verständliche deutsche Meldungen
- [ ] Keine Crashes bei Edge Cases
- [ ] RecordButton pulsiert während Aufnahme
- [ ] Haptic Feedback bei wichtigen Aktionen
- [ ] Dark Mode funktioniert korrekt
- [ ] App fühlt sich responsiv an

---

## Phase 7: Tests & Abschluss

**Ziel:** Testabdeckung für kritische Pfade, Dokumentation

### Tasks

**7.1 Unit Tests**

**VoiceNote Model Tests:**
- Test: VoiceNote-Erstellung mit allen Feldern
- Test: Standardwerte (id, timestamp) werden gesetzt

**ExportService Tests:**
- Test: Markdown-Generierung enthält Header
- Test: Markdown-Generierung enthält alle Notizen
- Test: PDF-Generierung liefert Data mit Größe > 0

**AppError Tests:**
- Test: Jeder Error-Case hat nicht-leere errorDescription

**7.2 Integration Tests (In-Memory SwiftData)**
- ModelContainer mit isStoredInMemoryOnly: true
- Test: VoiceNote speichern und wieder laden
- Test: VoiceNote löschen

**7.3 Manual Testing Checklist**
- [ ] Echtes iPhone 16 mit iOS 26
- [ ] Apple Intelligence aktiviert
- [ ] Aufnahme in ruhiger Umgebung
- [ ] Aufnahme mit Hintergrundgeräuschen
- [ ] Aufnahme flüsternd
- [ ] Aufnahme laut
- [ ] Lange Aufnahme (3+ Minuten)
- [ ] Mehrere Notizen erstellen
- [ ] Notiz löschen
- [ ] Einzelne Notiz teilen
- [ ] Export Markdown → Mail
- [ ] Export Markdown → Dateien
- [ ] Export PDF → Mail
- [ ] Export PDF → Dateien
- [ ] App während Aufnahme in Hintergrund
- [ ] App-Neustart, Notizen noch da
- [ ] Dark Mode aktivieren, alle Screens prüfen
- [ ] VoiceOver aktivieren, Hauptflows testen
- [ ] Apple Intelligence deaktivieren → Fehlermeldung

**7.4 Code-Dokumentation**
- MARK: Kommentare für Code-Sektionen
- TODO: für bekannte Limitationen oder zukünftige Verbesserungen
- Kurze Kommentare für komplexe Logik (Audio Session Setup, PDF Rendering)

**7.5 README erstellen**
- Kurze Projektbeschreibung
- Voraussetzungen (iOS 26, iPhone 16, Apple Intelligence)
- Build-Anleitung
- Bekannte Einschränkungen

### Akzeptanzkriterien
- [ ] Alle Unit Tests grün
- [ ] Integration Tests grün
- [ ] Manual Testing Checklist abgearbeitet
- [ ] Code ist kommentiert
- [ ] README vorhanden

---

## Projektstruktur (Vorschlag)

```
VoiceNotes/
├── VoiceNotesApp.swift
├── Models/
│   └── VoiceNote.swift
├── Services/
│   ├── SpeechRecognitionService.swift
│   ├── FoundationModelsService.swift
│   └── ExportService.swift
├── Views/
│   ├── ContentView.swift
│   ├── EmptyStateView.swift
│   ├── VoiceNoteCard.swift
│   ├── RecordingView.swift
│   ├── ProcessingView.swift
│   ├── RecordButton.swift
│   ├── ExportView.swift
│   └── ShareSheet.swift
├── Utilities/
│   ├── AppError.swift
│   └── ViewModifiers.swift
├── Resources/
│   └── Info.plist
└── Tests/
    ├── VoiceNoteTests.swift
    ├── ExportServiceTests.swift
    └── IntegrationTests.swift
```

---

## Zeitschätzung

| Phase | Geschätzter Aufwand |
|-------|---------------------|
| Phase 1: Setup & Grundgerüst | 2-3 Stunden |
| Phase 2: Speech Recognition | 4-6 Stunden |
| Phase 3: Foundation Models | 4-6 Stunden |
| Phase 4: Card-Liste UI | 3-4 Stunden |
| Phase 5: Export | 3-4 Stunden |
| Phase 6: Error Handling & Polish | 3-4 Stunden |
| Phase 7: Tests & Abschluss | 2-3 Stunden |
| **Gesamt** | **21-30 Stunden** |

Hinweis: Als Hobbyprojekt ohne Zeitdruck. Zeiten variieren je nach SwiftUI/iOS-Erfahrung.

---

## Nicht im Scope (für später)

- Audio-Aufnahme speichern
- Original-Transkription anzeigen (ausklappbar)
- Mehrsprachige Unterstützung
- iCloud Sync
- Widgets
- Siri Shortcuts
- Apple Watch Companion App
- Kategorien/Tags für Notizen
- Suche in Notizen
