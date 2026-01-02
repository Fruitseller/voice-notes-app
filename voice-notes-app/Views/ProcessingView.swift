//
//  ProcessingView.swift
//  voice-notes-app
//

import SwiftUI

struct ProcessingView: View {
    let partialResult: ProcessedNote.PartiallyGenerated?

    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Verarbeitung läuft...")
                .font(.headline)

            if let result = partialResult {
                VStack(alignment: .leading, spacing: 16) {
                    if let summary = result.summary, !summary.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Zusammenfassung")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            Text(summary)
                                .font(.body)
                        }
                    }

                    if let correctedText = result.correctedText, !correctedText.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Korrigierter Text")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            Text(correctedText)
                                .font(.body)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }
}

#Preview("Loading") {
    ProcessingView(partialResult: nil)
}
