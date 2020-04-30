//
//  Dataset_Vapor_Extensions.swift
//  App
//
//  Created by David van Enckevort on 16/07/2019.
//

import Foundation
import Vapor
import EJPRDMetadata

extension Dataset: Content {

    private enum RequestError: Error {
        case invalidURL(_ string: String)
        case decodeError
    }

    init(from aggregates: BiobankDiseaseCounts, for url: URL) throws  {
        guard let biobank = aggregates.biobanks.first,
            let disease = aggregates.diseases.first,
            let numberOfPatients = aggregates.counts.first?.first
            else {
                throw RequestError.decodeError
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.path = "/dataset/"
        components?.queryItems = [
            URLQueryItem(name: "disease", value: disease.compactID),
            URLQueryItem(name: "biobank", value: biobank.id)
        ]
        guard let url = components?.url else {
            throw RequestError.invalidURL(components?.description ?? "Invalid URL components")
        }

        var themes = [Theme]()
        if let theme = disease.url {
            let theme = Theme(id: theme)
            themes.append(theme)
        }
        let location = Location(city: biobank.city, country: biobank.country)
        let publisher = Publisher(name: biobank.institute, location: location)

        self.init(id: url, name: biobank.name, theme: themes, publisher: publisher, numberOfPatients: numberOfPatients)
    }
}
