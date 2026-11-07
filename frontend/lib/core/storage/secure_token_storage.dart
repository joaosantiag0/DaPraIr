import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SecureTokenStorage provides AES-256 encrypted storage for authentication JWT tokens,
/// using a dynamically generated device-bound seed (OWASP Mobile M1/M9).
class SecureTokenStorage {
  static const String _storageKey = 'daprair_auth_token_enc';
  static const String _deviceSeedKey = 'daprair_device_master_seed';
  static const String legacyTokenKey = 'daprair_auth_token';

  // Legacy key used solely for automatic one-time migration of previous installs
  static final _legacyAesKey = Key.fromUtf8('daprair_auth_token_secret_key32!');

  final SharedPreferences? _prefs;
  SecureTokenStorage([this._prefs]);

  Future<SharedPreferences> _getPrefs() async => _prefs ?? await SharedPreferences.getInstance();

  /// Derives an installation-specific 256-bit key unique to this device/install.
  Future<Key> _getDeviceKey() async {
    final prefs = await _getPrefs();
    var seed = prefs.getString(_deviceSeedKey);
    if (seed == null || seed.isEmpty) {
      final randomBytes = IV.fromSecureRandom(32).base64;
      seed = randomBytes;
      await prefs.setString(_deviceSeedKey, seed);
    }
    final digest = sha256.convert(utf8.encode('daprair_app_salt_$seed'));
    return Key(Uint8List.fromList(digest.bytes));
  }

  Future<void> saveToken(String token) async {
    final prefs = await _getPrefs();
    final key = await _getDeviceKey();
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(token, iv: iv);

    final payload = 'v2:${iv.base64}:${encrypted.base64}';
    await prefs.setString(_storageKey, payload);
    // Remove any legacy unencrypted token
    await prefs.remove(legacyTokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await _getPrefs();
    final payload = prefs.getString(_storageKey);

    if (payload != null && payload.isNotEmpty) {
      try {
        final parts = payload.split(':');
        // v2 payload: v2:iv:ciphertext
        if (parts.length == 3 && parts[0] == 'v2') {
          final iv = IV.fromBase64(parts[1]);
          final encrypted = Encrypted.fromBase64(parts[2]);
          final key = await _getDeviceKey();
          final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
          return encrypter.decrypt(encrypted, iv: iv);
        } else if (parts.length == 2) {
          // v1 payload with legacy key: attempt decryption and transparently migrate to v2
          final iv = IV.fromBase64(parts[0]);
          final encrypted = Encrypted.fromBase64(parts[1]);
          final encrypter = Encrypter(AES(_legacyAesKey, mode: AESMode.cbc));
          final decrypted = encrypter.decrypt(encrypted, iv: iv);
          await saveToken(decrypted);
          return decrypted;
        }
      } catch (_) {
        // Fallback or clear corrupted token
        await prefs.remove(_storageKey);
      }
    }

    // Check legacy plaintext key for migration
    final legacyToken = prefs.getString(legacyTokenKey);
    if (legacyToken != null && legacyToken.isNotEmpty) {
      await saveToken(legacyToken);
      return legacyToken;
    }

    return null;
  }

  Future<void> clearToken() async {
    final prefs = await _getPrefs();
    await prefs.remove(_storageKey);
    await prefs.remove(legacyTokenKey);
  }
}
