//
//  Filter.swift
//  App
//
//  Created by David van Enckevort on 22/07/2019.
//

import Foundation
import Vapor

struct FilterParameters: Content {
    let biobank: String?
    let disease: String?
    var queryItem: URLQueryItem? {
        if let biobank = biobank, let disease = disease {
            return URLQueryItem(name: "q", value: "Disease==\(disease);BiobankID==\(biobank)")
        } else if let disease = disease {
            return URLQueryItem(name: "q", value: "Disease==\(disease)")
        } else if let biobank = biobank {
            return URLQueryItem(name: "q", value: "BiobankID==\(biobank)")
        }
        return nil
    }
}
