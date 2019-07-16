//
//  AggregateResponse.swift
//  App
//
//  Created by David van Enckevort on 16/07/2019.
//

import Foundation

struct BiobankDatasetResponse: Decodable {
    var data: BiobankDiseaseCounts

    private enum CodingKeys: String, CodingKey {
        case data = "aggs"
    }
}
