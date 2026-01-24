import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:casarancha/app/utils/base_url.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class GroupService {
  http.Client client = http.Client();

  Future<http.StreamedResponse?> createGroup({
    required String token,
    required String name,
    required String description,
    required String visibilityType,
    required File file,
    required List<String> membersId,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/group/create");

      var request =
          http.MultipartRequest('POST', uri)
            ..headers['Authorization'] = 'Bearer $token'
            ..headers['Content-Type'] = 'multipart/form-data';

      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['visibilityType'] = visibilityType;

      if (membersId.isNotEmpty) {
        request.fields['memberIds'] = jsonEncode(membersId);
      }

      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final mimeSplit = mimeType.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          file.path,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      );

      var response = await request.send().timeout(const Duration(seconds: 100));
      return response;
    } on SocketException catch (e) {
      debugPrint("No internet connection $e");
      CustomSnackbar.showErrorToast("No internet connection");
    } on TimeoutException {
      debugPrint("Request timeout");
      CustomSnackbar.showErrorToast("Request timeout");
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> getGroups({required String token}) async {
    try {
      final response = await client.get(
        Uri.parse("$baseUrl/group/public-groups"),
        headers: {"Authorization": "Bearer $token"},
      );
      return response;
    } on SocketException catch (e) {
      debugPrint("No internet connection $e");
    } on TimeoutException {
      debugPrint("Request timeout");
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> joinGroup({
    required String token,
    required String groupId,
  }) async {
    try {
      final response = await client.post(
        Uri.parse("$baseUrl/group/join"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"groupId": groupId}),
      );
      return response;
    } on SocketException catch (e) {
      debugPrint("No internet connection $e");
    } on TimeoutException {
      debugPrint("Request timeout");
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> userGroups({required String token}) async {
    try {
      final response = await client.get(
        Uri.parse("$baseUrl/group/user-groups"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      return response;
    } on SocketException catch (e) {
      debugPrint("No internet connection $e");
    } on TimeoutException {
      debugPrint("Request timeout");
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> getMembersToAdd({required String token}) async {
    try {
      final response = await client.get(
        Uri.parse("$baseUrl/group/get-members-to-add"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      return response;
    } on SocketException catch (e) {
      debugPrint("No internet connection $e");
    } on TimeoutException {
      debugPrint("Request timeout");
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}
