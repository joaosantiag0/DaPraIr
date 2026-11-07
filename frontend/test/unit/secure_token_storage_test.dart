import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/storage/secure_token_storage.dart';
import 'package:encrypt/encrypt.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureTokenStorage (Security Hardening)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saves and retrieves token using dynamic v2 payload', () async {
      final storage = SecureTokenStorage();
      const sampleJwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.sample';

      await storage.saveToken(sampleJwt);
      final retrieved = await storage.getToken();

      expect(retrieved, equals(sampleJwt));

      // Verify raw storage format contains v2 prefix and not plaintext
      final prefs = await SharedPreferences.getInstance();
      final rawPayload = prefs.getString('daprair_auth_token_enc');
      expect(rawPayload, isNotNull);
      expect(rawPayload!.startsWith('v2:'), isTrue);
      expect(rawPayload.contains(sampleJwt), isFalse);
    });

    test('transparently migrates legacy unencrypted plaintext token', () async {
      const sampleJwt = 'legacy_plaintext_jwt_token';
      SharedPreferences.setMockInitialValues({
        SecureTokenStorage.legacyTokenKey: sampleJwt,
      });

      final storage = SecureTokenStorage();
      final retrieved = await storage.getToken();

      expect(retrieved, equals(sampleJwt));

      // After retrieval, legacy key must be migrated and cleared
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('daprair_auth_token_enc'), isTrue);
      expect(prefs.containsKey(SecureTokenStorage.legacyTokenKey), isFalse);
    });

    test('clears encrypted token and seed cleanly', () async {
      final storage = SecureTokenStorage();
      await storage.saveToken('token_to_delete');
      expect(await storage.getToken(), isNotNull);

      await storage.clearToken();
      expect(await storage.getToken(), isNull);
    });
  });
}
