//
//  Publisher.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation

struct Publisher: Codable {
    let name: String
    let location: Location

    private enum CodingKeys: String, CodingKey {
        case name, location
    }
}
