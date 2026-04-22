//
//  WaterLevelChartView.swift
//  Riviere
//

import SwiftUI
import Charts

struct WaterLevelChartView: View {
    let readings: [WaterLevelReading]

    private let dangerLevel: Double = 22.5

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Niveau 5 derniers jours")
                    .font(.headline)
                if let last = readings.last {
                    Spacer()
                    Text("Actuel: \(String(format: "%.2f", last.level)) m")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            if readings.isEmpty {
                Text("Données non disponibles")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, minHeight: 180, alignment: .center)
                    .padding(.horizontal)
            } else {
                Chart {
                    ForEach(readings) { reading in
                        LineMark(
                            x: .value("Heure", reading.date),
                            y: .value("Niveau (m)", reading.level)
                        )
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }

                    ForEach(readings) { reading in
                        AreaMark(
                            x: .value("Heure", reading.date),
                            y: .value("Niveau (m)", reading.level)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.blue.opacity(0.2), .blue.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }

                    RuleMark(y: .value("Danger", dangerLevel))
                        .foregroundStyle(.red.opacity(0.7))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Danger 22.5 m")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                }
                .chartYScale(domain: yAxisDomain)
                .chartXAxis {
                    AxisMarks(values: xAxisDates) { value in
                        if let date = value.as(Date.self) {
                            let hour = Calendar.current.component(.hour, from: date)
                            AxisGridLine(stroke: hour == 0
                                ? StrokeStyle(lineWidth: 1)
                                : StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                            AxisTick()
                            AxisValueLabel {
                                VStack(spacing: 2) {
                                    Text("\(hour)h")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    if hour == 0 {
                                        Text(date, format: .dateTime.day(.defaultDigits))
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .frame(height: 200)
                .clipped()
                .padding(.horizontal)
            }
        }
    }
}

private extension WaterLevelChartView {
    /// Calendar-aligned dates every 12h (midnight and noon) spanning the data range
    var xAxisDates: [Date] {
        guard let first = readings.first?.date,
              let last = readings.last?.date else { return [] }
        
        let calendar = Calendar.current
        // Start from midnight of the first reading's day
        let startOfDay = calendar.startOfDay(for: first)
        
        var dates: [Date] = []
        var current = startOfDay
        while current <= last {
            if current >= first {
                dates.append(current)
            }
            current = calendar.date(byAdding: .hour, value: 12, to: current)!
        }
        return dates
    }
    
    /// Y axis domain with padding, always including the danger level
    var yAxisDomain: ClosedRange<Double> {
        guard let minLevel = readings.map(\.level).min(),
              let maxLevel = readings.map(\.level).max() else {
            return 20.0...23.0
        }
        let effectiveMax = max(maxLevel, dangerLevel)
        let effectiveMin = min(minLevel, dangerLevel - 1)
        let range = effectiveMax - effectiveMin
        return (effectiveMin - range * 0.1)...(effectiveMax + range * 0.2)
    }
}

#Preview {
    let count = 480 // 5 days of 15-min readings
    let sampleReadings: [WaterLevelReading] = (0..<count).map { i in
        let date = Date().addingTimeInterval(-Double(count - 1 - i) * 900)
        let level = 21.9 + 0.15 * sin(Double(i) / 20.0) + Double(i) * 0.0002
        return WaterLevelReading(date: date, level: level)
    }
    WaterLevelChartView(readings: sampleReadings)
}
