//
//  Biobank.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation

struct Biobank: Decodable {
    let id: String
    let country: String
    let institute: String
    let city: String
    let url: URL
    let name: String

    private enum CodingKeys: String, CodingKey {
        case id = "organizationId", country = "country", institute = "nameOfHostInstitution", city, url = "idCardUrl", name
    }
}
