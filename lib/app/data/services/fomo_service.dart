import 'dart:async';
import 'dart:convert';

import 'package:casarancha/app/utils/base_url.dart';
import 'package:http/http.dart' as http;

class FomoService {
  Future<http.Response?> getActiveWindows({required String token}) async {
    try {
      final uri = Uri.parse("$baseUrl/fomo/active");
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

  Future<http.Response?> participate({
    required String token,
    required String windowId,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/fomo/windows/$windowId/participate");
      return await http
          .post(
            uri,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
