import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:casarancha/app/utils/base_url.dart';
import 'package:casarancha/app/utils/get_file_type.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class StoryService {
  http.Client client = http.Client();

  Future<http.StreamedResponse?> createStory({
    required String content,
    required String token,
    required List<File> mediaFiles,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/story/create");

      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Content-Type'] = 'multipart/form-data'
        ..fields['content'] = content;

      for (var mediaFile in mediaFiles) {
        final filePath = mediaFile.path;
        request.files.add(
          await http.MultipartFile.fromPath(
            'media',
            mediaFile.path,
            contentType: MediaType.parse(getMimeType(filePath)),
          ),
        );
      }

      var response = await request.send();
      return response;
    } on SocketException catch (e) {
      CustomSnackbar.showErrorToast("Check internet connection, $e");
      debugPrint("No internet connection");
      return null;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> getAllStories({
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/story/feed');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));
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

  Future<http.Response?> viewStory({
    required String token,
    required List<Map> storyItems,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/story/view-story');
      final response = await client
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "storyItems": storyItems,
            }),
          )
          .timeout(const Duration(seconds: 15));
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

  Future<http.Response?> getStoryViewers({
    required String token,
    required String storyId,
    required String storyItemId,
  }) async {
    try {
      final url =
          Uri.parse('$baseUrl/story/get-story-viewers/$storyId/$storyItemId');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 60));
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

  Future<http.Response?> getUserPostedStories({
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/story/get-user-posted-story');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));
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

  Future<http.Response?> deleteStory({
    required String token,
    required String storyId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/story/delete-story/$storyId');
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));
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
