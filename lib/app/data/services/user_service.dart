import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/utils/base_url.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserService {
  http.Client client = http.Client();

  Future<http.Response?> getUserDetails({required String token}) async {
    try {
      final response = await client
          .get(
            Uri.parse("$baseUrl/user/get-user-details"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
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

  Future<http.Response?> getUserById({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await client
          .get(
            Uri.parse("$baseUrl/user/user-details/$userId"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
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

  Future<http.StreamedResponse?> completeProfile({
    required UserModel userModel,
    required String token,
    required File imageFile,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/user/complete-profile");

      var request =
          http.MultipartRequest('POST', uri)
            ..headers['Authorization'] = 'Bearer $token'
            ..headers['Content-Type'] = 'multipart/form-data'
            ..fields['dob'] = userModel.dateOfBirth.toString()
            ..fields['username'] = userModel.username!
            ..fields['education'] = userModel.education ?? ""
            ..fields['work'] = userModel.work ?? ""
            ..fields['bio'] = userModel.bio ?? ""
            ..files.add(
              await http.MultipartFile.fromPath('avatar', imageFile.path),
            );

      var response = await request.send().timeout(const Duration(seconds: 120));
      return response;
    } on SocketException catch (e) {
      CustomSnackbar.showErrorToast("Check internet connection, $e");
      debugPrint("No internet connection");
      return null;
    } on TimeoutException {
      CustomSnackbar.showErrorToast(
        "Request timeout, probably bad network, try again",
      );
      debugPrint("Request timeout");
      return null;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> getUserStatus({required String token}) async {
    try {
      final response = await client
          .get(
            Uri.parse("$baseUrl/user/get-user-status"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
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

  Future<http.Response?> toggleBlock({
    required String token,
    required String blockId,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse("$baseUrl/user/toggle-block"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"blockId": blockId}),
          )
          .timeout(const Duration(seconds: 30));
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

  Future<http.Response?> toggleFollow({
    required String token,
    required String followId,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse("$baseUrl/user/toggle-follow"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"followId": followId}),
          )
          .timeout(const Duration(seconds: 30));
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

  Future<http.Response?> getBlockedUsers({required String token}) async {
    try {
      final response = await client
          .get(
            Uri.parse("$baseUrl/user/get-blocked-users"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60));
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

  Future<http.Response?> reportUser({
    required String token,
    required String type,
    required String reason,
    required String reportedUser,
    required String referenceId,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/user/create-report");
      final response = await client
          .post(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "type": type.toLowerCase(),
              "description": reason,
              "reportedUser": reportedUser,
              "referenceId": referenceId,
            }),
          )
          .timeout(const Duration(seconds: 60));
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

  Future<http.Response?> getAllUserPost({
    required String token,
    required String userId,
    required int currentPage,
  }) async {
    try {
      final response = await client
          .get(
            Uri.parse("$baseUrl/user/all-user-posts").replace(
              queryParameters: {
                "userId": userId,
                "pageNum": currentPage.toString(),
              },
            ),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60));
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

  Future<http.Response?> getAllUserMedia({
    required String token,
    required String userId,
    required String type,
  }) async {
    try {
      final response = await client
          .get(
            Uri.parse(
              "$baseUrl/user/get-user-media",
            ).replace(queryParameters: {"userId": userId, "type": type}),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60));
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

  Future<http.StreamedResponse?> uploadCoverPhoto({
    required String token,
    required File imageFile,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/user/upload-cover-photo");

      var request =
          http.MultipartRequest('POST', uri)
            ..headers['Authorization'] = 'Bearer $token'
            ..headers['Content-Type'] = 'multipart/form-data'
            ..files.add(
              await http.MultipartFile.fromPath('coverPhoto', imageFile.path),
            );

      var response = await request.send().timeout(const Duration(seconds: 120));
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

  Future<http.Response?> saveUserOneSignalId({
    required String token,
    required String id,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse("$baseUrl/user/save-signal-id/$id"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
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

  Future<http.Response?> getNotifications({required String token}) async {
    try {
      final response = await client
          .get(
            Uri.parse("$baseUrl/user/get-notification"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> markNotificationAsRead({
    required String token,
    required String id,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/user/mark-notification-as-read"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"notificationId": id}),
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

  Future<http.Response?> getAllAccounts({required String token}) async {
    try {
      final response = await client
          .get(
            Uri.parse("$baseUrl/user/get-all-accounts"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
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

  Future<http.Response?> getTopAccounts({required String token}) async {
    try {
      final response = await client
          .get(
            Uri.parse("$baseUrl/user/get-trending-accounts"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60));
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

  Future<http.Response?> notificationSettings({
    required String token,
    required bool pushNotification,
    required bool realTimeUpdate,
    required bool inboxNotification,
    required bool vibrate,
    required bool sound,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/user/notification-settings"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "pushNotification": pushNotification,
              "realTimeUpdate": realTimeUpdate,
              "inboxNotification": inboxNotification,
              "vibrate": vibrate,
              "sound": sound,
            }),
          )
          .timeout(const Duration(seconds: 60));
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

  Future<http.Response?> getNotificationSettings({
    required String token,
  }) async {
    try {
      final response = await client
          .get(
            Uri.parse("$baseUrl/user/get-notification-settings"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60));
      return response;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> searchUser({
    required String token,
    required String search,
  }) async {
    try {
      final response = await client
          .get(
            Uri.parse("$baseUrl/user/search-user?search=$search"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60));
      return response;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> editProfile({
    required String token,
    required UserModel userModel,
    File? avatar,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/user/edit-profile");
      final request = http.MultipartRequest("PATCH", url)
        ..headers['Authorization'] = 'Bearer $token';

      if (avatar != null) {
        request.files.add(
          await http.MultipartFile.fromPath('avatar', avatar.path),
        );
      }
      if (userModel.email != null) {
        request.fields['email'] = userModel.email!;
      }
      if (userModel.phoneNumber != null) {
        request.fields['phoneNumber'] = userModel.phoneNumber!;
      }
      if (userModel.displayName != null) {
        request.fields['displayName'] = userModel.displayName!;
      }
      // if (userModel.username != null) {
      //   request.fields['username'] = userModel.username!;
      // }
      if (userModel.bio != null) {
        request.fields['bio'] = userModel.bio!;
      }
      if (userModel.dateOfBirth != null) {
        request.fields['dob'] = userModel.dateOfBirth.toString();
      }
      if (userModel.education != null) {
        request.fields['education'] = userModel.education!;
      }
      if (userModel.work != null) {
        request.fields['work'] = userModel.work!;
      }

      final response = await request.send().timeout(
        const Duration(seconds: 60),
      );
      return await http.Response.fromStream(response);
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> verificationRequest({
    required String token,
    required File frontId,
    required File backId,
    required File selfieId,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/verification/upload-id");
      final request = http.MultipartRequest("POST", url)
        ..headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('id_front', frontId.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('id_back', backId.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('selfie', selfieId.path),
      );
      final response = await request.send().timeout(
        const Duration(seconds: 60),
      );
      return await http.Response.fromStream(response);
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> createTicket({
    required String token,
    required List<File> attachments,
    required String subject,
    required String description,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/support-ticket/create-ticket");
      final requests = http.MultipartRequest("POST", url)
        ..headers['Authorization'] = 'Bearer $token';
      final files = await Future.wait(
        attachments
            .map((e) => http.MultipartFile.fromPath('attachments', e.path))
            .toList(),
      );
      requests.files.addAll(files);
      requests.fields['subject'] = subject;
      requests.fields['description'] = description;
      final response = await requests.send().timeout(
        const Duration(seconds: 60),
      );
      return await http.Response.fromStream(response);
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> viewAllFollowers({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await client
          .get(
            Uri.parse("$baseUrl/user/get-followers?userId=$userId"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> viewAllFollowing({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await client
          .get(
            Uri.parse("$baseUrl/user/get-following?userId=$userId"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> toggleGhostMode({required String token}) async {
    try {
      final response = await client
          .post(
            Uri.parse("$baseUrl/user/toggle-ghost-mode"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

}
