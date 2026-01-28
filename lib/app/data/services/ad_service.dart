import 'dart:async';
import 'dart:convert';
import 'package:casarancha/app/utils/base_url.dart';
import 'package:http/http.dart' as http;

class AdService {
  Future<http.Response?> getActiveAds({required String token}) async {
    try {
      final uri = Uri.parse("$baseUrl/ads/active");
      return await http.get(uri, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      }).timeout(const Duration(seconds: 30));
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
