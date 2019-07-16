//
//  Dataset_Vapor_Extensions.swift
//  App
//
//  Created by David van Enckevort on 16/07/2019.
//

import Foundation
import Vapor

extension Dataset: ResponseEncodable {

    private enum RequestError: Error {
        case invalidURL(_ string: String)
        case decodeError
    }

    func encode(for req: Request) throws -> EventLoopFuture<Response> {
        let encoder = JSONEncoder()
        let body = try encoder.encode(self)
        let response = req.response(body)
        return req.future(response)
    }

    init(from aggregates: BiobankDiseaseCounts) throws  {
        guard let biobank = aggregates.biobanks.first,
            let disease = aggregates.diseases.first,
            let numberOfPatients = aggregates.counts.first?.first
            else {
                throw RequestError.decodeError
        }
        var components = URLComponents(string: "http://localhost:8080/")
        components?.queryItems = [
            URLQueryItem(name: "disease", value: disease.url.absoluteString),
            URLQueryItem(name: "biobank", value: biobank.id)
        ]
        guard let url = components?.url else {
            throw RequestError.invalidURL(components?.description ?? "Invalid URL components")
        }

        let theme = Theme(id: disease.url)
        let location = Location(city: biobank.city, country: biobank.country)
        let publisher = Publisher(name: biobank.institute, location: location)

        self.init(id: url, name: biobank.name, theme: [theme], publisher: publisher, numberOfPatients: numberOfPatients)
    }
}
