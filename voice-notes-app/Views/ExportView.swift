//
//  ExportView.swift
//  voice-notes-app
//

import SwiftUI

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss

    let notes: [VoiceNote]

    @State private var selectedFormat: ExportFormat = .markdown
    @State private var showShareSheet = false
    @State private var exportData: ExportData?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Exportformat")
                }

                Section {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundStyle(.secondary)
                        Text("\(notes.count) Notizen werden exportiert")
                    }
                } footer: {
                    Text(formatDescription)
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Exportieren") {
                        performExport()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet, onDismiss: {
                dismiss()
            }) {
                if let fileURL = exportData?.temporaryFileURL {
                    ShareSheet(items: [fileURL])
                }
            }
        }
    }

    private var formatDescription: String {
        switch selectedFormat {
        case .markdown:
            return "Markdown-Dateien können in Texteditoren geöffnet und bearbeitet werden."
        case .pdf:
            return "PDF-Dateien können auf allen Geräten angezeigt und gedruckt werden."
        }
    }

    private func performExport() {
        exportData = ExportService.export(notes, format: selectedFormat)
        showShareSheet = true
    }
}

#Preview {
    ExportView(notes: [])
}
