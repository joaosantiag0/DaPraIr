import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSavedLocation {
  final String label;
  final String? address;
  final String? city;
  final String? state;
  final double latitude;
  final double longitude;
  final bool isGps;
  final DateTime savedAt;

  const UserSavedLocation({
    required this.label,
    this.address,
    this.city,
    this.state,
    required this.latitude,
    required this.longitude,
    this.isGps = false,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'address': address,
        'city': city,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'isGps': isGps,
        'savedAt': savedAt.toIso8601String(),
      };

  factory UserSavedLocation.fromJson(Map<String, dynamic> json) => UserSavedLocation(
        label: json['label'] as String? ?? 'Localização Definida',
        address: json['address'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        isGps: json['isGps'] as bool? ?? false,
        savedAt: json['savedAt'] != null
            ? DateTime.tryParse(json['savedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  String get displayTitle {
    if (isGps) {
      if (city != null && state != null && city!.isNotEmpty) {
        return '$city - $state (GPS)';
      }
      return 'Minha Localização Atual (GPS)';
    }
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    if (city != null && state != null) {
      return '$city - $state';
    }
    return label;
  }
}

class UserLocationStorage {
  static const String _storageKey = 'daprair_encrypted_user_location';
  // 32-byte key for AES-256 (256-bit encryption compliant with LGPD)
  static final _aesKey = Key.fromUtf8('daprair_secure_user_loc_key_32b!');

  final SharedPreferences? _prefs;
  UserLocationStorage([this._prefs]);

  Future<SharedPreferences> _getPrefs() async => _prefs ?? await SharedPreferences.getInstance();

  Future<void> saveLocation(UserSavedLocation location) async {
    final prefs = await _getPrefs();
    final jsonString = jsonEncode(location.toJson());

    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(_aesKey, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(jsonString, iv: iv);

    final payload = '${iv.base64}:${encrypted.base64}';
    await prefs.setString(_storageKey, payload);
  }

  Future<UserSavedLocation?> getSavedLocation() async {
    final prefs = await _getPrefs();
    final payload = prefs.getString(_storageKey);
    if (payload == null || payload.isEmpty) return null;

    try {
      final parts = payload.split(':');
      if (parts.length != 2) return null;

      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);
      final encrypter = Encrypter(AES(_aesKey, mode: AESMode.cbc));
      final decryptedJson = encrypter.decrypt(encrypted, iv: iv);

      final map = jsonDecode(decryptedJson) as Map<String, dynamic>;
      return UserSavedLocation.fromJson(map);
    } catch (_) {
      // In case of tampering or corruption, clear safely
      await prefs.remove(_storageKey);
      return null;
    }
  }

  Future<void> clearLocation() async {
    final prefs = await _getPrefs();
    await prefs.remove(_storageKey);
  }
}
