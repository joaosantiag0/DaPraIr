import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/places_repository.dart';
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
        await placesDao.cachePlaces(places);
      }

      return places;
    } catch (_) {
      // Offline fallback: load from local cache
      return await placesDao.getCachedPlaces();
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
    final payload = <String, dynamic>{
      'name': name,
      'category': category,
      'address': address,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (description != null && description.isNotEmpty) payload['description'] = description;
    if (postalCode != null && postalCode.isNotEmpty) payload['postalCode'] = postalCode;
    if (googlePlaceId != null && googlePlaceId.isNotEmpty) payload['googlePlaceId'] = googlePlaceId;

    final response = await dioClient.dio.post(
      '/api/v1/places',
      data: payload,
    );
    return _mapJsonToPlace(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ExternalPlaceSuggestion>> searchExternalPlaces({
    String? query,
    double? latitude,
    double? longitude,
  }) async {
    final response = await dioClient.dio.get(
      '/api/v1/places/external-search',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );

    final list = (response.data as List<dynamic>?) ?? [];
    return list.map((item) {
      final json = item as Map<String, dynamic>;
      return ExternalPlaceSuggestion(
        googlePlaceId: json['googlePlaceId'] as String,
        name: json['name'] as String,
        formattedAddress: json['formattedAddress'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        category: json['category'] as String,
        alreadyImportedId: json['alreadyImportedId'] as String?,
      );
    }).toList();
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
    final Map<String, dynamic> body = {
      'ratings': ratings,
    };
    if (generalComment != null && generalComment.trim().isNotEmpty) {
      body['generalComment'] = generalComment.trim();
    }
    if (mediaIds != null && mediaIds.isNotEmpty) {
      body['mediaIds'] = mediaIds;
    }

    final response = await dioClient.dio.post(
      '/api/v1/places/$placeId/reviews',
      data: body,
    );
    // On success, clear any stored draft
    await placesDao.deleteDraft(placeId);
    return _mapJsonToReview(response.data as Map<String, dynamic>);
  }

  @override
  Future<String> uploadPhoto({
    required String placeId,
    required String altText,
    required List<int> bytes,
    required String fileName,
    String mimeType = 'image/jpeg',
  }) async {
    final formData = FormData.fromMap({
      'placeId': placeId,
      'altText': altText,
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    final response = await dioClient.dio.post(
      '/api/v1/media/upload',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return (response.data as Map<String, dynamic>)['id'] as String;
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
    return await placesDao.getDraft(placeId);
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
      source: (json['source'] as String?) ?? (json['googlePlaceId'] != null ? 'GOOGLE_PLACES' : 'COMMUNITY'),
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
