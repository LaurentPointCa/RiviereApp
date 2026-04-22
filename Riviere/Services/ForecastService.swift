//
//  ForecastService.swift
//  Riviere
//

import Foundation

final class ForecastService {
    static let shared = ForecastService()
    
    private init() {}

    // Disk-persisted cache for water level history (1 hour TTL)
    private let cacheDuration: TimeInterval = 3600
    
    private static var cacheFileURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("water_level_cache.json")
    }

    private static let jsonURL = URL(string: "https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.json")!
    static let imageURL = URL(string: "https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.png")!
    static let image30DayURL = URL(string: "https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast_30d.png")!
    private static let currentLevelURL = URL(string: "https://www.cehq.gouv.qc.ca/suivihydro/fichier_donnees.asp?NoStation=043301")!

    func fetchForecast() async throws -> ForecastResponse {
        let (data, _) = try await URLSession.shared.data(from: Self.jsonURL)
        let decoder = JSONDecoder()
        return try decoder.decode(ForecastResponse.self, from: data)
    }
    
    
    func fetchWaterLevelHistory(hours: Int = 120, forceRefresh: Bool = false) async throws -> [WaterLevelReading] {
        // Return cached data if still valid and not forcing refresh
        if !forceRefresh, let cached = loadCache() {
            return cached
        }
        
        let (data, _) = try await URLSession.shared.data(from: Self.currentLevelURL)
        
        let dataString: String
        if let s = String(data: data, encoding: .utf8) {
            dataString = s
        } else if let s = String(data: data, encoding: .windowsCP1252) {
            dataString = s
        } else {
            throw NSError(domain: "ForecastService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Unable to decode data"])
        }
        
        let readings = parseWaterLevelHistory(from: dataString, hours: hours)
        saveCache(readings)
        return readings
    }
    
    private struct CacheEntry: Codable {
        let timestamp: Date
        let readings: [WaterLevelReading]
    }
    
    private func loadCache() -> [WaterLevelReading]? {
        guard let data = try? Data(contentsOf: Self.cacheFileURL),
              let entry = try? JSONDecoder().decode(CacheEntry.self, from: data),
              Date().timeIntervalSince(entry.timestamp) < cacheDuration else {
            return nil
        }
        return entry.readings
    }
    
    private func saveCache(_ readings: [WaterLevelReading]) {
        let entry = CacheEntry(timestamp: Date(), readings: readings)
        if let data = try? JSONEncoder().encode(entry) {
            try? data.write(to: Self.cacheFileURL)
        }
    }
    
    private func parseWaterLevelHistory(from text: String, hours: Int) -> [WaterLevelReading] {
        let lines = text.components(separatedBy: .newlines)
        var readings: [WaterLevelReading] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "America/Montreal")
        
        let cutoff = Date().addingTimeInterval(-Double(hours) * 3600)
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            
            let components = trimmed.components(separatedBy: "\t")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            // Need at least 3 columns: date, time, level
            guard components.count >= 3 else { continue }
            
            let dateStr = components[0]
            let timeStr = components[1]
            
            // Validate date format (YYYY-MM-DD)
            guard dateStr.count == 10, dateStr.contains("-") else { continue }
            
            guard let date = dateFormatter.date(from: "\(dateStr) \(timeStr)") else { continue }
            guard date >= cutoff else { continue }
            
            let levelStr = components[2].replacingOccurrences(of: ",", with: ".")
            guard let level = Double(levelStr), level > 15, level < 25 else { continue }
            
            readings.append(WaterLevelReading(date: date, level: level))
        }
        
        // Sort chronologically (data arrives most-recent-first)
        readings.sort { $0.date < $1.date }
        return readings
    }
    
}
