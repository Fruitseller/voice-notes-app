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

                if let result = result {
                    self.transcription = result.bestTranscription.formattedString
                }

                if let error = error {
                    self.error = error
                    self.stopRecordingInternal()
                } else if result?.isFinal == true {
                    self.stopRecordingInternal()
                }
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
