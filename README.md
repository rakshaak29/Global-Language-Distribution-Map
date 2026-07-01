# Global Language Distribution Map

A Flutter application that visualizes the world's **8,618 cataloged languages** across an interactive map. Built with a **KML-first, Liquid Galaxy-friendly** architecture.

Data sourced from **Glottolog** (linguistic classification) and **UNESCO Atlas of the World's Languages in Danger** (endangerment status).

---

## Features

### Home Screen
- **Searchable language list** with debounced input (300ms)
- **Endangerment filter chips** — color-coded with live counts
- **Expandable language tiles** showing name, family, region, status, coordinates, and description

###  Interactive Map
- **8,300+ language markers** displayed as name labels on the map
- **Marker clustering** — groups nearby languages at lower zoom levels
- **Endangerment-colored markers** — green (safe) → red (nearly extinct) → grey (extinct)
- **Search & navigate** — find any language and animate the camera to its location
- **Detail bottom sheet** — tap a marker for full language info
- **Filter by endangerment** — show only threatened, moribund, or extinct languages
- **Dark/light map tiles** — CartoDB Dark Matter & Positron, auto-switching with app theme

###  Settings
- Dark/light theme toggle
- Data source attributions (Glottolog, UNESCO)
- App version display

### 💾 KML Export (Liquid Galaxy-Ready)
- **Comprehensive KML Generation:** Converts search results or filtered views of languages into a standard `.kml` file.
- **Cross-Platform Save:** Uses platform-aware saving (downloads automatically on Web, writes directly on Mobile/Desktop).
- **Liquid Galaxy Styling:** Translates app endangerment color hexes into KML `aabbggrr` values.
- **LookAt Camera Angles:** Embeds precise `<LookAt>` details for every marker to support synchronized viewpoints on multi-display setups.
- **Visual Folders:** Organizes markers into distinct KML `<Folder>` structures based on endangerment levels for easy visibility control.

---

## 🏗️ Architecture & Folder Structure

The project follows a clean **MVVM (Model-View-ViewModel)** architecture structured under a **Layer-First** layout. Dependencies are managed using a central Service Locator via **GetIt** to enforce loose coupling and facilitate testing.

### Folder Structure
```
lib/
├── main.dart                      # App entry point, locator initialization & root providers
├── app/
│   ├── app.dart                   # MaterialApp.router root configuration
│   ├── router.dart                # Declarative navigation with GoRouter StatefulShellRoute
│   └── theme.dart                 # Dark/light theme definitions & status color palettes
├── core/
│   ├── di/
│   │   └── locator.dart           # GetIt service locator setup
│   ├── constants/
│   │   └── app_constants.dart     # System-wide constants & map configuration keys
│   └── widgets/
│       └── curved_header.dart     # Shared design system components
├── data/
│   ├── models/
│   │   └── language.dart          # Domain entity modeling language properties
│   ├── repositories/
│   │   └── language_repository.dart # Repository acting as the single source of truth
│   └── services/
│       ├── local_data_service.dart # JSON asset ingestion service
│       ├── liquid_galaxy_service.dart # SSH integration service for the LG Rig
│       ├── gemini_service.dart    # LLM queries to Gemini Pro
│       ├── tts_service.dart       # Local Text-To-Speech engine
│       └── kml_service.dart       # Static utility mapping data structures to KML
└── presentation/                  # Presentation layer organized by features
    ├── home/                      # Dashboard showing stats, quick-nav, and alerts
    ├── map/                       # Full map screens, marker clusterers, and detail sheets
    ├── families/                  # Gradient-styled language classification browsing
    ├── settings/                  # SSH, API key, display theme, and marker scale controllers
    ├── chat/                      # AI assistant query interface
    └── tours/                     # Guided fly-to sequences on Google Earth
```

