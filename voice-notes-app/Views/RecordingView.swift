//
//  RecordingView.swift
//  voice-notes-app
//

import SwiftUI

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var speechService = SpeechRecognitionService()
    @State private var hasPermission: Bool?
    @State private var showPermissionAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
                .padding(.vertical, 32)
            }
            .navigationTitle("Aufnahme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        if speechService.isRecording {
                            speechService.stopRecording()
                        }
                        dismiss()
                    }
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
            .task {
                // Check permissions on appear
                hasPermission = await speechService.requestPermissions()
            }
        }
    }

    private func handleRecordButtonTap() {
        if speechService.isRecording {
            speechService.stopRecording()
        } else {
            Task {
                // Check permissions first
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
}

#Preview {
    RecordingView()
}
