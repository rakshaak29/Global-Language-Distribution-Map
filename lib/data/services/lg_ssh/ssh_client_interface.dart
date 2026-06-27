abstract class LgSshClient {
  Future<bool> connect({
    required String host,
    required int port,
    required String username,
    required String password,
  });

  Future<void> disconnect();

  Future<String> execute(String command);

  bool get isConnected;
}
