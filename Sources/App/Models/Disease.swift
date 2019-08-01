//
//  Disease.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation

struct Disease: Codable {
    static var name = "Disease"

    var IRI: String
    var preferredTerm: String
    var id: String
    var code: String
    var url: URL {
        if IRI.hasPrefix("urn:miriam:ncit") {
            return URL(string: "http://purl.obolibrary.org/obo/NCIT_\(code)")!
        } else if IRI.hasPrefix("urn:miriam:orphanet") {
            return URL(string: "http://www.orpha.net/ORDO/Orphanet_\(code)")!
        } else {
            return URL(string: code)!
        }
    }
    enum CodingKeys: String, CodingKey {
        case IRI, preferredTerm = "PreferredTerm", id = "ID", code = "Code"
    }
}
