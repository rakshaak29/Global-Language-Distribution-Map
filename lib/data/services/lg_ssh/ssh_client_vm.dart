import 'package:dartssh2/dartssh2.dart';
import 'ssh_client_interface.dart';

class LgSshClientImpl implements LgSshClient {
  SSHClient? _client;

  @override
  Future<bool> connect({
    required String host,
    required int port,
    required String username,
    required String password,
  }) async {
    try {
      final socket = await SSHSocket.connect(host, port, timeout: const Duration(seconds: 5));
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );
      // Wait for authentication
      await _client!.authenticated;
      return true;
    } catch (_) {
      _client = null;
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      _client?.close();
      await _client?.done;
    } catch (_) {
      // Ignore client close errors
    } finally {
      _client = null;
    }
  }

  @override
  Future<String> execute(String command) async {
    if (_client == null) return '';
    try {
      final result = await _client!.run(command);
      return String.fromCharCodes(result);
    } catch (_) {
      return '';
    }
  }

  @override
  bool get isConnected => _client != null;
}
