import Foundation
import Vapor

struct FilterParameters: Content {
    let biobank: String?
    let disease: String?
    var queryItem: URLQueryItem? {
        if let biobank = biobank, let disease = disease, let diseaseIRI = Disease.iri(from: disease) {
            return URLQueryItem(name: "q", value: "Disease==\(diseaseIRI);BiobankID==\(biobank)")
        } else if let disease = disease, let diseaseIRI = Disease.iri(from: disease) {
            return URLQueryItem(name: "q", value: "Disease==\(diseaseIRI))")
        } else if let biobank = biobank {
            return URLQueryItem(name: "q", value: "BiobankID==\(biobank)")
        }
        return nil
    }
}
