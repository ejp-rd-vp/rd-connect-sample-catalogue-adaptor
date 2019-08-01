//
//  Theme.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation

struct Theme: Codable {
    let id: URL

    private enum CodingKeys: String, CodingKey {
        case id = "@id"
    }
}
