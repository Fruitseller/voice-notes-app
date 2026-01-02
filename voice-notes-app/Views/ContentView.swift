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
    @State private var noteToDelete: VoiceNote?
    @State private var showDeleteConfirmation = false
    @State private var noteToShare: VoiceNote?
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                if notes.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(notes) { note in
                            VoiceNoteCard(
                                note: note,
                                onDelete: {
                                    noteToDelete = note
                                    showDeleteConfirmation = true
                                },
                                onShare: {
                                    noteToShare = note
                                    showShareSheet = true
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    noteToDelete = note
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    noteToShare = note
                                    showShareSheet = true
                                } label: {
                                    Label("Teilen", systemImage: "square.and.arrow.up")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(Color(.systemGroupedBackground))
                    .scrollContentBackground(.hidden)
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
            RecordingView()
        }
        .sheet(isPresented: $showShareSheet) {
            if let note = noteToShare {
                ShareSheet(items: [note.shareText])
            }
        }
        .alert("Notiz löschen?", isPresented: $showDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) {
                noteToDelete = nil
            }
            Button("Löschen", role: .destructive) {
                if let note = noteToDelete {
                    modelContext.delete(note)
                    noteToDelete = nil
                }
            }
        } message: {
            Text("Diese Notiz wird unwiderruflich gelöscht.")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: VoiceNote.self, inMemory: true)
}
