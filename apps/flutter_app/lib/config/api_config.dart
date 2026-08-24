/// CodeHub Sovereign Client Public Configuration
/// Strictly contains public client endpoints ONLY.
/// Database credentials, JWT secrets, Redis credentials, and private server secrets are NEVER exposed in the client app.
class ApiConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080/api/v1',
  );

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  static const String socketWsUrl = String.fromEnvironment(
    'SOCKET_WS_URL',
    defaultValue: 'ws://127.0.0.1:8080/api/v1/events/ws',
  );

  static const String appDomain = 'app.codehub.com';
  static const String apiDomain = 'api.codehub.com';

  // libp2p Bootstrap Discovery Relay Node Multiaddr
  static const String p2pBootstrapRelayMultiaddr =
      '/dns4/p2p.codehub.com/tcp/4001/p2p/12D3KooWControlRelayServer';
}
