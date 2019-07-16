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
    let publisher: Publisher

    init(id: URL, datasets: [Dataset], publisher: Publisher) {
        self.id = id
        self.datasets = datasets
        self.publisher = publisher
    }

    private enum CodingKeys: String, CodingKey {
        case id = "@id", datasets = "dct:dataset", type, publisher
    }
}
