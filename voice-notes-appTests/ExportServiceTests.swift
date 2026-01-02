//
//  ExportServiceTests.swift
//  voice-notes-appTests
//

import Testing
import Foundation
@testable import voice_notes_app

struct ExportServiceTests {

    // MARK: - Markdown Tests

    @Test func markdownContainsHeader() {
        let markdown = ExportService.generateMarkdown([])

        #expect(markdown.contains("# Sprachnotizen Export"))
    }

    @Test func markdownContainsExportDate() {
        let markdown = ExportService.generateMarkdown([])

        #expect(markdown.contains("Exportiert am"))
    }

    @Test func markdownContainsAllNotes() {
        let note1 = VoiceNote(
            originalTranscription: "Original 1",
            correctedText: "Corrected text one",
            summary: "Summary one"
        )
        let note2 = VoiceNote(
            originalTranscription: "Original 2",
            correctedText: "Corrected text two",
            summary: "Summary two"
        )

        let markdown = ExportService.generateMarkdown([note1, note2])

        #expect(markdown.contains("Summary one"))
        #expect(markdown.contains("Corrected text one"))
        #expect(markdown.contains("Summary two"))
        #expect(markdown.contains("Corrected text two"))
    }

    @Test func markdownContainsSummaryLabel() {
        let note = VoiceNote(
            originalTranscription: "Original",
            correctedText: "Corrected",
            summary: "Test summary"
        )

        let markdown = ExportService.generateMarkdown([note])

        #expect(markdown.contains("**Zusammenfassung:**"))
    }

    @Test func markdownContainsSeparators() {
        let note1 = VoiceNote(
            originalTranscription: "Original 1",
            correctedText: "Corrected 1",
            summary: "Summary 1"
        )
        let note2 = VoiceNote(
            originalTranscription: "Original 2",
            correctedText: "Corrected 2",
            summary: "Summary 2"
        )

        let markdown = ExportService.generateMarkdown([note1, note2])

        #expect(markdown.contains("---"))
    }

    // MARK: - PDF Tests

    @Test func pdfGenerationReturnsData() {
        let pdfData = ExportService.generatePDF([])

        #expect(pdfData.count > 0)
    }

    @Test func pdfGenerationWithNotesReturnsLargerData() {
        let emptyPdfData = ExportService.generatePDF([])

        let note = VoiceNote(
            originalTranscription: "Original",
            correctedText: "This is a longer corrected text that should make the PDF larger",
            summary: "Summary"
        )
        let pdfDataWithNote = ExportService.generatePDF([note])

        #expect(pdfDataWithNote.count > emptyPdfData.count)
    }

    // MARK: - Export Data Tests

    @Test func exportDataMarkdownHasCorrectExtension() {
        let exportData = ExportService.export([], format: .markdown)

        #expect(exportData.filename.hasSuffix(".md"))
    }

    @Test func exportDataPDFHasCorrectExtension() {
        let exportData = ExportService.export([], format: .pdf)

        #expect(exportData.filename.hasSuffix(".pdf"))
    }

    @Test func exportDataFilenameContainsDate() {
        let exportData = ExportService.export([], format: .markdown)

        // Filename should be like "sprachnotizen_2025-01-02.md"
        #expect(exportData.filename.hasPrefix("sprachnotizen_"))
    }
}
