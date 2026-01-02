//
//  ShareSheet.swift
//  voice-notes-app
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Helper for formatting

extension VoiceNote {
    var shareText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"

        return """
        Sprachnotiz vom \(formatter.string(from: timestamp))

        Zusammenfassung:
        \(summary)

        \(correctedText)
        """
    }
}
