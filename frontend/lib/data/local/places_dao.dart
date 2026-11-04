import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/place.dart';

class PlacesDao {
  static const _cachedPlacesKey = 'daprair_cached_places';
  static const _draftPrefix = 'daprair_review_draft_';

  final SharedPreferences? _prefs;

  PlacesDao([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  Future<void> cachePlaces(List<Place> places) async {
    final prefs = await _getPrefs();
    final jsonList = places.map((p) => {
      'id': p.id,
      'name': p.name,
      'category': p.category,
      'address': p.address,
      'city': p.city,
      'state': p.state,
      'latitude': p.latitude,
      'longitude': p.longitude,
      'overallScore': p.overallScore,
      'totalReviews': p.totalReviews,
    }).toList();
    await prefs.setString(_cachedPlacesKey, jsonEncode(jsonList));
  }

  Future<List<Place>> getCachedPlaces() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_cachedPlacesKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return Place(
          id: map['id'] as String,
          name: map['name'] as String,
          category: map['category'] as String,
          address: map['address'] as String,
          city: map['city'] as String,
          state: map['state'] as String,
          latitude: (map['latitude'] as num).toDouble(),
          longitude: (map['longitude'] as num).toDouble(),
          overallScore: (map['overallScore'] as num).toDouble(),
          totalReviews: (map['totalReviews'] as num).toInt(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDraft({
    required String placeId,
    String? generalComment,
    required Map<String, int> ratings,
    List<Map<String, String>> photos = const [],
  }) async {
    final prefs = await _getPrefs();
    final draftData = {
      'placeId': placeId,
      'generalComment': generalComment,
      'ratings': ratings,
      'photos': photos,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString('$_draftPrefix$placeId', jsonEncode(draftData));
  }

  Future<Map<String, dynamic>?> getDraft(String placeId) async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString('$_draftPrefix$placeId');
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return {
        'placeId': map['placeId'] as String,
        'generalComment': map['generalComment'] as String?,
        'ratings': map['ratings'] as Map<String, dynamic>,
        'photos': map['photos'] as List<dynamic>,
        'updatedAt': map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : DateTime.now(),
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteDraft(String placeId) async {
    final prefs = await _getPrefs();
    await prefs.remove('$_draftPrefix$placeId');
  }
}
