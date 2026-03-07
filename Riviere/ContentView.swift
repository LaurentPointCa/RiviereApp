//
//  ContentView.swift
//  Riviere
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ForecastViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ZoomableImageView(
                    imageURL: ForecastService.imageURL,
                    maxWidth: UIScreen.main.bounds.width
                )

                if viewModel.isLoading, viewModel.forecast.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding()
                } else if let error = viewModel.error {
                    Text("Erreur: \(error)")
                        .foregroundStyle(.red)
                        .padding()
                } else {
                    forecastTable
                }

                CEHQButton()
                    .padding()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.load()
        }
    }

    private var forecastTable: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prévisions")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                // Header row
                HStack {
                    Text("Jour")
                        .frame(width: 50, alignment: .leading)
                    Text("Date")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Débit (m³/s)")
                        .frame(width: 100, alignment: .trailing)
                    Text("Niveau (m)")
                        .frame(width: 100, alignment: .trailing)
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color(.systemGray6))

                Divider()

                // Data rows
                ForEach(viewModel.forecast) { day in
                    VStack(spacing: 0) {
                        HStack {
                            Text("J\(day.day)")
                                .frame(width: 50, alignment: .leading)
                            Text(day.date)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(String(format: "%.1f", day.flowM3s))
                                .frame(width: 100, alignment: .trailing)
                            Text(String(format: "%.3f", day.levelM))
                                .frame(width: 100, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        
                        if day.day != viewModel.forecast.last?.day {
                            Divider()
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }
}

struct CEHQButton: View {
    private let url = URL(string: "https://www.cehq.gouv.qc.ca/suivihydro/graphique.asp?NoStation=043301")!

    var body: some View {
        Button(action: openCEHQ) {
            Text("CEHQ")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
    }

    private func openCEHQ() {
        UIApplication.shared.open(url)
    }
}

@MainActor
final class ForecastViewModel: ObservableObject {
    @Published var forecast: [ForecastDay] = []
    @Published var isLoading = false
    @Published var error: String?

    func load() async {
        await refresh()
    }

    func refresh() async {
        isLoading = true
        error = nil
        do {
            print("🔄 Starting forecast refresh...")
            let response = try await ForecastService.shared.fetchForecast()
            print("✅ Forecast loaded: \(response.forecast.count) days")
            forecast = response.forecast
            print("✅ Data loaded")
        } catch {
            print("❌ Error: \(error)")
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    ContentView()
}
