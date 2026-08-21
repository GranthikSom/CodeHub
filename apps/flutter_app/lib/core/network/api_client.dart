import 'dart:io';
import 'dart:convert';

class ApiClient {
  static const String baseUrl = 'http://127.0.0.1:8080';
  static final HttpClient _client = HttpClient();

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final request = await _client.getUrl(Uri.parse('$baseUrl$endpoint'));
    final response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    return json.decode(stringData);
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final request = await _client.postUrl(Uri.parse('$baseUrl$endpoint'));
    request.headers.contentType = ContentType.json;
    request.write(json.encode(data));
    final response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    return json.decode(stringData);
  }
}
