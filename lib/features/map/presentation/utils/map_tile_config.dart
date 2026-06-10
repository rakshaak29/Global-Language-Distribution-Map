/// Map tile configuration for dark and light themes.
///
/// Uses OpenStreetMap-compatible tile providers that don't require API keys.
/// This keeps the architecture open and KML-friendly — the tile layer is
/// just a visual base, not a proprietary dependency.
class MapTileConfig {
  MapTileConfig._();

  /// CartoDB Dark Matter — matches the app's dark indigo/violet theme.
  /// Note: flutter_map v7 removed subdomains — use direct URL.
  static const String darkTileUrl =
      'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

  /// CartoDB Positron — clean, minimal light theme.
  static const String lightTileUrl =
      'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';

  /// Standard OpenStreetMap tiles as fallback.
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Attribution for CartoDB tiles.
  static const String cartoAttribution =
      '&copy; OpenStreetMap contributors &copy; CARTO';

  /// Attribution for OSM tiles.
  static const String osmAttribution =
      '&copy; OpenStreetMap contributors';

  /// Returns the appropriate tile URL for the given brightness.
  static String getTileUrl(bool isDarkMode) {
    return isDarkMode ? darkTileUrl : lightTileUrl;
  }
}
