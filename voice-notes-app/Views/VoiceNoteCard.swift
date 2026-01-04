//
//  VoiceNoteCard.swift
//  voice-notes-app
//

import SwiftUI

struct VoiceNoteCard: View {
    let note: VoiceNote
    let onDelete: () -> Void
    let onShare: () -> Void

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        return formatter.string(from: note.timestamp)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date
            Text(formattedDate)
                .font(.caption)
                .foregroundStyle(.secondary)

            // Summary section
            VStack(alignment: .leading, spacing: 4) {
                Text("Zusammenfassung")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(note.summary)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            // Corrected text
            Text(note.correctedText)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Notiz vom \(formattedDate). Zusammenfassung: \(note.summary). \(note.correctedText)")
        .contextMenu {
            Button {
                onShare()
            } label: {
                Label("Teilen", systemImage: "square.and.arrow.up")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
    }
}

#Preview {
    VoiceNoteCard(
        note: {
            let note = VoiceNote(
                originalTranscription: "Test original",
                correctedText: "Dies ist ein Beispieltext einer Sprachnotiz, die korrigiert wurde.",
                summary: "Eine kurze Zusammenfassung der Notiz."
            )
            return note
        }(),
        onDelete: {},
        onShare: {}
    )
    .padding()
}
