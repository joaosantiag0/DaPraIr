import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/storage/user_location_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('UserLocationStorage encrypts location using AES-256 and decrypts back correctly', () async {
    final storage = UserLocationStorage();

    final location = UserSavedLocation(
      label: 'Meu Endereço',
      address: 'Av. Paulista, 1000 - Bela Vista',
      city: 'São Paulo',
      state: 'SP',
      latitude: -23.5654,
      longitude: -46.6517,
      isGps: false,
      savedAt: DateTime(2026, 11, 4, 15, 0),
    );

    await storage.saveLocation(location);

    // Verify stored payload in SharedPreferences is encrypted (does NOT contain plain address or coordinates)
    final prefs = await SharedPreferences.getInstance();
    final rawStored = prefs.getString('daprair_encrypted_user_location');
    expect(rawStored, isNotNull);
    expect(rawStored!.contains('Paulista'), isFalse);
    expect(rawStored.contains('São Paulo'), isFalse);
    expect(rawStored.contains('-23.5654'), isFalse);
    expect(rawStored.contains(':'), isTrue); // IV:Ciphertext

    // Decrypt and assert all fields
    final retrieved = await storage.getSavedLocation();
    expect(retrieved, isNotNull);
    expect(retrieved!.label, equals('Meu Endereço'));
    expect(retrieved.address, equals('Av. Paulista, 1000 - Bela Vista'));
    expect(retrieved.city, equals('São Paulo'));
    expect(retrieved.state, equals('SP'));
    expect(retrieved.latitude, closeTo(-23.5654, 0.0001));
    expect(retrieved.longitude, closeTo(-46.6517, 0.0001));
    expect(retrieved.isGps, isFalse);
    expect(retrieved.displayTitle, contains('Paulista'));
  });

  test('UserLocationStorage clearLocation removes encrypted payload', () async {
    final storage = UserLocationStorage();
    final location = UserSavedLocation(
      label: 'Local GPS',
      latitude: -23.55052,
      longitude: -46.633308,
      isGps: true,
      savedAt: DateTime.now(),
    );

    await storage.saveLocation(location);
    expect(await storage.getSavedLocation(), isNotNull);

    await storage.clearLocation();
    expect(await storage.getSavedLocation(), isNull);
  });
}
