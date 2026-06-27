import 'dart:async';
import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/data/services/liquid_galaxy_service.dart';

/// ViewModel for the Settings screen.
///
/// Manages theme, Liquid Galaxy connection, and display settings.
class SettingsViewModel extends ChangeNotifier {
  // Theme
  ThemeMode _themeMode = ThemeMode.light;

  // Liquid Galaxy connection
  String _host = '192.168.1.100';
  String _port = '22';
  String _username = 'lg';
  String _password = '';
  int _numberOfScreens = 3;

  final LiquidGalaxyService _lgService = LiquidGalaxyService();

  // Display settings
  bool _darkMapTheme = false;
  bool _showLanguageMarkers = true;
  bool _autoFlyOnSelect = false;
  double _markerSize = 1.0;

  // ─── Getters ────────────────────────────────────────────────────────────────

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  String get host => _host;
  String get port => _port;
  String get username => _username;
  String get password => _password;
  int get numberOfScreens => _numberOfScreens;

  LgConnectionStatus get connectionStatus => _lgService.status;
  bool get isConnected => _lgService.isConnected;
  bool get isConnecting => _lgService.isConnecting;
  String? get connectionError => _lgService.lastError;

  bool get darkMapTheme => _darkMapTheme;
  bool get showLanguageMarkers => _showLanguageMarkers;
  bool get autoFlyOnSelect => _autoFlyOnSelect;
  double get markerSize => _markerSize;

  LiquidGalaxyService get lgService => _lgService;

  String get connectionStatusText => _lgService.statusText;

  // ─── Theme ──────────────────────────────────────────────────────────────────

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  // ─── Liquid Galaxy Connection ────────────────────────────────────────────────

  void setHost(String value) {
    _host = value;
    notifyListeners();
  }

  void setPort(String value) {
    _port = value;
    notifyListeners();
  }

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setNumberOfScreens(int value) {
    _numberOfScreens = value;
    notifyListeners();
  }

  /// Connect to Liquid Galaxy using real LiquidGalaxyService.
  Future<void> testConnection() async {
    if (isConnecting) return;
    notifyListeners();

    final config = LgConnectionConfig(
      host: _host.trim(),
      port: int.tryParse(_port) ?? 22,
      username: _username.trim(),
      password: _password,
      numberOfScreens: _numberOfScreens,
    );

    await _lgService.connect(config);
    notifyListeners();
  }

  /// Disconnect from Liquid Galaxy.
  Future<void> disconnect() async {
    await _lgService.disconnect();
    notifyListeners();
  }

  /// Send pre-generated KML to the Liquid Galaxy.
  Future<bool> sendKml(String kmlContent) async {
    final result = await _lgService.sendKml(kmlContent);
    notifyListeners();
    return result;
  }

  /// Clear KML on the Liquid Galaxy.
  Future<bool> clearKml() async {
    final result = await _lgService.clearKml();
    notifyListeners();
    return result;
  }

  /// Fly to coordinates on Liquid Galaxy.
  Future<bool> flyToOnLg({
    required double latitude,
    required double longitude,
    String name = 'Location',
  }) async {
    final result = await _lgService.flyTo(
      latitude: latitude,
      longitude: longitude,
      name: name,
    );
    notifyListeners();
    return result;
  }

  /// Reboot the Liquid Galaxy rig.
  Future<bool> reboot() async {
    final result = await _lgService.reboot();
    notifyListeners();
    return result;
  }

  /// Relaunch Google Earth on the Liquid Galaxy.
  Future<bool> relaunchGoogleEarth() async {
    final result = await _lgService.relaunchGoogleEarth();
    notifyListeners();
    return result;
  }

  // ─── Display Settings ────────────────────────────────────────────────────────

  void toggleDarkMapTheme() {
    _darkMapTheme = !_darkMapTheme;
    notifyListeners();
  }

  void toggleShowLanguageMarkers() {
    _showLanguageMarkers = !_showLanguageMarkers;
    notifyListeners();
  }

  void toggleAutoFlyOnSelect() {
    _autoFlyOnSelect = !_autoFlyOnSelect;
    notifyListeners();
  }

  void setMarkerSize(double size) {
    _markerSize = size;
    notifyListeners();
  }
}
