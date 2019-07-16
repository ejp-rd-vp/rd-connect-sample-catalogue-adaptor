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

    func catalog(_ req: Request) throws -> Future<Response> {
        guard var components = URLComponents(string: endPoint) else {
            throw RequestError.unknown
        }
        components.queryItems = [
            URLQueryItem(name: "aggs", value: "x==BiobankID;y==Disease"),
        ]
        switch (try? req.query.get(String.self, at: "disease"), try? req.query.get(String.self, at: "biobank")) {
        case (let disease, let biobank) where biobank == nil && disease != nil:
            components.queryItems?.append(URLQueryItem(name: "q", value: "Disease==\(disease!)"))
        case (let disease, let biobank) where disease == nil && biobank != nil:
            components.queryItems?.append(URLQueryItem(name: "q", value: "BiobankID==\(biobank!)"))
        case (let disease, let biobank) where biobank != nil && disease != nil:
            components.queryItems?.append(URLQueryItem(name: "q", value: "Disease==\(disease!);BiobankID==\(biobank!)"))
        default:
            break
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
            encoder.outputFormatting = .prettyPrinted
            var datasets = [URL]()
            do {
                let response = try decoder.decode(AggregateResponse<Aggregates<Biobank, Disease>>.self, from: data)
                for (x, biobank) in response.aggs.xLabels.enumerated() {
                    guard let diseases = response.aggs.yLabels else {
                        promise.fail(error: RequestError.decodeError)
                        return
                    }
                    for (y, disease) in diseases.enumerated() {
                        let numberOfPatients = response.aggs.matrix[x][y]

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
                let catalog = Catalog(id: id, datasets: datasets, publisher: publisher)
                let body = try encoder.encode(catalog)
                promise.succeed(result: req.response(body))
            } catch {
                promise.fail(error: error)
            }
        }
        task.resume()
        return promise.futureResult
    }

    func dataset(_ req: Request) throws -> Future<Response> {
        let disease = try req.query.get(String.self, at: "disease")
        let biobank = try req.query.get(String.self, at: "biobank")
        guard var components = URLComponents(string: endPoint) else {
            throw RequestError.unknown
        }
        components.queryItems = [
            URLQueryItem(name: "aggs", value: "x==BiobankID;y==Disease;distinct==ParticipantID"),
            URLQueryItem(name: "q", value: "Disease==\(disease);BiobankID==\(biobank)")
        ]
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
            encoder.outputFormatting = .prettyPrinted

            do {
                let response = try decoder.decode(AggregateResponse<Aggregates<Biobank, Disease>>.self, from: data)
                guard let biobank = response.aggs.xLabels.first,
                    let disease = response.aggs.yLabels?.first,
                    let numberOfPatients = response.aggs.matrix.first?.first
                else {
                    promise.fail(error: RequestError.decodeError)
                    return
                }

                if numberOfPatients > 0 {
                    guard let url = URL(string: req.http.urlString, relativeTo: URL(string: "http://localhost:8080/")!) else {
                        promise.fail(error: RequestError.invalidURL(req.http.urlString))
                        return
                    }

                    let theme = Theme(id: disease.url)
                    let location = Location(city: biobank.city, country: biobank.country)
                    let publisher = Publisher(name: biobank.institute, location: location)

                    let dataset = Dataset(id: url, name: biobank.name, theme: [theme], publisher: publisher, numberOfPatients: numberOfPatients)
                    let body = try encoder.encode(dataset)
                    promise.succeed(result: req.response(body))
                }
            } catch {
                promise.fail(error: error)
            }
        }
        task.resume()
        return promise.futureResult
    }
}
