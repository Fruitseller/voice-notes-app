//
//  HapticFeedback.swift
//  voice-notes-app
//

import UIKit

enum HapticFeedback {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    // Convenience methods
    static func recordingStarted() {
        impact(.medium)
    }

    static func recordingStopped() {
        impact(.medium)
    }

    static func deleted() {
        notification(.warning)
    }

    static func success() {
        notification(.success)
    }

    static func error() {
        notification(.error)
    }
}
