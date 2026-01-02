//
//  RecordButton.swift
//  voice-notes-app
//

import SwiftUI

struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                .font(.system(size: 32))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(isRecording ? Color.red : Color.accentColor)
                .clipShape(Circle())
                .shadow(radius: 4, y: 2)
        }
        .accessibilityLabel(isRecording ? "Aufnahme stoppen" : "Aufnahme starten")
    }
}

#Preview("Idle") {
    RecordButton(isRecording: false) {}
}

#Preview("Recording") {
    RecordButton(isRecording: true) {}
}
