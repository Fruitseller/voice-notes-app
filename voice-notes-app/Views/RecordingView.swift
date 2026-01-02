//
//  RecordingView.swift
//  voice-notes-app
//

import SwiftUI
import SwiftData
import FoundationModels

enum ProcessingState {
    case idle
    case processing
    case done
}

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var speechService = SpeechRecognitionService()
    @State private var foundationService = FoundationModelsService()

    @State private var hasPermission: Bool?
    @State private var showPermissionAlert = false
    @State private var processingState: ProcessingState = .idle
    @State private var partialResult: ProcessedNote.PartiallyGenerated?
    @State private var showEmptyTranscriptionAlert = false
    @State private var showAvailabilityAlert = false
    @State private var availabilityMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if processingState == .processing {
                    ProcessingView(partialResult: partialResult)
                        .frame(maxHeight: .infinity)
                } else {
                    // Live transcription area
                    ScrollView {
                        VStack(alignment: .leading) {
                            if speechService.transcription.isEmpty {
                                Text("Sprechen Sie jetzt...")
                                    .foregroundStyle(.secondary)
                                    .italic()
                            } else {
                                Text(speechService.transcription)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                    .frame(maxHeight: .infinity)

                    Divider()

                    // Record button
                    RecordButton(isRecording: speechService.isRecording) {
                        handleRecordButtonTap()
                    }
                    .disabled(processingState == .processing)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle(processingState == .processing ? "Verarbeitung" : "Aufnahme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        if speechService.isRecording {
                            speechService.stopRecording()
                        }
                        dismiss()
                    }
                    .disabled(processingState == .processing)
                }
            }
            .alert("Berechtigung erforderlich", isPresented: $showPermissionAlert) {
                Button("Einstellungen öffnen") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Bitte erlaube den Zugriff auf Mikrofon und Spracherkennung in den Einstellungen.")
            }
            .alert("Keine Sprache erkannt", isPresented: $showEmptyTranscriptionAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Es wurde keine Sprache erkannt. Bitte versuche es erneut.")
            }
            .alert("Apple Intelligence nicht verfügbar", isPresented: $showAvailabilityAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(availabilityMessage)
            }
            .task {
                hasPermission = await speechService.requestPermissions()
            }
        }
    }

    private func handleRecordButtonTap() {
        if speechService.isRecording {
            speechService.stopRecording()
            processTranscription()
        } else {
            Task {
                if hasPermission == nil {
                    hasPermission = await speechService.requestPermissions()
                }

                guard hasPermission == true else {
                    showPermissionAlert = true
                    return
                }

                do {
                    try speechService.startRecording()
                } catch {
                    speechService.error = error
                }
            }
        }
    }

    private func processTranscription() {
        let transcription = speechService.transcription

        guard !transcription.isEmpty else {
            showEmptyTranscriptionAlert = true
            return
        }

        // Check availability
        let availability = foundationService.checkAvailability()
        switch availability {
        case .available:
            break
        case .unavailable(let reason):
            switch reason {
            case .appleIntelligenceNotEnabled:
                availabilityMessage = "Bitte aktiviere Apple Intelligence in den Einstellungen."
            case .modelNotReady:
                availabilityMessage = "Das Sprachmodell wird noch heruntergeladen. Bitte versuche es später erneut."
            @unknown default:
                availabilityMessage = "Apple Intelligence ist nicht verfügbar."
            }
            showAvailabilityAlert = true
            return
        }

        processingState = .processing
        partialResult = nil

        Task {
            do {
                let stream = try await foundationService.processTranscriptionStream(transcription)

                var finalResult: ProcessedNote.PartiallyGenerated?
                for try await result in stream {
                    partialResult = result
                    finalResult = result
                }

                if let result = finalResult,
                   let correctedText = result.correctedText,
                   let summary = result.summary {
                    saveVoiceNote(
                        originalTranscription: transcription,
                        correctedText: correctedText,
                        summary: summary
                    )
                }

                processingState = .done
                dismiss()
            } catch {
                processingState = .idle
                availabilityMessage = "Verarbeitung fehlgeschlagen: \(error.localizedDescription)"
                showAvailabilityAlert = true
            }
        }
    }

    private func saveVoiceNote(originalTranscription: String, correctedText: String, summary: String) {
        let note = VoiceNote(
            originalTranscription: originalTranscription,
            correctedText: correctedText,
            summary: summary
        )
        modelContext.insert(note)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save VoiceNote: \(error)")
        }
    }
}

#Preview {
    RecordingView()
        .modelContainer(for: VoiceNote.self, inMemory: true)
}
