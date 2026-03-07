# Rivière

iOS app for viewing river forecast data: image, table, and a home screen widget with the day‑5 water level.

## Features

- **Forecast image** – Fetches and displays the forecast chart; double-tap to zoom, drag to pan.
- **Forecast table** – JSON data shown in a table (day, date, flow m³/s, level m).
- **CEHQ button** – Opens the CEHQ station page in Safari.
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

- Image: [forecast.png](https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.png)
- JSON: [forecast.json](https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.json)
