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
    static let image30DayURL = URL(string: "https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast_30d.png")!
    private static let currentLevelURL = URL(string: "https://www.cehq.gouv.qc.ca/suivihydro/fichier_donnees.asp?NoStation=043301")!

    func fetchForecast() async throws -> ForecastResponse {
        let (data, _) = try await URLSession.shared.data(from: Self.jsonURL)
        let decoder = JSONDecoder()
        return try decoder.decode(ForecastResponse.self, from: data)
    }
    
    func fetchCurrentLevel() async throws -> Double {
        let (data, _) = try await URLSession.shared.data(from: Self.currentLevelURL)
        
        // Try UTF-8 first
        if let dataString = String(data: data, encoding: .utf8) {
            return try parseWaterLevel(from: dataString)
        }
        
        // Try Windows-1252 encoding (common for CEHQ)
        if let dataString = String(data: data, encoding: .windowsCP1252) {
            return try parseWaterLevel(from: dataString)
        }
        
        throw NSError(domain: "ForecastService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to decode data"])
    }
    
    private func parseWaterLevel(from text: String) throws -> Double {
        let lines = text.components(separatedBy: .newlines)
        
        // Look at each line to find water level data
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            
            // Try different separators
            // First try tab
            var components = trimmed.components(separatedBy: "\t").filter { !$0.isEmpty }
            
            // If no tabs, try multiple spaces
            if components.count < 2 {
                components = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            }
            
            // Look through all components for a valid water level number
            for component in components {
                let cleaned = component.trimmingCharacters(in: .whitespaces)
                // Handle French decimal format (comma)
                let normalized = cleaned.replacingOccurrences(of: ",", with: ".")
                
                if let level = Double(normalized) {
                    // Water level for Carillon should be between 15 and 25 meters typically
                    if level > 15 && level < 25 {
                        return level
                    }
                }
            }
        }
        
        throw NSError(domain: "ForecastService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unable to parse water level"])
    }
}
