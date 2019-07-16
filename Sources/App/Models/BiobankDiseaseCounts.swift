//
//  Aggregates.swift
//  App
//
//  Created by David van Enckevort on 16/07/2019.
//

import Foundation

struct BiobankDiseaseCounts: Decodable {
    var counts: [[Int]]
    var biobanks: [Biobank]
    var diseases: [Disease]

    private enum CodingKeys: String, CodingKey {
        case counts = "matrix", biobanks = "xLabels", diseases = "yLabels"
    }
}
