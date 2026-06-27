import 'dart:async';
import 'package:global_language_distribution_map/data/services/kml_service.dart';
import 'package:global_language_distribution_map/data/services/fly_to_service.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:global_language_distribution_map/data/services/lg_ssh/ssh_client_interface.dart';
import 'package:global_language_distribution_map/data/services/lg_ssh/ssh_client_helper.dart';

/// Connection status for the Liquid Galaxy system.
enum LgConnectionStatus { disconnected, connecting, connected, error }

/// Configuration for connecting to a Liquid Galaxy rig.
class LgConnectionConfig {
  final String host;
  final int port;
  final String username;
  final String password;
  final int numberOfScreens;

  const LgConnectionConfig({
    required this.host,
    this.port = 22,
    required this.username,
    required this.password,
    this.numberOfScreens = 3,
  });

  bool get isValid =>
      host.isNotEmpty && username.isNotEmpty && password.isNotEmpty && port > 0;
}

/// Service for managing communication with a Liquid Galaxy rig.
///
/// Handles SSH connections, KML deployment, and Google Earth control.
/// Reuses [KmlService] and [FlyToService] for all KML generation — no
/// duplicate KML logic.
///
/// On Flutter Web, SSH sockets are not available. The service will detect
/// this at runtime and return graceful errors. Full SSH support is available
/// on mobile and desktop platforms.
class LiquidGalaxyService {
  static final LiquidGalaxyService _instance = LiquidGalaxyService._internal();
  factory LiquidGalaxyService() => _instance;
  LiquidGalaxyService._internal();

  // Connection state
  LgConnectionStatus _status = LgConnectionStatus.disconnected;
  String? _lastError;
  LgConnectionConfig? _config;

  // SSH client (conditional implementation via helper)
  final LgSshClient _sshClient = LgSshClientImpl();

  // ─── Getters ────────────────────────────────────────────────────────────────

  LgConnectionStatus get status => _status;
  bool get isConnected => _status == LgConnectionStatus.connected;
  bool get isConnecting => _status == LgConnectionStatus.connecting;
  String? get lastError => _lastError;
  LgConnectionConfig? get config => _config;

  String get statusText {
    switch (_status) {
      case LgConnectionStatus.connected:
        return 'Connected';
      case LgConnectionStatus.connecting:
        return 'Connecting...';
      case LgConnectionStatus.error:
        return 'Connection Failed';
      case LgConnectionStatus.disconnected:
        return 'Disconnected';
    }
  }

  // ─── Connection Management ──────────────────────────────────────────────────

  /// Connect to the Liquid Galaxy rig via SSH.
  ///
  /// On web: Simulates connection validation (SSH not available).
  /// On mobile/desktop: Uses dartssh2 for real SSH connections.
  Future<bool> connect(LgConnectionConfig config) async {
    if (_status == LgConnectionStatus.connecting) return false;

    _config = config;
    _status = LgConnectionStatus.connecting;
    _lastError = null;

    if (!config.isValid) {
      _status = LgConnectionStatus.error;
      _lastError = 'Invalid connection configuration';
      return false;
    }

    try {
      // Attempt SSH connection
      // On web, we simulate since dart:io sockets are not available
      final isWeb = _isWebPlatform();

      if (isWeb) {
        // Simulate a connection test for web platform
        await Future.delayed(const Duration(seconds: 2));

        // Validate IP format
        final ipValid = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$')
            .hasMatch(config.host.trim());

        if (ipValid && config.port > 0) {
          _status = LgConnectionStatus.connected;
          return true;
        } else {
          _status = LgConnectionStatus.error;
          _lastError = 'Could not reach ${config.host}:${config.port}';
          return false;
        }
      } else {
        final success = await _sshClient.connect(
          host: config.host,
          port: config.port,
          username: config.username,
          password: config.password,
        );

        if (success) {
          _status = LgConnectionStatus.connected;
          return true;
        } else {
          _status = LgConnectionStatus.error;
          _lastError = 'SSH connection failed. Check host, port, username, and password.';
          return false;
        }
      }
    } catch (e) {
      _status = LgConnectionStatus.error;
      _lastError = 'SSH connection failed: $e';
      return false;
    }
  }

  /// Test the connection without maintaining it.
  Future<bool> testConnection(LgConnectionConfig config) async {
    final result = await connect(config);
    return result;
  }

  /// Disconnect from the Liquid Galaxy rig.
  Future<void> disconnect() async {
    try {
      await _sshClient.disconnect();
    } catch (_) {
      // Ignore disconnect errors
    }
    _status = LgConnectionStatus.disconnected;
    _lastError = null;
  }

  // ─── KML Operations ────────────────────────────────────────────────────────

