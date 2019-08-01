//
//  Catalog.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation

struct Catalog: Codable {
    let id: URL
    let datasets: [URL]
    let type = "CatalogOfRegistries"
    let publisher: Publisher

    init(id: URL, datasets: [URL], publisher: Publisher) {
        self.id = id
        self.datasets = datasets
        self.publisher = publisher
    }

    private enum CodingKeys: String, CodingKey {
        case id = "@id", datasets, type, publisher
    }
}
