import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> storeApiKey(String apiKey) async {
    await _storage.write(
      key: AppConstants.secureStorageApiKeyKey,
      value: apiKey,
    );
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: AppConstants.secureStorageApiKeyKey);
  }

  Future<void> deleteApiKey() async {
    await _storage.delete(key: AppConstants.secureStorageApiKeyKey);
  }

  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
