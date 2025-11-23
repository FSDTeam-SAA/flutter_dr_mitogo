import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageController extends GetxController {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Store token
  Future<void> storeToken(String token) async {
    await _secureStorage.write(key: 'userToken', value: token);
  }

  // Get token
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'userToken');
    } catch (e) {
      return null;
    }
  }

  // Delete token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'userToken');
  }

  //user status
  Future<bool> getUserStatus() async {
    final String? value = await _secureStorage.read(key: "newUser");
    return value != null ? true : false;
  }

  Future<void> saveStatus(String value) async {
    await _secureStorage.write(key: "newUser", value: value);
  }

  Future<void> saveLastPushId({
    required String userId,
    required String oneSignalId,
  }) async {
    await _secureStorage.write(key: 'push_id_$userId', value: oneSignalId);
  }

  Future<String?> getLastPushId(String userId) async {
    try {
      return await _secureStorage.read(key: 'push_id_$userId');
    } catch (e) {
      return null;
    }
  }

  // Noyon
  Future<void> saveAppLanguage(String languageCode) async {
    await _secureStorage.write(key: 'app_language', value: languageCode);
  }

  Future<String?> getAppLanguage() async {
    try {
      return await _secureStorage.read(key: 'app_language');
    } catch (e) {
      return null;
    }
  }
}
