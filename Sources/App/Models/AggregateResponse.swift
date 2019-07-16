//
//  AggregateResponse.swift
//  App
//
//  Created by David van Enckevort on 16/07/2019.
//

import Foundation

struct AggregateResponse<T>: Decodable where T: Decodable {
    var aggs: T
}
