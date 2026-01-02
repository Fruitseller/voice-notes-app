//
//  RecordButton.swift
//  voice-notes-app
//

import SwiftUI

struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void

    @State private var isPulsing = false

    var body: some View {
        Button {
            HapticFeedback.impact(.medium)
            action()
        } label: {
            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                .font(.system(size: 32))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(isRecording ? Color.red : Color.accentColor)
                .clipShape(Circle())
                .shadow(radius: 4, y: 2)
                .scaleEffect(isPulsing ? 1.1 : 1.0)
        }
        .accessibilityLabel(isRecording ? "Aufnahme stoppen" : "Aufnahme starten")
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            } else {
                withAnimation(.default) {
                    isPulsing = false
                }
            }
        }
    }
}

#Preview("Idle") {
    RecordButton(isRecording: false) {}
}

#Preview("Recording") {
    RecordButton(isRecording: true) {}
}
