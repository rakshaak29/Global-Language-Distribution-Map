import 'dart:async';
import 'package:flutter/material.dart';

/// Connection status for Liquid Galaxy.
enum LgConnectionStatus { disconnected, connecting, connected, error }

/// ViewModel for the Settings screen.
///
/// Manages theme, Liquid Galaxy connection, and display settings.
class SettingsViewModel extends ChangeNotifier {
  // Theme
  ThemeMode _themeMode = ThemeMode.light;

  // Liquid Galaxy connection
  String _ipAddress = '192.168.1.100';
  String _port = '2222';
  LgConnectionStatus _connectionStatus = LgConnectionStatus.disconnected;
  String? _connectionError;

  // Display settings
  bool _darkMapTheme = false;
  bool _showLanguageMarkers = true;
  bool _autoFlyOnSelect = false;
  double _markerSize = 1.0;

  // ─── Getters ────────────────────────────────────────────────────────────────

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  String get ipAddress => _ipAddress;
  String get port => _port;
  LgConnectionStatus get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus == LgConnectionStatus.connected;
  bool get isConnecting => _connectionStatus == LgConnectionStatus.connecting;
  String? get connectionError => _connectionError;

  bool get darkMapTheme => _darkMapTheme;
  bool get showLanguageMarkers => _showLanguageMarkers;
  bool get autoFlyOnSelect => _autoFlyOnSelect;
  double get markerSize => _markerSize;

  String get connectionStatusText {
    switch (_connectionStatus) {
      case LgConnectionStatus.connected:
        return 'Connected!';
      case LgConnectionStatus.connecting:
        return 'Connecting...';
      case LgConnectionStatus.error:
        return 'Connection Failed';
      case LgConnectionStatus.disconnected:
        return 'Disconnected';
    }
  }

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

  void setIpAddress(String value) {
    _ipAddress = value;
    notifyListeners();
  }

  void setPort(String value) {
    _port = value;
    notifyListeners();
  }

  /// Test connection to Liquid Galaxy (stub — actual SSH not implemented).
  Future<void> testConnection() async {
    if (_isConnecting) return;
    _connectionStatus = LgConnectionStatus.connecting;
    _connectionError = null;
    notifyListeners();

    // Simulate network attempt
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes: succeed if IP looks valid
    final isValidIp = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$')
        .hasMatch(_ipAddress.trim());

    if (isValidIp && _port.isNotEmpty) {
      _connectionStatus = LgConnectionStatus.connected;
    } else {
      _connectionStatus = LgConnectionStatus.error;
      _connectionError = 'Could not connect to $_ipAddress:$_port';
    }
    notifyListeners();
  }

  void disconnect() {
    _connectionStatus = LgConnectionStatus.disconnected;
    _connectionError = null;
    notifyListeners();
  }

  bool get _isConnecting =>
      _connectionStatus == LgConnectionStatus.connecting;

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
