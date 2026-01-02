//
//  ContentView.swift
//  voice-notes-app
//
//  Created by Piotr Private Großmann on 01.01.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VoiceNote.timestamp, order: .reverse) private var notes: [VoiceNote]

    @State private var showRecordingSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                if notes.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(notes) { note in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(note.timestamp, format: .dateTime.day().month().year().hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(note.summary)
                                    .font(.subheadline)
                            }
                        }
                    }
                }

                // FAB (Floating Action Button)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showRecordingSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 4, y: 2)
                        }
                        .accessibilityLabel("Neue Aufnahme starten")
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Sprachnotizen")
        }
        .sheet(isPresented: $showRecordingSheet) {
            Text("Aufnahme-Ansicht (kommt in Phase 2)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: VoiceNote.self, inMemory: true)
}
