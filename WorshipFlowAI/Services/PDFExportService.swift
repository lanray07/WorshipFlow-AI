import Foundation
import UIKit

struct PDFExportService {
    func makeSetListPDF(setList: SetList, songs: [Song], notes: [RehearsalNote]) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appending(path: "\(setList.title.replacingOccurrences(of: " ", with: "-"))-flow.pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        try renderer.writePDF(to: url) { context in
            context.beginPage()
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 28), .foregroundColor: UIColor.label]
            let bodyAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.label]
            setList.title.draw(at: CGPoint(x: 40, y: 40), withAttributes: titleAttributes)
            "Service: \(setList.serviceDate.formatted(date: .abbreviated, time: .shortened))".draw(at: CGPoint(x: 40, y: 82), withAttributes: bodyAttributes)
            WorshipFlowAIPrompt.disclaimer.draw(in: CGRect(x: 40, y: 110, width: 532, height: 44), withAttributes: bodyAttributes)
            var y = 174
            for (index, song) in songs.enumerated() {
                "\(index + 1). \(song.title) - \(song.originalKey) - \(song.bpm) BPM".draw(at: CGPoint(x: 40, y: y), withAttributes: bodyAttributes)
                y += 26
                if y > 700 {
                    context.beginPage()
                    y = 44
                }
            }
            if !notes.isEmpty {
                y += 20
                "Rehearsal Notes".draw(at: CGPoint(x: 40, y: y), withAttributes: titleAttributes)
                y += 40
                for note in notes {
                    note.content.draw(in: CGRect(x: 40, y: y, width: 532, height: 58), withAttributes: bodyAttributes)
                    y += 64
                }
            }
        }
        return url
    }
}
