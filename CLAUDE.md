# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Build the project
xcodebuild build -scheme voice-notes-app -destination 'platform=iOS Simulator,name=iPhone 17'

# Run all tests
xcodebuild test -scheme voice-notes-app -destination 'platform=iOS Simulator,name=iPhone 17'
```

Tests use Swift Testing framework (`@Test` macro, `#expect` assertions).

## Architecture

iOS voice notes app (iOS 26+, Swift/SwiftUI) that records speech, transcribes it, and uses Apple Intelligence (Foundation Models) for text correction and summarization.

**Core Flow:**
1. User records voice → SpeechRecognitionService transcribes (de-DE, on-device)
2. FoundationModelsService corrects filler words/grammar and generates summary via on-device LLM
3. VoiceNote saved to SwiftData

**Key Components:**

- **Models/VoiceNote.swift** - SwiftData `@Model` storing originalTranscription, correctedText, summary
- **Models/ProcessedNote.swift** - `@Generable` struct with `@Guide` annotations for LLM output schema
- **Services/SpeechRecognitionService.swift** - Manages AVAudioEngine + SFSpeechRecognizer with pause detection logic
- **Services/FoundationModelsService.swift** - Wraps LanguageModelSession, supports streaming via `processTranscriptionStream()`
- **Services/ExportService.swift** - Markdown and PDF export generation

**Framework Dependencies:**
- FoundationModels (Apple Intelligence LLM)
- Speech + AVFoundation (recording/transcription)
- SwiftData (persistence)
- PDFKit (export)

## Requirements

- iOS 26, Xcode 26
- iPhone 16+ device/simulator (Apple Intelligence required)
- Apple Intelligence must be enabled on device
- Language: German (de-DE) for speech recognition
