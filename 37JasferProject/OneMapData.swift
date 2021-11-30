//
//  OneMapData.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 9/11/21.
//

import Foundation

struct OneMapData: Codable {
    var found: Int
    var results: [Result]
}

struct Result: Codable {
    var LONGITUDE: String
    var LATITUDE: String
}
