# Rivière

Application iOS pour surveiller les prévisions de la rivière à la station CEHQ 043301, avec un graphique de prévisions, un tableau de données et le niveau d'eau actuel.

## Fonctionnalités

- **Graphique de prévisions** – Affiche le graphique de prévisions; pincez pour zoomer, glissez pour déplacer, double-touchez pour réinitialiser.
- **Mode paysage** – En mode paysage, le graphique s'affiche en plein écran pour une meilleure lisibilité.
- **Niveau d'eau actuel** – Niveau en temps réel récupéré depuis la station CEHQ 043301, affiché sous le graphique.
- **Zone de danger** – Le seuil de danger de 22,5 m est indiqué sous le tableau de prévisions.
- **Tableau de prévisions** – Données JSON affichées en tableau (jour, date, débit m³/s, niveau m).
- **Bouton CEHQ** – Ouvre la station CEHQ 043301 dans Safari.
- **Bouton Carillon** – Ouvre la page de la jauge de Carillon sur rivièredesoutaouais.ca.

## Exigences

- Xcode 15+
- iOS 17+

## Configuration

1. Ouvrez `Riviere.xcodeproj` dans Xcode.
2. Sélectionnez votre équipe de développement sous Signing & Capabilities pour la cible de l'application et pour **RiviereWidgetExtension**.
3. Assurez-vous que le App Group `group.ca.point.riviere` existe dans votre compte Apple Developer (ou créez-le) et est activé pour les deux cibles.
4. Compilez et exécutez sur un appareil ou un simulateur.

## Sources de données

- Graphique de prévisions : [forecast.png](https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.png)
- JSON de prévisions : [forecast.json](https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.json)
- Niveau actuel : [Station CEHQ 043301](https://www.cehq.gouv.qc.ca/suivihydro/fichier_donnees.asp?NoStation=043301)

---

# Rivière (English)

iOS app for monitoring river forecast data for CEHQ station 043301, with a forecast chart, data table, and current water level.

## Features

- **Forecast chart** – Fetches and displays the forecast image; pinch to zoom, drag to pan, double-tap to reset.
- **Landscape mode** – Rotating to landscape shows the chart full-screen for easier reading.
- **Current water level** – Live level fetched from CEHQ station 043301 and displayed below the chart.
- **Danger zone** – The 22.5 m danger threshold is shown below the forecast table.
- **Forecast table** – JSON data shown in a table (day, date, flow m³/s, level m).
- **CEHQ button** – Opens CEHQ station 043301 in Safari.
- **Carillon button** – Opens the Carillon gauge page on rivièredesoutaouais.ca.

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