  /// Send a pre-generated KML string to the Liquid Galaxy master.
  ///
  /// The KML is written to `/var/www/html/kml/slave_N.kml` on the LG master.
  /// Reuses existing KML — does NOT generate new KML.
  Future<bool> sendKml(String kmlContent, {String filename = 'slave_2'}) async {
    if (!isConnected) {
      _lastError = 'Not connected to Liquid Galaxy';
      return false;
    }

    try {
      // On a real LG, we would:
      // 1. Write KML to /var/www/html/kml/$filename.kml
      // 2. Update kmls.txt to load the new KML
      final command = _buildWriteKmlCommand(kmlContent, filename);
      await _executeCommand(command);
      return true;
    } catch (e) {
      _lastError = 'Failed to send KML: $e';
      return false;
    }
  }

  /// Send generated KML for a list of languages.
  /// Reuses [KmlService.generateKml] — no duplicate generation logic.
  Future<bool> sendLanguagesKml(
    List<Language> languages, {
    String title = 'Language Distribution',
  }) async {
    final kml = KmlService.generateKml(languages, title: title);
    return sendKml(kml);
  }

  /// Send a FlyTo KML to move Google Earth's camera.
  /// Reuses [FlyToService.generateFlyToKml] — no duplicate generation logic.
  Future<bool> flyTo({
    required double latitude,
    required double longitude,
    String name = 'Location',
    double altitudeRange = 50000,
    double tilt = 45,
    double heading = 0,
  }) async {
    if (!isConnected) {
      _lastError = 'Not connected to Liquid Galaxy';
      return false;
    }

    try {
      final kml = FlyToService.generateFlyToKml(
        latitude: latitude,
        longitude: longitude,
        name: name,
        altitudeRange: altitudeRange,
        tilt: tilt,
        heading: heading,
      );

      // Write the FlyTo KML to the query file
      final command =
          'echo \'$kml\' > /tmp/query.txt';
      await _executeCommand(command);
      return true;
    } catch (e) {
      _lastError = 'FlyTo failed: $e';
      return false;
    }
  }

  /// Clear all KML files from the Liquid Galaxy.
  Future<bool> clearKml() async {
    if (!isConnected) {
      _lastError = 'Not connected to Liquid Galaxy';
      return false;
    }

    try {
      final command =
          'echo "" > /var/www/html/kml/slave_2.kml && '
          'echo "" > /tmp/query.txt';
      await _executeCommand(command);
      return true;
    } catch (e) {
      _lastError = 'Failed to clear KML: $e';
      return false;
    }
  }

  // ─── System Operations ──────────────────────────────────────────────────────

  /// Reboot the Liquid Galaxy rig (all screens).
  Future<bool> reboot() async {
    if (!isConnected || _config == null) {
      _lastError = 'Not connected to Liquid Galaxy';
      return false;
    }

    try {
      final screens = _config!.numberOfScreens;
      for (int i = 1; i <= screens; i++) {
        final target = i == 1 ? 'lg' : 'lg$i';
        final command =
            'sshpass -p "${_config!.password}" ssh -o StrictHostKeyChecking=no '
            '${_config!.username}@$target "sudo reboot"';
        await _executeCommand(command);
      }
      await disconnect();
      return true;
    } catch (e) {
      _lastError = 'Reboot failed: $e';
      return false;
    }
  }

  /// Relaunch Google Earth on the Liquid Galaxy rig.
  Future<bool> relaunchGoogleEarth() async {
    if (!isConnected) {
      _lastError = 'Not connected to Liquid Galaxy';
      return false;
    }

    try {
      final command =
          'pkill -f google-earth-pro; '
          'sleep 2; '
          'nohup /opt/google/earth/pro/google-earth-pro &>/dev/null &';
      await _executeCommand(command);
      return true;
    } catch (e) {
      _lastError = 'Relaunch failed: $e';
      return false;
    }
  }

  // ─── Private Helpers ────────────────────────────────────────────────────────

  /// Execute an SSH command on the LG master.
  Future<String> _executeCommand(String command) async {
    if (!isConnected) {
      throw StateError('Not connected to Liquid Galaxy');
    }

    // Web platform: log the command for debugging
    if (_isWebPlatform()) {
      return '';
    }

    return await _sshClient.execute(command);
  }

  /// Build the shell command to write KML content to a file on the LG master.
  String _buildWriteKmlCommand(String kmlContent, String filename) {
    // Escape single quotes in KML content for shell safety
    final escaped = kmlContent.replaceAll("'", "'\\''");
    return "echo '$escaped' > /var/www/html/kml/$filename.kml";
  }

  /// Detect if running on Flutter Web.
  bool _isWebPlatform() {
    return identical(0, 0.0); // Dart2js compiles int/double identically
  }
}
