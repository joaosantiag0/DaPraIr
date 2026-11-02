import '../entities/place.dart';
import '../entities/review.dart';

abstract class PlacesRepository {
  Future<List<Place>> searchPlaces({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    String? query,
    String? category,
    List<String>? requiredCriteria,
    int limit = 20,
    int offset = 0,
  });

  Future<Place> getPlaceDetails(String placeId);

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
  });

  Future<List<Review>> getPlaceReviews(String placeId, {int limit = 10, int offset = 0});

  Future<Review> submitReview({
    required String placeId,
    String? generalComment,
    required List<Map<String, dynamic>> ratings,
    List<String>? mediaIds,
  });

  Future<void> saveReviewDraft({
    required String placeId,
    String? generalComment,
    required Map<String, int> ratings,
    List<Map<String, String>> photos = const [],
  });

  Future<Map<String, dynamic>?> getReviewDraft(String placeId);

  Future<void> clearReviewDraft(String placeId);
}
