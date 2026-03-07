//
//  ContentView.swift
//  Riviere
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ForecastViewModel()
    @State private var orientation = UIDevice.current.orientation

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            if isLandscape {
                // Landscape: Full-screen zoomable graph
                FullScreenZoomableImage(imageURL: ForecastService.imageURL)
                    .ignoresSafeArea()
            } else {
                // Portrait: Normal view
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ZoomableImageView(
                            imageURL: ForecastService.imageURL,
                            maxWidth: UIScreen.main.bounds.width
                        )

                        // Current level display
                        HStack {
                            Text("Niveau actuel: ")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if let currentLevel = viewModel.currentLevel {
                                Text(String(format: "%.2f m", currentLevel))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            } else {
                                Text("non-disponible")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .italic()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

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
                        }
                        
                        Spacer(minLength: 20)
                        
                        // Buttons at bottom
                        HStack(spacing: 12) {
                            CEHQButton()
                            CarillonButton()
                        }
                        .padding()
                    }
                }
                .refreshable {
                    await viewModel.refresh()
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
    private let url = URL(string: "https://www.cehq.gouv.qc.ca/suivihydro/graphique.asp?NoStation=043301")!

    var body: some View {
        Button(action: openCEHQ) {
            Text("CEHQ 043301")
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

struct CarillonButton: View {
    private let url = URL(string: "https://rivieredesoutaouais.ca/location/carillon-2/")!

    var body: some View {
        Button(action: openCarillon) {
            Text("Carillon")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
    }

    private func openCarillon() {
        UIApplication.shared.open(url)
    }
}

@MainActor
final class ForecastViewModel: ObservableObject {
    @Published var forecast: [ForecastDay] = []
    @Published var currentLevel: Double?
    @Published var isLoading = false
    @Published var error: String?

    func load() async {
        await refresh()
    }

    func refresh() async {
        isLoading = true
        error = nil
        do {
            // Fetch forecast (required)
            let response = try await ForecastService.shared.fetchForecast()
            forecast = response.forecast
            
            // Fetch current level (optional - don't fail if it doesn't work)
            do {
                let level = try await ForecastService.shared.fetchCurrentLevel()
                currentLevel = level
            } catch {
                // If fetching current level fails, just don't show it
                currentLevel = nil
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
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
                                    scale = min(max(scale * delta, minScale), maxScale)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    if scale > 1.0 {
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
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
