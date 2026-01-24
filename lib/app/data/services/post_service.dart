import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/utils/base_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class PostService {
  Future<http.StreamedResponse?> createPost({
    required String token,
    PostModel? postModel,
    List<File>? files,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/create");

      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';

      if (postModel != null) {
        final json = postModel.toJson();
        json.forEach((key, value) {
          if (value == null) return;
          if (value is List || value is Map) {
            request.fields[key] = jsonEncode(value);
            return;
          }
          request.fields[key] = value.toString();
        });
      }

      if (files != null) {
        for (var file in files) {
          final mimeType =
              lookupMimeType(file.path) ?? 'application/octet-stream';
          final mimeSplit = mimeType.split('/');
          request.files.add(
            await http.MultipartFile.fromPath(
              'mediaFiles',
              file.path,
              contentType: MediaType(mimeSplit[0], mimeSplit[1]),
            ),
          );
        }
      }

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

  Future<http.Response?> getFeed({
    required String token,
    required RxInt currentPage,
    String? type,
    String? groupId,
  }) async {
    try {
      var queryParams = {"page": currentPage.value.toString()};

      if (type != null) {
        queryParams["type"] = type;
      }
      if (groupId != null) {
        queryParams["groupId"] = groupId;
      }

      final uri = Uri.parse(
        "$baseUrl/post/feed",
      ).replace(queryParameters: queryParams);

      var response = await http
          .get(
            uri,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 120));
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

  Future<http.Response?> viewPosts({
    required String token,
    required List<String> postId,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/view-posts");
      var response = await http
          .post(
            uri,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"postIds": postId}),
          )
          .timeout(const Duration(seconds: 120));
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

  Future<http.Response?> voteOnPoll({
    required String token,
    required String postId,
    required String optionId,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/vote-poll");
      var response = await http
          .post(
            uri,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"postId": postId, "optionId": optionId}),
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

  Future<http.Response?> reactToPost({
    required String token,
    required String postId,
    required String emoji,
    required String reactedEmoji,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/react");
      var response = await http
          .post(
            uri,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "postId": postId,
              "emoji": emoji,
              "reactionType": reactedEmoji,
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

  Future<http.Response?> reactToComment({
    required String token,
    required String postId,
    required String commentId,
    required String emoji,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/react-comment");
      var response = await http
          .post(
            uri,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "postId": postId,
              "emoji": emoji,
              "reactionType": "love",
              "commentId": commentId,
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

  Future<http.Response?> commentOnPost({
    required String token,
    required String postId,
    required String comment,
    required String clientId,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/comment");
      var response = await http
          .post(
            uri,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "postId": postId,
              "text": comment,
              "clientId": clientId,
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

  Future<http.Response?> replyComment({
    required String token,
    required String commentId,
    required String comment,
    required String clientId,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/reply-to-comment");
      var response = await http
          .post(
            uri,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "commentId": commentId,
              "text": comment,
              "clientId": clientId,
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

  Future<http.Response?> getPostComments({
    required String token,
    required String postId,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/comments?postId=$postId");
      var response = await http
          .get(
            uri,
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

  Future<http.Response?> getAllCommentReplies({
    required String token,
    required String parentId,
    required RxInt currentPage,
  }) async {
    try {
      var uri = Uri.parse(
        "$baseUrl/post/comment-replies?parentId=$parentId&page=${currentPage.value.toString()}",
      );
      var response = await http
          .get(
            uri,
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

  Future<http.Response?> deletePostReaction({
    required String token,
    required String postId,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/delete-post-reaction");
      var response = await http
          .delete(
            uri,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"postId": postId}),
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

  Future<http.Response?> toggleSavePost({
    required String token,
    required String postId,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/toggle-post");
      var response = await http
          .post(
            uri,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"postId": postId}),
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

  Future<http.Response?> searchPeopleToTag({
    required String token,
    required String search,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/search-people?searchQuery=$search");
      var response = await http
          .get(
            uri,
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

  Future<http.Response?> deleteComment({
    required String token,
    required String commentId,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/delete-comment");
      var response = await http
          .delete(
            uri,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"commentId": commentId}),
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

  Future<http.Response?> deletePost({
    required String token,
    required String postId,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/delete-post");
      var response = await http
          .delete(
            uri,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"postId": postId}),
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

  Future<http.Response?> getPostsByMediaType({
    required String token,
    required String mediaType,
    required int currentPage,
  }) async {
    try {
      Map<String, dynamic> query = {
        "page": currentPage.toString(),
        "mediaType": mediaType.toLowerCase(),
      };
      final uri = Uri.parse(
        "$baseUrl/post/get-posts-by-media-type",
      ).replace(queryParameters: query);
      final response = await http.get(
        uri,
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

  Future<http.Response?> getPostViewers({
    required String token,
    required String postId,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/post/post-viewers?postId=$postId");
      var response = await http.get(
        uri,
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
