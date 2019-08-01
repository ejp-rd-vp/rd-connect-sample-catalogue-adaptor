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
    var filter: FilterParameters? {
        return try? query.decode(FilterParameters.self)
    }
}
