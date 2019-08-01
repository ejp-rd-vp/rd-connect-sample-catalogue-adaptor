//
//  SampleCatalogueController.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation
import Vapor

class SampleCatalogueController {

    func catalog(_ req: Request) throws -> Future<Catalog> {
        var components = catalogEndPoint
        if let filter = req.filter?.queryItem {
            components.queryItems?.append(filter)
        }
        guard let url = components.url else { throw RequestError.invalidURL(components.debugDescription)}

        let headers = [("Content-Type", "application/json")]
        let client = try req.client()
        return client.get(url, headers: HTTPHeaders(headers))
            .flatMap { return try $0.content.decode(BiobankDatasetResponse.self) }
            .map(to: Catalog.self) { return try Catalog(from: $0, for: self.localURL) }
    }

    func dataset(_ req: Request) throws -> Future<Dataset> {
        guard let filter = req.filter?.queryItem else { throw RequestError.missingParameters}
        var components = collectionEndPoint
        components.queryItems?.append(filter)
        guard let url = components.url else { throw RequestError.invalidURL(components.debugDescription)}

        let headers = [("Content-Type", "application/json")]
        let client = try req.client()
        return client.get(url, headers: HTTPHeaders(headers))
            .flatMap { return try $0.content.decode(BiobankDatasetResponse.self) }
            .map(to: Dataset.self) { return try Dataset(from: $0.data, for: self.localURL) }
    }

    init(catalog url: URL, localURL: URL) {
        self.catalogBaseURL = url
        self.localURL = localURL
    }

    private enum RequestError: Error {
        case invalidURL(_ string: String)
        case missingParameters
    }

    private var catalogBaseURL: URL
    private var localURL: URL

    private var collectionEndPoint: URLComponents {
        let endPoint = URL(string: "/api/v2/rd_connect_Sample?aggs=x==BiobankID;y==Disease;distinct==ParticipantID", relativeTo: catalogBaseURL)!
        return URLComponents(url: endPoint, resolvingAgainstBaseURL: true)!
    }

    private var catalogEndPoint: URLComponents {
        let endPoint = URL(string: "/api/v2/rd_connect_Sample?aggs=x==BiobankID;y==Disease", relativeTo: catalogBaseURL)!
        return URLComponents(url: endPoint, resolvingAgainstBaseURL: true)!
    }
}
