# Rivière

iOS app for monitoring river forecast data for CEHQ station 043301, with a forecast chart, data table, current water level, and a home screen widget.

## Features

- **Forecast chart** – Fetches and displays the forecast image; pinch to zoom, drag to pan, double-tap to reset.
- **Landscape mode** – Rotating to landscape shows the chart full-screen for easier reading.
- **Current water level** – Live level fetched from CEHQ station 043301 and displayed below the chart.
- **Danger zone** – The 22.5 m danger threshold is shown below the forecast table.
- **Forecast table** – JSON data shown in a table (day, date, flow m³/s, level m).
- **CEHQ button** – Opens CEHQ station 043301 in Safari.
- **Carillon button** – Opens the Carillon gauge page on rivièredesoutaouais.ca.
- **Widget** – Shows the 5th forecast day water level on the home screen.
- **Background refresh** – Hourly refresh to keep the widget up to date.

## Requirements

- Xcode 15+
- iOS 17+

## Setup

1. Open `Riviere.xcodeproj` in Xcode.
2. Select your development team under Signing & Capabilities for both the app and the **RiviereWidgetExtension** target.
3. Ensure the App Group `group.ca.point.riviere` exists in your Apple Developer account (or create it) and is enabled for both targets.
4. Build and run on a device or simulator.

## Data sources

- Forecast chart: [forecast.png](https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.png)
- Forecast JSON: [forecast.json](https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.json)
- Current level: [CEHQ station 043301](https://www.cehq.gouv.qc.ca/suivihydro/fichier_donnees.asp?NoStation=043301)
