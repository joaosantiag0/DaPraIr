import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/places_repository.dart';
import '../local/app_database.dart';
import '../local/places_dao.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final DioClient dioClient;
  final PlacesDao placesDao;

  PlacesRepositoryImpl({required this.dioClient, required this.placesDao});

  @override
  Future<List<Place>> searchPlaces({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    String? query,
    String? category,
    List<String>? requiredCriteria,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await dioClient.dio.get(
        '/api/v1/places',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusMeters': radiusMeters,
          if (query != null && query.isNotEmpty) 'query': query,
          if (category != null) 'category': category,
          if (requiredCriteria != null && requiredCriteria.isNotEmpty)
            'requiredCriteria': requiredCriteria,
          'limit': limit,
          'offset': offset,
        },
      );

      final items = (response.data['items'] as List<dynamic>?) ?? [];
      final places = items.map((json) => _mapJsonToPlace(json as Map<String, dynamic>)).toList();

      // Update offline cache
      if (places.isNotEmpty) {
        final companions = places.map((p) => CachedPlacesCompanion.insert(
          id: p.id,
          name: p.name,
          category: p.category,
          address: p.address,
          city: p.city,
          state: p.state,
          latitude: p.latitude,
          longitude: p.longitude,
          overallScore: p.overallScore,
          totalReviews: p.totalReviews,
          cachedAt: Value(DateTime.now()),
        )).toList();
        await placesDao.cachePlaces(companions);
      }

      return places;
    } catch (_) {
      // Offline fallback: load from Drift local cache
      final cached = await placesDao.getCachedPlaces();
      return cached.map((c) => Place(
        id: c.id,
        name: c.name,
        category: c.category,
        address: c.address,
        city: c.city,
        state: c.state,
        latitude: c.latitude,
        longitude: c.longitude,
        overallScore: c.overallScore,
        totalReviews: c.totalReviews,
      )).toList();
    }
  }

  @override
  Future<Place> getPlaceDetails(String placeId) async {
    final response = await dioClient.dio.get('/api/v1/places/$placeId');
    return _mapJsonToPlace(response.data as Map<String, dynamic>);
  }

  @override
  Future<Place> createPlace({
    required String name,
    String? description,
    required String category,
    required String address,
    required String city,
    required String state,
    String? postalCode,
    required double latitude,
    required double longitude,
    String? googlePlaceId,
  }) async {
    final response = await dioClient.dio.post(
      '/api/v1/places',
      data: {
        'name': name,
        'description': description,
        'category': category,
        'address': address,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'latitude': latitude,
        'longitude': longitude,
        'googlePlaceId': googlePlaceId,
      },
    );
    return _mapJsonToPlace(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Review>> getPlaceReviews(String placeId, {int limit = 10, int offset = 0}) async {
    final response = await dioClient.dio.get(
      '/api/v1/places/$placeId/reviews',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final items = (response.data['items'] as List<dynamic>?) ?? [];
    return items.map((json) => _mapJsonToReview(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Review> submitReview({
    required String placeId,
    String? generalComment,
    required List<Map<String, dynamic>> ratings,
    List<String>? mediaIds,
  }) async {
    final response = await dioClient.dio.post(
      '/api/v1/places/$placeId/reviews',
      data: {
        'generalComment': generalComment,
        'ratings': ratings,
        'mediaIds': mediaIds,
      },
    );
    // On success, clear any stored draft
    await placesDao.deleteDraft(placeId);
    return _mapJsonToReview(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> saveReviewDraft({
    required String placeId,
    String? generalComment,
    required Map<String, int> ratings,
    List<Map<String, String>> photos = const [],
  }) async {
    await placesDao.saveDraft(
      placeId: placeId,
      generalComment: generalComment,
      ratings: ratings,
      photos: photos,
    );
  }

  @override
  Future<Map<String, dynamic>?> getReviewDraft(String placeId) async {
    final draft = await placesDao.getDraft(placeId);
    if (draft == null) return null;
    return {
      'placeId': draft.placeId,
      'generalComment': draft.generalComment,
      'ratings': jsonDecode(draft.ratingsJson) as Map<String, dynamic>,
      'photos': jsonDecode(draft.photosJson) as List<dynamic>,
      'updatedAt': draft.updatedAt,
    };
  }

  @override
  Future<void> clearReviewDraft(String placeId) async {
    await placesDao.deleteDraft(placeId);
  }

  Place _mapJsonToPlace(Map<String, dynamic> json) {
    final criteria = (json['criteriaBreakdown'] as List<dynamic>?) ?? [];
    final media = (json['media'] as List<dynamic>?) ?? [];

    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      overallScore: (json['overallScore'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      lastReviewedAt: json['lastReviewedAt'] != null ? DateTime.parse(json['lastReviewedAt'] as String) : null,
      isOutdated: json['isOutdated'] as bool? ?? false,
      distanceMeters: json['distanceMeters'] as int?,
      criteriaBreakdown: criteria.map((c) => PlaceCriterionSummary(
        id: c['id'] as String,
        code: c['code'] as String,
        title: c['title'] as String,
        iconName: c['iconName'] as String,
        averageScore: (c['averageScore'] as num).toDouble(),
        ratingsCount: (c['ratingsCount'] as num).toInt(),
      )).toList(),
      media: media.map((m) => PlaceMediaItem(
        id: m['id'] as String,
        mediaUrl: m['mediaUrl'] as String,
        thumbnailUrl: m['thumbnailUrl'] as String,
        altText: m['altText'] as String,
      )).toList(),
    );
  }

  Review _mapJsonToReview(Map<String, dynamic> json) {
    final authorJson = json['author'] as Map<String, dynamic>;
    final ratings = (json['ratings'] as List<dynamic>?) ?? [];
    final media = (json['media'] as List<dynamic>?) ?? [];

    return Review(
      id: json['id'] as String,
      placeId: json['placeId'] as String,
      generalComment: json['generalComment'] as String?,
      averageScore: (json['averageScore'] as num).toDouble(),
      reportCount: (json['reportCount'] as num).toInt(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      author: ReviewAuthor(
        id: authorJson['id'] as String,
        name: authorJson['name'] as String,
        handle: authorJson['handle'] as String,
        avatarUrl: authorJson['avatarUrl'] as String?,
      ),
      ratings: ratings.map((r) => ReviewRatingItem(
        criterionCode: r['criterionCode'] as String,
        criterionTitle: r['criterionTitle'] as String,
        score: (r['score'] as num).toInt(),
        notes: r['notes'] as String?,
      )).toList(),
      media: media.map((m) => PlaceMediaItem(
        id: m['id'] as String,
        mediaUrl: m['mediaUrl'] as String,
        thumbnailUrl: m['thumbnailUrl'] as String,
        altText: m['altText'] as String,
      )).toList(),
    );
  }
}
