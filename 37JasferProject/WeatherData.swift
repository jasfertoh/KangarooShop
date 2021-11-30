//
//  fetchWeather.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 8/11/21.
//

import Foundation

struct WeatherData: Codable {
//    var weather: [Weather]
    var weather: [Weather]
    var main: Main
}
//
struct Weather: Codable {
    var main: String
    var description: String
}

struct Main: Codable {
    var temp: Double
}
