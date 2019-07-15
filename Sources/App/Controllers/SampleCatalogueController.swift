//
//  SampleCatalogueController.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation
import Vapor

class SampleCatalogueController {
    private struct Aggregates<X, Y>: Decodable where X: Decodable, Y: Decodable {
        var matrix: [[Int]]
        var xLabels: [X]
        var yLabels: [Y]?
    }

    private struct AggregateResponse<T>: Decodable where T: Decodable {
        var aggs: T
    }

    let endPoint = "https://samples.rd-connect.eu/api/v2/rd_connect_Sample"

    enum RequestError: Error {
        case unknown
        case invalidURL(_ string: String)
        case decodeError
        case missingArgument
    }

    func count(_ req: Request) throws -> Future<Response> {
        guard var components = URLComponents(string: endPoint) else {
            throw RequestError.unknown
        }
        components.queryItems = [URLQueryItem(name: "aggs", value: "x==Disease;y==BiobankID")]

        switch (try? req.query.get(String.self, at: "disease"), try? req.query.get(String.self, at: "biobank")) {
        case (let disease, let biobank) where biobank == nil && disease != nil:
            components.queryItems?.append(URLQueryItem(name: "q", value: "Disease==\(disease!)"))
        case (let disease, let biobank) where disease == nil && biobank != nil:
            components.queryItems?.append(URLQueryItem(name: "q", value: "BiobankID==\(biobank!)"))
        case (let disease, let biobank) where biobank != nil && disease != nil:
            components.queryItems?.append(URLQueryItem(name: "q", value: "Disease==\(disease!);BiobankID==\(biobank!)"))
        default:
            throw RequestError.missingArgument
        }

        guard let url = components.url else {
            throw RequestError.invalidURL(components.description)
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let promise = req.eventLoop.newPromise(of: Response.self)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                promise.fail(error: error!)
                return
            }
            let decoder = JSONDecoder()
            let encoder = JSONEncoder()
            var diseaseCount = [DiseaseCount]()
            do {
                let response = try decoder.decode(AggregateResponse<Aggregates<Disease, Biobank>>.self, from: data)
                for (x, disease) in response.aggs.xLabels.enumerated() {
                    guard let biobanks = response.aggs.yLabels else {
                        promise.fail(error: RequestError.decodeError)
                        return
                    }
                    for (y, biobank) in biobanks.enumerated() {
                        diseaseCount.append(DiseaseCount(orpha: disease.IRI, count: response.aggs.matrix[x][y], biobank: biobank.name))
                    }
                }
                let body = try encoder.encode(diseaseCount)
                promise.succeed(result: req.response(body))
            } catch {
                promise.fail(error: error)
            }
        }
        task.resume()
        return promise.futureResult
    }
}
