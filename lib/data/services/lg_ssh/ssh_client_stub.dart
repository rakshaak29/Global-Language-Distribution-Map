import 'ssh_client_interface.dart';

class LgSshClientImpl implements LgSshClient {
  bool _connected = false;

  @override
  Future<bool> connect({
    required String host,
    required int port,
    required String username,
    required String password,
  }) async {
    // Validate IP format
    final ipValid = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$')
        .hasMatch(host.trim());

    if (ipValid && port > 0) {
      _connected = true;
      return true;
    }
    return false;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }

  @override
  Future<String> execute(String command) async {
    return '';
  }

  @override
  bool get isConnected => _connected;
}
