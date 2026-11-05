import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SecureTokenStorage provides AES-256 encrypted storage for authentication JWT tokens,
/// preventing plaintext exposure in Android SharedPreferences or iOS NSUserDefaults (OWASP Mobile M1).
class SecureTokenStorage {
  static const String _storageKey = 'daprair_auth_token_enc';
  static const String legacyTokenKey = 'daprair_auth_token';

  // 32-byte key for AES-256
  static final _aesKey = Key.fromUtf8('daprair_auth_token_secret_key32!');

  final SharedPreferences? _prefs;
  SecureTokenStorage([this._prefs]);

  Future<SharedPreferences> _getPrefs() async => _prefs ?? await SharedPreferences.getInstance();

  Future<void> saveToken(String token) async {
    final prefs = await _getPrefs();
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(_aesKey, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(token, iv: iv);

    final payload = '${iv.base64}:${encrypted.base64}';
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
        if (parts.length == 2) {
          final iv = IV.fromBase64(parts[0]);
          final encrypted = Encrypted.fromBase64(parts[1]);
          final encrypter = Encrypter(AES(_aesKey, mode: AESMode.cbc));
          return encrypter.decrypt(encrypted, iv: iv);
        }
      } catch (_) {
        // Fallback or clear corrupted token
        await prefs.remove(_storageKey);
      }
    }

    // Check legacy key for migration
    final legacyToken = prefs.getString(legacyTokenKey);
    if (legacyToken != null && legacyToken.isNotEmpty) {
      // Migrate to encrypted format
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
