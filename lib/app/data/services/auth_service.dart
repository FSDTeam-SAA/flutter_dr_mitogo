import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/utils/base_url.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  http.Client client = http.Client();
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> _initializeSignIn() async {
    final clientId =
        "423296603409-16vqq4rnphhhkb43v81q1088e56jp08f.apps.googleusercontent.com";
    final serverClientId =
        "423296603409-lechplsgug2dtpsa9r6hrkptihsl6tdn.apps.googleusercontent.com";

    await _googleSignIn.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );
  }

  Future<String?> signInWithGoogle() async {
    try {
      await _initializeSignIn();
      final googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      return idToken;
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
    }
    return null;
  }

  Future<http.Response?> sendGoogleToken({
    required String token,
    required bool isRegister,
  }) async {
    try {
      final authUrl =
          isRegister
              ? "$baseUrl/auth/google-auth-signup"
              : "$baseUrl/auth/google-auth-signin";
      final response = await http.post(
        Uri.parse(authUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"token": token}),
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.disconnect();
  }

  Future<http.Response?> register({required UserModel userModel}) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(userModel.toMap()),
      );
      return response;
    } on SocketException catch (e) {
      // CustomSnackbar.showErrorSnackBar("Check internet connection");
      debugPrint("SocketException: $e");
    } on TimeoutException {
      // CustomSnackbar.showErrorSnackBar(
      //   "Request timeout, probably Bad network, try again",
      // );
      debugPrint("Request Time out");
    } catch (e) {
      debugPrint("Error From Auth Servie: ${e.toString()}");
    }
    return null;
  }

  Future<http.Response?> sendOtp({required String email}) async {
    try {
      final response = await client
          .post(
            Uri.parse("$baseUrl/auth/send-otp"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({"email": email}),
          )
          .timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.Response?> verifyOtp({
    required String otpCode,
    String? email,
    String? phoneNumber,
    required String token,
  }) async {
    try {
      final Map<String, String> body = {"otp": otpCode};

      if (email?.isNotEmpty == true) {
        body["email"] = email!;
      }

      if (phoneNumber?.isNotEmpty == true) {
        body["phone_number"] = phoneNumber!;
      }

      final response = await client
          .post(
            Uri.parse("$baseUrl/auth/verify-otp"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<http.Response?> sendOtpForgotPassword({required String email}) async {
    try {
      final response = await client
          .post(
            Uri.parse("$baseUrl/auth/send-otp-forgot-password"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({"email": email}),
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

  Future<http.Response?> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse("$baseUrl/auth/reset-password"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"password": password}),
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

  Future<http.Response?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      http.Response response = await client
          .post(
            Uri.parse("$baseUrl/auth/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 60));
      return response;
    } on SocketException catch (_) {
      CustomSnackbar.showErrorToast("Host connection unstable");
      debugPrint("No internet connection");
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

  Future<http.Response?> deleteAccount({required String token}) async {
    try {
      final response = await client.delete(
        Uri.parse("$baseUrl/auth/delete-account"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

}
