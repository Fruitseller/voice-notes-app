//
//  EmptyStateView.swift
//  voice-notes-app
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("Keine Notizen")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tippe auf +, um eine neue Sprachnotiz aufzunehmen")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    EmptyStateView()
}
