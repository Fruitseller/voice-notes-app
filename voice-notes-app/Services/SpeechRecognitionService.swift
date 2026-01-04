//
//  SpeechRecognitionService.swift
//  voice-notes-app
//

import Foundation
import Speech
import AVFoundation

@Observable
@MainActor
class SpeechRecognitionService {
    // MARK: - Published Properties
    var transcription: String = ""
    var isRecording: Bool = false
    var error: Error?

    // MARK: - Private Properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var confirmedTranscription: String = ""
    private var lastResultLength: Int = 0

    // MARK: - Permission Handling

    func requestPermissions() async -> Bool {
        let speechAuthorized = await requestSpeechPermission()
        let microphoneAuthorized = await requestMicrophonePermission()
        return speechAuthorized && microphoneAuthorized
    }

    private func requestSpeechPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    private func requestMicrophonePermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    // MARK: - Recording Control

    func startRecording() throws {
        // Reset previous state
        transcription = ""
        confirmedTranscription = ""
        lastResultLength = 0
        error = nil

        // Cancel any ongoing task
        recognitionTask?.cancel()
        recognitionTask = nil

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognitionError.requestCreationFailed
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = true

        // Verify recognizer availability
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechRecognitionError.recognizerUnavailable
        }

        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                self.handleRecognitionResult(result: result, error: error)
            }
        }

        // Setup audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        isRecording = true
    }

    @discardableResult
    func stopRecording() -> String {
        stopRecordingInternal()
        return transcription
    }

    private func handleRecognitionResult(result: SFSpeechRecognitionResult?, error: Error?) {
        if let result = result {
            let newText = result.bestTranscription.formattedString
            let newLength = newText.count

            // iOS resets recognition after pauses, causing shorter results.
            // Detect this and preserve the existing transcription.
            if newLength < lastResultLength && lastResultLength > 0 {
                confirmCurrentTranscription()
            }

            lastResultLength = newLength

            // Build full transcription: confirmed + new segment
            if confirmedTranscription.isEmpty {
                transcription = newText
            } else if !newText.isEmpty {
                transcription = confirmedTranscription + " " + newText
            }

            if result.isFinal {
                confirmCurrentTranscription()
            }
        }

        if let error = error {
            let nsError = error as NSError
            let isExpectedError = nsError.domain == "kAFAssistantErrorDomain"

            if isExpectedError && isRecording {
                confirmCurrentTranscription()
            } else if !isExpectedError {
                self.error = error
                stopRecordingInternal()
            }
        }
    }

    private func confirmCurrentTranscription() {
        if !transcription.isEmpty {
            confirmedTranscription = transcription
        }
        lastResultLength = 0
    }

    private func stopRecordingInternal() {
        guard isRecording else { return }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil

        isRecording = false
    }
}

// MARK: - Error Types

enum SpeechRecognitionError: LocalizedError {
    case requestCreationFailed
    case recognizerUnavailable

    var errorDescription: String? {
        switch self {
        case .requestCreationFailed:
            return "Spracherkennungsanfrage konnte nicht erstellt werden."
        case .recognizerUnavailable:
            return "Spracherkennung ist nicht verfügbar."
        }
    }
}
