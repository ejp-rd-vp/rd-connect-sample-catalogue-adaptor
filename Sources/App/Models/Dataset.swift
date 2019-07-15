//
//  Dataset.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation

struct Dataset: Encodable {
    let id: URL
    let type = "BiobankDataset"
    let name: String
    let theme: [Theme]
    let publisher: [Publisher]
    let samples: Int

    init(id: URL, name: String, theme: [Theme], publisher: [Publisher], samples: Int) {
        self.id = id
        self.name = name
        self.theme = theme
        self.publisher = publisher
        self.samples = samples
    }

    private enum CodingKeys: String, CodingKey {
        case id = "@id", type = "@type", name, theme, publisher, samples
    }
}
