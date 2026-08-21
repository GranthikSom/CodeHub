/// CodeHub Sovereign Infrastructure Domain Endpoints
class ApiConfig {
  static const String appDomain = 'app.codehub.com';
  static const String apiDomain = 'api.codehub.com';
  static const String authDomain = 'auth.codehub.com';
  static const String registryDomain = 'registry.codehub.com';
  static const String p2pDomain = 'p2p.codehub.com';

  static const String appBaseUrl = 'https://$appDomain';
  static const String apiBaseUrl = 'https://$apiDomain';
  static const String authBaseUrl = 'https://$authDomain';
  static const String registryBaseUrl = 'https://$registryDomain';

  // libp2p Bootstrap Discovery Relay Node Multiaddr
  static const String p2pBootstrapRelayMultiaddr =
      '/dns4/$p2pDomain/tcp/4001/p2p/12D3KooWControlRelayServer';
}
