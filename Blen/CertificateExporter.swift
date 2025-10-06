import Foundation
import PDFKit
import SwiftUI

class CertificateExporter {
    static func generatePDF(for certificate: Certificate, username: String) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Rush Academy",
            kCGPDFContextAuthor: username,
            kCGPDFContextTitle: "Certificate"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 595.2  // A4
        let pageHeight = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()

            let title = "Certificate of Completion"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: UIColor.systemBlue
            ]
            title.draw(at: CGPoint(x: 70, y: 80), withAttributes: titleAttributes)

            let nameText = "This certifies that \(username)"
            let nameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20)
            ]
            nameText.draw(at: CGPoint(x: 70, y: 150), withAttributes: nameAttributes)

            let detailText: String
            if certificate.relatedToQuiz {
                detailText = "Has successfully completed the quiz: \(certificate.courseTitle ?? "Unknown")\n" +
                             "Score: \(certificate.score ?? 0)/\(certificate.totalQuestions ?? 0)\n" +
                             "Grade: \(certificate.grade)"
            } else {
                detailText = "Has successfully completed the course: \(certificate.courseTitle ?? "Unknown")\n" +
                             "Final Grade: \(certificate.grade)"
            }

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            let detailAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .paragraphStyle: paragraphStyle
            ]
            detailText.draw(in: CGRect(x: 70, y: 200, width: pageWidth - 140, height: 300), withAttributes: detailAttributes)

            let dateText = "Issued on \(certificate.issueDate.formatted(date: .long, time: .omitted))"
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 14),
                .foregroundColor: UIColor.gray
            ]
            dateText.draw(at: CGPoint(x: 70, y: pageHeight - 100), withAttributes: dateAttributes)
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("certificate.pdf")
        do {
            try data.write(to: url)
            return url
        } catch {
            print("Error saving PDF: \(error)")
            return nil
        }
    }
}