### Key Architectural Concepts
1. **Dependency Injection (DI)**: Orchestrated via **GetIt** (configured in `locator.dart`). All core services and repositories are registered here and injected into view models via constructors. This decouples logic and allows easy mock-injection for testing.
2. **State Management**: Orchestrated via **Provider**. Screens watch corresponding ViewModels (which extend `ChangeNotifier`) to reactively rebuild.
3. **Layer Separation**: The data layer is completely independent of the UI representation. ViewModels process data from the repository layer and publish states consumed by presentation widgets.


### KML-First Design

The ViewModel layer works with **raw `Language` objects and `LatLng` coordinates** — no proprietary map types. This makes the architecture ready for:

| Future Feature | Extension Point |
|---|---|
| **KML Generation** | Iterate `filteredLanguages` → generate `<Placemark>` elements (Completed ✅) |
| **Liquid Galaxy** | Send `cameraPosition` as KML `<LookAt>` via SSH |
| **Guided Tours** | Sequence `selectLanguage()` + animated camera moves |
| **Heatmaps** | Use `filteredLanguages` coords with heatmap overlay |

---

##  Data Pipeline

A standalone Python script (`data_ingestion/ingest.py`) merges two data sources:

### Sources
| Source | Data | Records |
|---|---|---|
| **Glottolog CLDF** | Language names, families, coordinates, classification | 8,618 languages |
| **UNESCO Endangered Languages** | Endangerment degrees, descriptions | 2,431 matched |

### Processing
1. Download Glottolog `languages.csv` (filtered to actual languages, not dialects)
2. Join with `languoid.csv` for family names and country codes
3. Fuzzy-match UNESCO entries by name (threshold=80 using `rapidfuzz`)
4. Normalize into a unified `Language` model
5. Output `assets/data/languages.json` (~2.8 MB)

### Endangerment Distribution

| Status | Count |
|---|---|
| Not Endangered | 6,932 |
| Shifting | 411 |
| Nearly Extinct | 389 |
| Threatened | 376 |
| Moribund | 330 |
| Extinct | 180 |

---

##  Getting Started

### Prerequisites
- Flutter SDK `>=3.10.8`
- Python 3.x (only for data regeneration)

### Run the App
```bash
# Clone the repo
git clone https://github.com/rakshaak29/Global-Language-Map.git
cd Global-Language-Map

# Install dependencies
flutter pub get

# Run on web (recommended)
flutter run -d chrome

# Or run on a connected device
flutter run
```

### Regenerate Data (Optional)
The processed `languages.json` is already included. To regenerate from source:

```bash
cd data_ingestion
pip install -r requirements.txt
python ingest.py
```

---

##  Tech Stack

| Component | Technology |
|---|---|
| **Framework** | Flutter |
| **State Management** | Provider |
| **Navigation** | GoRouter |
| **Map** | flutter_map (OpenStreetMap) |
| **Clustering** | flutter_map_marker_cluster |
| **Tiles** | CartoDB (Dark Matter / Positron) |
| **XML Builder** | xml |
| **File Saving** | file_saver |
| **Typography** | Google Fonts (Inter) |
| **Data Ingestion** | Python (pandas, rapidfuzz) |

---

##  Screens

| Splash | Home | Map | Settings |
|---|---|---|---|
| Animated loading | Search + Filter | Clustered markers | Theme toggle |

---

##  Data Sources & Attribution

- **Glottolog** — Hammarström, Harald & Forkel, Robert & Haspelmath, Martin & Bank, Sebastian. *Glottolog 5.0*. Leipzig: Max Planck Institute for Evolutionary Anthropology. https://glottolog.org
- **UNESCO Atlas of the World's Languages in Danger** — Moseley, Christopher (ed.). 2010. *Atlas of the World's Languages in Danger*, 3rd edn. Paris, UNESCO Publishing.
- **Map Tiles** — © OpenStreetMap contributors © CARTO

---

##  License

This project is for educational and research purposes.

---

##  Roadmap

- [ ] Language Family View (color-coded by family)
- [ ] Endangered Languages Focus View
- [x] KML Generation & Export
- [ ] Liquid Galaxy Integration
- [ ] Guided Tours
- [ ] Heatmap Visualization
- [ ] Gemini AI Integration
