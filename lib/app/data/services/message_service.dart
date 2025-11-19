import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:casarancha/app/controller/storage_controller.dart';
import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/utils/base_url.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class MessageService {
  http.Client client = http.Client();

  Future<http.Response?> sendMessage({
    required String token,
    required MessageModel messageModel,
  }) async {
    try {
      http.Response response = await client
          .post(
            Uri.parse("$baseUrl/message/send"),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(messageModel.toJson()),
          )
          .timeout(const Duration(seconds: 15));
      return response;
    } on SocketException catch (e) {
      CustomSnackbar.showErrorToast("Check internet connection");
      debugPrint("No internet connection $e");
      return null;
    } on TimeoutException {
      CustomSnackbar.showErrorToast(
        "Request timeout, probably bad network, try again",
      );
      debugPrint("Request timeout");
      return null;
    } catch (e) {
      throw Exception("Unexpected error $e");
    }
  }

  Future<http.Response?> getMessageHistory({
    required String token,
    required String receiverUserId,
  }) async {
    try {
      http.Response response = await client.get(
        Uri.parse("$baseUrl/message/history/$receiverUserId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 60));
      return response;
    } on SocketException catch (e) {
      CustomSnackbar.showErrorToast("Check internet connection");
      debugPrint("No internet connection $e");
      return null;
    } on TimeoutException {
      CustomSnackbar.showErrorToast(
        "Request timeout, probably bad network, try again",
      );
      debugPrint("Request timeout");
      return null;
    } catch (e) {
      throw Exception("Unexpected error $e");
    }
  }

  Future<http.Response?> getChatList({
    required String token,
  }) async {
    try {
      http.Response response = await client.get(
        Uri.parse("$baseUrl/message/get-chat-list"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 60));
      return response;
    } on SocketException catch (e) {
      CustomSnackbar.showErrorToast("Check internet connection");
      debugPrint("No internet connection $e");
      return null;
    } on TimeoutException {
      debugPrint("Request timeout");
      return null;
    } catch (e) {
      throw Exception("Unexpected error $e");
    }
  }

  Future<dynamic> uploadMedia(File file) async {
    final token = await Get.find<StorageController>().getToken();
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/message/upload"),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    });

    String fileExtension = file.path.split('.').last.toLowerCase();
    MediaType mediaType;

    if (fileExtension == 'mp4') {
      mediaType = MediaType("video", "mp4");
    } else if (['mp3', 'aac', 'wav', 'm4a', 'ogg'].contains(fileExtension)) {
      mediaType = MediaType("audio", fileExtension);
    } else {
      mediaType = MediaType("image", "jpeg");
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: mediaType,
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      return jsonResponse;
    } else {
      return null;
    }
  }

  Future<dynamic> uploadMultiplePictures(List<File> files) async {
    final token = await Get.find<StorageController>().getToken();

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/message/upload-multiple-images"),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    });

    for (var file in files) {
      String fileExtension = file.path.split('.').last.toLowerCase();
      MediaType mediaType;

      if (fileExtension == 'mp4') {
        mediaType = MediaType("video", "mp4");
      } else if (['mp3', 'aac', 'wav', 'm4a', 'ogg'].contains(fileExtension)) {
        mediaType = MediaType("audio", fileExtension);
      } else {
        mediaType = MediaType("image", "jpeg");
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'mul-images',
          file.path,
          contentType: mediaType,
        ),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      return jsonResponse;
    } else {
      return null;
    }
  }

}
