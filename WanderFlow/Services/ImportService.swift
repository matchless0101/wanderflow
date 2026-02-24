import Foundation
import UIKit
import Vision
import CoreLocation

struct CandidatePOI: Identifiable, Equatable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D?
    init(id: UUID = UUID(), name: String, coordinate: CLLocationCoordinate2D? = nil) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
    }
    static func == (lhs: CandidatePOI, rhs: CandidatePOI) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}

protocol PostImportService {
    func importFromImages(_ images: [UIImage]) async throws -> [CandidatePOI]
    func importFromURL(_ url: URL) async throws -> [CandidatePOI]
}

final class VisionImportService: PostImportService {
    func importFromImages(_ images: [UIImage]) async throws -> [CandidatePOI] {
        var all: [String] = []
        for img in images {
            if let strs = try? await recognizeText(in: img) {
                all.append(contentsOf: strs)
            }
        }
        let names = extractPOINames(from: all.joined(separator: " "))
        let unique = Array(Set(names))
        return unique.map { CandidatePOI(name: $0, coordinate: nil) }
    }
    
    func importFromURL(_ url: URL) async throws -> [CandidatePOI] {
        let data = try Data(contentsOf: url)
        guard let html = String(data: data, encoding: .utf8) else { return [] }
        let names = extractPOINames(from: html)
        let unique = Array(Set(names))
        return unique.map { CandidatePOI(name: $0, coordinate: nil) }
    }
    
    private func recognizeText(in image: UIImage) async throws -> [String] {
        guard let cg = image.cgImage else { return [] }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        try handler.perform([request])
        let results = request.results as? [VNRecognizedTextObservation] ?? []
        var out: [String] = []
        for obs in results {
            if let top = obs.topCandidates(1).first {
                out.append(top.string)
            }
        }
        return out
    }
    
    private func extractPOINames(from text: String) -> [String] {
        let stopwords = ["小时", "分钟", "路线", "攻略", "推荐", "地址", "电话", "营业", "时间", "美食", "交通"]
        let tokens = text.replacingOccurrences(of: "\n", with: " ").components(separatedBy: .whitespaces)
        var names: [String] = []
        var buffer: [String] = []
        for t in tokens {
            if t.isEmpty { continue }
            if stopwords.contains(where: { t.contains($0) }) {
                if !buffer.isEmpty {
                    names.append(buffer.joined())
                    buffer.removeAll()
                }
                continue
            }
            if t.count > 1 {
                buffer.append(t)
                if buffer.count > 4 {
                    names.append(buffer.joined())
                    buffer.removeAll()
                }
            }
        }
        if !buffer.isEmpty { names.append(buffer.joined()) }
        return names
    }
}
