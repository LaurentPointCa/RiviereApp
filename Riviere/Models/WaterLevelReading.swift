//
//  WaterLevelReading.swift
//  Riviere
//

import Foundation

struct WaterLevelReading: Identifiable, Codable {
    let id: UUID
    let date: Date
    let level: Double
    
    init(date: Date, level: Double) {
        self.id = UUID()
        self.date = date
        self.level = level
    }
}
