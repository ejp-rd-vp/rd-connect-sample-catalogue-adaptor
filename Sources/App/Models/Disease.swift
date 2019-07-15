//
//  Disease.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation

import Foundation

struct Disease: Decodable {
    static var name = "Disease"

    var IRI: String
    var preferredTerm: String
    var id: String
    var code: String
    enum CodingKeys: String, CodingKey {
        case IRI, preferredTerm = "PreferredTerm", id = "ID", code = "Code"
    }
}
