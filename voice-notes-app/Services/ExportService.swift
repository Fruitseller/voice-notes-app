//
//  ExportService.swift
//  voice-notes-app
//

import Foundation
import UIKit
import PDFKit
import UniformTypeIdentifiers

// MARK: - Export Format

enum ExportFormat: String, CaseIterable {
    case markdown
    case pdf

    var fileExtension: String {
        switch self {
        case .markdown: return "md"
        case .pdf: return "pdf"
        }
    }

    var utType: UTType {
        switch self {
        case .markdown: return .plainText
        case .pdf: return .pdf
        }
    }

    var displayName: String {
        switch self {
        case .markdown: return "Markdown"
        case .pdf: return "PDF"
        }
    }
}

// MARK: - Export Data

struct ExportData {
    let data: Data
    let filename: String
    let utType: UTType

    var temporaryFileURL: URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
}

// MARK: - Export Service

class ExportService {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        return formatter
    }()

    private static let filenameDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: - Public Methods

    static func export(_ notes: [VoiceNote], format: ExportFormat) -> ExportData {
        let filename = "sprachnotizen_\(filenameDateFormatter.string(from: Date())).\(format.fileExtension)"

        let data: Data
        switch format {
        case .markdown:
            let markdown = generateMarkdown(notes)
            data = markdown.data(using: .utf8) ?? Data()
        case .pdf:
            data = generatePDF(notes)
        }

        return ExportData(data: data, filename: filename, utType: format.utType)
    }

    // MARK: - Markdown Generation

    static func generateMarkdown(_ notes: [VoiceNote]) -> String {
        var markdown = "# Sprachnotizen Export\n\n"
        markdown += "Exportiert am \(dateFormatter.string(from: Date()))\n\n"

        for note in notes {
            markdown += "## \(dateFormatter.string(from: note.timestamp))\n\n"
            markdown += "**Zusammenfassung:** \(note.summary)\n\n"
            markdown += "\(note.correctedText)\n\n"
            markdown += "---\n\n"
        }

        return markdown
    }

    // MARK: - PDF Generation

    static func generatePDF(_ notes: [VoiceNote]) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
        let margin: CGFloat = 40
        let contentRect = pageRect.insetBy(dx: margin, dy: margin)

        let titleFont = UIFont.boldSystemFont(ofSize: 18)
        let subtitleFont = UIFont.systemFont(ofSize: 12)
        let dateFont = UIFont.boldSystemFont(ofSize: 12)
        let labelFont = UIFont.boldSystemFont(ofSize: 11)
        let bodyFont = UIFont.systemFont(ofSize: 11)

        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let subtitleAttributes: [NSAttributedString.Key: Any] = [.font: subtitleFont, .foregroundColor: UIColor.gray]
        let dateAttributes: [NSAttributedString.Key: Any] = [.font: dateFont]
        let labelAttributes: [NSAttributedString.Key: Any] = [.font: labelFont]
        let bodyAttributes: [NSAttributedString.Key: Any] = [.font: bodyFont]

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { context in
            var currentY: CGFloat = 0

            func startNewPage() {
                context.beginPage()
                currentY = margin
            }

            func drawText(_ text: String, attributes: [NSAttributedString.Key: Any], maxWidth: CGFloat) -> CGFloat {
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                let boundingRect = attributedString.boundingRect(
                    with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                )

                // Check if we need a new page
                if currentY + boundingRect.height > pageRect.height - margin {
                    startNewPage()
                }

                let drawRect = CGRect(x: margin, y: currentY, width: maxWidth, height: boundingRect.height)
                attributedString.draw(in: drawRect)
                currentY += boundingRect.height + 8

                return boundingRect.height
            }

            func drawSeparator() {
                if currentY + 20 > pageRect.height - margin {
                    startNewPage()
                }

                let separatorY = currentY + 8
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: separatorY))
                path.addLine(to: CGPoint(x: pageRect.width - margin, y: separatorY))
                UIColor.lightGray.setStroke()
                path.lineWidth = 0.5
                path.stroke()
                currentY += 24
            }

            // Start first page
            startNewPage()

            // Title
            _ = drawText("Sprachnotizen Export", attributes: titleAttributes, maxWidth: contentRect.width)
            currentY += 4

            // Subtitle
            _ = drawText("Exportiert am \(dateFormatter.string(from: Date()))", attributes: subtitleAttributes, maxWidth: contentRect.width)
            currentY += 16

            // Notes
            for (index, note) in notes.enumerated() {
                // Date
                _ = drawText(dateFormatter.string(from: note.timestamp), attributes: dateAttributes, maxWidth: contentRect.width)

                // Summary label and text
                _ = drawText("Zusammenfassung:", attributes: labelAttributes, maxWidth: contentRect.width)
                _ = drawText(note.summary, attributes: bodyAttributes, maxWidth: contentRect.width)
                currentY += 8

                // Corrected text
                _ = drawText(note.correctedText, attributes: bodyAttributes, maxWidth: contentRect.width)

                // Separator (except for last note)
                if index < notes.count - 1 {
                    drawSeparator()
                }
            }
        }
    }
}
