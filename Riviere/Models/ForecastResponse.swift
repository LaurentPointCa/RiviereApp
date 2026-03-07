//
//  ForecastResponse.swift
//  Riviere
//

import Foundation

struct ForecastResponse: Codable {
    let generatedAt: String
    let anchorDate: String
    let forecast: [ForecastDay]

    enum CodingKeys: String, CodingKey {
        case generatedAt = "generated_at"
        case anchorDate = "anchor_date"
        case forecast
    }
}

struct ForecastDay: Codable, Identifiable {
    let day: Int
    let date: String
    let flowM3s: Double
    let levelM: Double

    enum CodingKeys: String, CodingKey {
        case day, date
        case flowM3s = "flow_m3s"
        case levelM = "level_m"
    }

    var id: Int { day }
}
