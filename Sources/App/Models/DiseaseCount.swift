//
//  DiseaseCountResponse.swift
//  App
//
//  Created by David van Enckevort on 15/07/2019.
//

import Foundation

struct DiseaseCount: Codable {
    let orpha: String
    let count: Int
    let biobank: String
}