//
//  ContentView.swift
//  Riviere
//

import SwiftUI
import Charts

struct ContentView: View {
    @StateObject private var viewModel = ForecastViewModel()
    @State private var orientation = UIDevice.current.orientation

    private var appVersionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            if isLandscape {
                // Landscape: Full-screen zoomable graph
                FullScreenZoomableImage(imageURL: ForecastService.imageURL)
                    .ignoresSafeArea()
            } else {
                // Portrait: Normal view
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // 48-hour water level chart
                            WaterLevelChartView(readings: viewModel.waterLevelReadings)
                            
                            // Label for the 30-day forecast graph
                            Text("Données 30 derniers jours")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            AsyncImage(url: ForecastService.image30DayURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: UIScreen.main.bounds.width)
                                case .failure:
                                    Image(systemName: "photo")
                                        .frame(maxWidth: UIScreen.main.bounds.width, minHeight: 200)
                                        .foregroundStyle(.secondary)
                                case .empty:
                                    ProgressView()
                                        .frame(maxWidth: UIScreen.main.bounds.width, minHeight: 200)
                                @unknown default:
                                    EmptyView()
                                }
                            }

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
                                
                                // Danger zone warning
                                Text("Zone de danger: 22.5 m")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                    .padding(.horizontal)
                                    .padding(.top, 4)
                                
                                // 1 year forecast image
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Données 1 an")
                                        .font(.headline)
                                        .padding(.horizontal)
                                        .padding(.top, 16)
                                    
                                    AsyncImage(url: ForecastService.imageURL) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: UIScreen.main.bounds.width)
                                        case .failure:
                                            Image(systemName: "photo")
                                                .frame(maxWidth: UIScreen.main.bounds.width, minHeight: 200)
                                                .foregroundStyle(.secondary)
                                        case .empty:
                                            ProgressView()
                                                .frame(maxWidth: UIScreen.main.bounds.width, minHeight: 200)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                            
                            // Add space at bottom so content isn't hidden by buttons
                            Color.clear
                                .frame(height: 70)
                        }
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                    
                    // Buttons pinned at bottom
                    VStack(spacing: 0) {
                        Divider()
                        HStack(spacing: 8) {
                            CEHQButton()
                            CarillonButton()
                            CruesMTLButton()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        
                        // Build version
                        Text(appVersionString)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 8)
                    }
                    .background(Color(.systemBackground))
                }
            }
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
                HStack(spacing: 8) {
                    Text("Jour")
                        .frame(width: 40, alignment: .leading)
                    Text("Date")
                        .frame(width: 85, alignment: .leading)
                    Spacer()
                    Text("Débit (m³/s)")
                        .frame(width: 85, alignment: .trailing)
                    Text("Niveau (m)")
                        .frame(width: 80, alignment: .trailing)
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
                        HStack(spacing: 8) {
                            Text("J\(day.day)")
                                .frame(width: 40, alignment: .leading)
                            Text(day.date)
                                .frame(width: 85, alignment: .leading)
                            Spacer()
                            Text(String(format: "%.1f", day.flowM3s))
                                .frame(width: 85, alignment: .trailing)
                            Text(String(format: "%.3f", day.levelM))
                                .frame(width: 80, alignment: .trailing)
                        }
                        .font(.caption)
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
    private let url = URL(string: "https://www.cehq.gouv.qc.ca/prevision/previsions.asp?secteur=Archipel")!

    var body: some View {
        Button(action: openCEHQ) {
            Text("CEHQ")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
    }

    private func openCEHQ() {
        UIApplication.shared.open(url)
    }
}

struct CarillonButton: View {
    private let url = URL(string: "https://rivieredesoutaouais.ca/location/carillon-2/")!

    var body: some View {
        Button(action: openCarillon) {
            Text("Carillon")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
    }

    private func openCarillon() {
        UIApplication.shared.open(url)
    }
}

struct CruesMTLButton: View {
    private let url = URL(string: "https://www.cruesgrandmontreal.ca/")!

    var body: some View {
        Button(action: openCruesMTL) {
            Text("Crues MTL")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
    }

    private func openCruesMTL() {
        UIApplication.shared.open(url)
    }
}

@MainActor
final class ForecastViewModel: ObservableObject {
    @Published var forecast: [ForecastDay] = []
    @Published var waterLevelReadings: [WaterLevelReading] = []
    @Published var isLoading = false
    @Published var error: String?

    func load() async {
        await fetchAll(forceRefreshHistory: false)
    }

    func refresh() async {
        await fetchAll(forceRefreshHistory: true)
    }

    private func fetchAll(forceRefreshHistory: Bool) async {
        isLoading = true
        error = nil
        
        // Run fetches in parallel
        async let forecastResult = ForecastService.shared.fetchForecast()
        async let historyResult = fetchHistoryOrEmpty(forceRefresh: forceRefreshHistory)
        
        do {
            let response = try await forecastResult
            forecast = response.forecast
        } catch {
            self.error = error.localizedDescription
        }
        
        waterLevelReadings = await historyResult
        isLoading = false
    }
    
    nonisolated private func fetchHistoryOrEmpty(forceRefresh: Bool) async -> [WaterLevelReading] {
        (try? await ForecastService.shared.fetchWaterLevelHistory(forceRefresh: forceRefresh)) ?? []
    }
}

struct FullScreenZoomableImage: View {
    let imageURL: URL
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 4.0
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    let newScale = scale * delta
                                    scale = min(max(newScale, minScale), maxScale)
                                    
                                    // Reset offset if zooming out to 1.0
                                    if scale <= 1.0 {
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                    
                                    // Constrain offset to prevent image from going off screen
                                    if scale > 1.0 {
                                        let maxOffset = (geometry.size.width * (scale - 1)) / 2
                                        let maxOffsetY = (geometry.size.height * (scale - 1)) / 2
                                        
                                        offset.width = min(max(offset.width, -maxOffset), maxOffset)
                                        offset.height = min(max(offset.height, -maxOffsetY), maxOffsetY)
                                        lastOffset = offset
                                    }
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    if scale > 1.0 {
                                        let maxOffset = (geometry.size.width * (scale - 1)) / 2
                                        let maxOffsetY = (geometry.size.height * (scale - 1)) / 2
                                        
                                        let newOffsetX = lastOffset.width + value.translation.width
                                        let newOffsetY = lastOffset.height + value.translation.height
                                        
                                        // Constrain offset while dragging
                                        offset = CGSize(
                                            width: min(max(newOffsetX, -maxOffset), maxOffset),
                                            height: min(max(newOffsetY, -maxOffsetY), maxOffsetY)
                                        )
                                    }
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    scale = 2.5
                                }
                            }
                        }
                case .failure:
                    VStack {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                        Text("Erreur de chargement")
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                @unknown default:
                    EmptyView()
                }
            }
        }
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}
