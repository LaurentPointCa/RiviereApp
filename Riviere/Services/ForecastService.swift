//
//  ForecastService.swift
//  Riviere
//

import Foundation

final class ForecastService {
    static let shared = ForecastService()
    
    private init() {}

    private static let jsonURL = URL(string: "https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.json")!
    static let imageURL = URL(string: "https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.png")!

    func fetchForecast() async throws -> ForecastResponse {
        let (data, _) = try await URLSession.shared.data(from: Self.jsonURL)
        let decoder = JSONDecoder()
        return try decoder.decode(ForecastResponse.self, from: data)
    }
}
