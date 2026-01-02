//
//  ProcessingView.swift
//  voice-notes-app
//

import SwiftUI

struct ProcessingView: View {
    let partialResult: ProcessedNote.PartiallyGenerated?

    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(isPulsing ? 1.6 : 1.4)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
                .onAppear {
                    isPulsing = true
                }

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
                        .transition(.opacity.combined(with: .move(edge: .top)))
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
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .animation(.easeInOut(duration: 0.3), value: result.summary)
                .animation(.easeInOut(duration: 0.3), value: result.correctedText)
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.3), value: partialResult != nil)
    }
}

#Preview("Loading") {
    ProcessingView(partialResult: nil)
}
