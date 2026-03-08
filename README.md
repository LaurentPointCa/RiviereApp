# Rivière

Application iOS pour surveiller les prévisions de la rivière à la station CEHQ 043301, avec un graphique de prévisions, un tableau de données et le niveau d'eau actuel.

## Fonctionnalités

- **Graphique 30 jours** – Affiche les données des 30 derniers jours en haut de l'écran.
- **Graphique de prévisions (1 an)** – Affiche le graphique de prévisions annuel; pincez pour zoomer, glissez pour déplacer, double-touchez pour réinitialiser.
- **Mode paysage** – En mode paysage, le graphique 1 an s'affiche en plein écran pour une meilleure lisibilité.
- **Niveau d'eau actuel** – Niveau en temps réel récupéré depuis la station CEHQ 043301, affiché sous le graphique.
- **Zone de danger** – Le seuil de danger de 22,5 m est indiqué sous le tableau de prévisions.
- **Tableau de prévisions** – Données JSON affichées en tableau (jour, date, débit m³/s, niveau m).
- **Bouton CEHQ** – Ouvre la station CEHQ 043301 dans Safari.
- **Bouton Carillon** – Ouvre la page de la jauge de Carillon sur rivièredesoutaouais.ca.
- **Bouton Crues MTL** – Ouvre le site Crues Grand Montréal dans Safari.

## Exigences

- Xcode 15+
- iOS 17+

## Configuration

1. Ouvrez `Riviere.xcodeproj` dans Xcode.
2. Sélectionnez votre équipe de développement sous Signing & Capabilities.
3. Compilez et exécutez sur un appareil ou un simulateur.

## Sources de données

- Graphique 30 jours : [forecast_30d.png](https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast_30d.png)
- Graphique de prévisions (1 an) : [forecast.png](https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.png)
- JSON de prévisions : [forecast.json](https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.json)
- Niveau actuel : [Station CEHQ 043301](https://www.cehq.gouv.qc.ca/suivihydro/fichier_donnees.asp?NoStation=043301)

---

# Rivière (English)

iOS app for monitoring river forecast data for CEHQ station 043301, with a forecast chart, data table, and current water level.

## Features

- **30-day chart** – Displays the last 30 days of data at the top of the screen.
- **Forecast chart (1 year)** – Displays the annual forecast image; pinch to zoom, drag to pan, double-tap to reset.
- **Landscape mode** – Rotating to landscape shows the 1-year chart full-screen for easier reading.
- **Current water level** – Live level fetched from CEHQ station 043301 and displayed below the chart.
- **Danger zone** – The 22.5 m danger threshold is shown below the forecast table.
- **Forecast table** – JSON data shown in a table (day, date, flow m³/s, level m).
- **CEHQ button** – Opens CEHQ station 043301 in Safari.
- **Carillon button** – Opens the Carillon gauge page on rivièredesoutaouais.ca.
- **Crues MTL button** – Opens the Crues Grand Montréal website in Safari.

## Requirements

- Xcode 15+
- iOS 17+

## Setup

1. Open `Riviere.xcodeproj` in Xcode.
2. Select your development team under Signing & Capabilities.
3. Build and run on a device or simulator.

## Data sources

- 30-day chart: [forecast_30d.png](https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast_30d.png)
- Forecast chart (1 year): [forecast.png](https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.png)
- Forecast JSON: [forecast.json](https://raw.githubusercontent.com/LaurentPointCa/riviere/refs/heads/master/docs/forecast.json)
- Current level: [CEHQ station 043301](https://www.cehq.gouv.qc.ca/suivihydro/fichier_donnees.asp?NoStation=043301)
