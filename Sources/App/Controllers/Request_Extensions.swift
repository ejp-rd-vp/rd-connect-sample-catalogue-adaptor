//
//  Request_Extensions.swift
//  App
//
//  Created by David van Enckevort on 30/07/2019.
//

import Foundation
import Vapor
import os

extension Request {
    var url: URL? {
        let baseURL = Environment.get("baseURL") ?? "http://localhost:8080/"
        print(baseURL)
        return URL(string: baseURL)
    }

    var filter: FilterParameters? {
        return try? query.decode(FilterParameters.self)
    }
}
