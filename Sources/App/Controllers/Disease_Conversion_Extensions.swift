//
//  DiseaseCodeConverter.swift
//  App
//
//  Created by David van Enckevort on 01/08/2019.
//

import Foundation

extension Disease {

    struct ORPHA {
        static let miriam = "urn:miriam:orphanet"
        static let url = "http://www.orpha.net/ORDO/Orphanet"
        static let compact = "ORPHA"
    }

    struct NCIT {
        static let miriam = "urn:miriam:ncit"
        static let url = "http://purl.obolibrary.org/obo/NCIT"
        static let compact = "NCIT"
    }

    var url: URL? {
        if IRI.hasPrefix(NCIT.miriam) {
            return URL(string: "\(NCIT.url)_\(code)")!
        } else if IRI.hasPrefix(ORPHA.miriam) {
            return URL(string: "\(ORPHA.url)_\(code)")!
        } else {
            return nil
        }
    }

    var compactID: String? {
        if IRI.hasPrefix(NCIT.miriam) {
            return "\(NCIT.compact):\(code)"
        } else if IRI.hasPrefix(ORPHA.miriam) {
            return "\(ORPHA.compact):\(code)"
        } else {
            return nil
        }
    }

   static func iri(from compactID: String) -> String? {
        let parts = compactID.split(separator: ":")
        guard parts.count == 2 else { return nil }
        switch "\(parts[0])" {
        case NCIT.compact:
            return "\(NCIT.miriam):\(parts[1])"
        case ORPHA.compact:
            return "\(ORPHA.miriam):\(parts[1])"
        default:
            return nil
        }
    }
}
