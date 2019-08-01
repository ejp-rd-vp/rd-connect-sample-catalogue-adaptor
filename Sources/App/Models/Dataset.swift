//
//  Dataset.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation

struct Dataset: Codable {
    let id: URL
    let type = "BiobankDataset"
    let name: String
    let theme: [Theme]
    let publisher: Publisher
    let numberOfPatients: Int

    init(id: URL, name: String, theme: [Theme], publisher: Publisher, numberOfPatients: Int) {
        self.id = id
        self.name = name
        self.theme = theme
        self.publisher = publisher
        self.numberOfPatients = numberOfPatients
    }

    private enum CodingKeys: String, CodingKey {
        case id = "@id", type = "@type", name, theme, publisher, numberOfPatients
    }
}
