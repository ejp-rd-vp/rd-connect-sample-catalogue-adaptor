//
//  Aggregates.swift
//  App
//
//  Created by David van Enckevort on 16/07/2019.
//

import Foundation

struct Aggregates<X, Y>: Decodable where X: Decodable, Y: Decodable {
    var matrix: [[Int]]
    var xLabels: [X]
    var yLabels: [Y]
}
