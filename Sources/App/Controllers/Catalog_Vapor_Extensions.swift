//
//  Catalog_Vapor_Extensions.swift
//  App
//
//  Created by David van Enckevort on 16/07/2019.
//

import Foundation
import Vapor

extension Catalog: ResponseEncodable {
    func encode(for req: Request) throws -> EventLoopFuture<Response> {
        let encoder = JSONEncoder()
        let body = try encoder.encode(self)
        let response = req.response(body)
        return req.future(response)
    }

    init(from response: BiobankDatasetResponse) throws {
        var datasets = [URL]()
        for (x, biobank) in response.data.biobanks.enumerated() {
            for (y, disease) in response.data.diseases.enumerated() {
                let numberOfPatients = response.data.counts[x][y]

                if numberOfPatients > 0 {
                    if let url = URL(string: "http://localhost:8080/dataset/?disease=\(disease.id)&biobank=\(biobank.id)") {
                        datasets.append(url)
                    }
                }
            }
        }
        let id = URL(string: "https://samples.rd-connect.eu/")!
        let location = Location(city: "Groningen", country: "The Netherlands")
        let publisher = Publisher(name: "University Medical Center Groningen", location: location)
        self.init(id: id, datasets: datasets, publisher: publisher)
    }
}

