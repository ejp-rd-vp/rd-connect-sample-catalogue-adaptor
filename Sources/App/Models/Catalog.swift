//
//  Catalog.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation

struct Catalog: Encodable {
    let id: URL
    let datasets: [Dataset]
    let type = "dcat:Catalog"

    init(id: URL, datasets: [Dataset]) {
        self.id = id
        self.datasets = datasets
    }

    private enum CodingKeys: String, CodingKey {
        case id = "@id", datasets = "dct:dataset", type
    }
}
