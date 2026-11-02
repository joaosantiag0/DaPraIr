import 'package:dio/dio.dart';
import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final Dio dio;

  FeedRepositoryImpl(this.dio);

  @override
  Future<FeedData> getFeed({double? latitude, double? longitude, int limit = 10}) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };
    if (latitude != null) queryParams['latitude'] = latitude;
    if (longitude != null) queryParams['longitude'] = longitude;

    final response = await dio.get('/api/v1/feed', queryParameters: queryParams);
    final data = response.data as Map<String, dynamic>;

    final placesList = (data['highlightedPlaces'] as List<dynamic>? ?? []).map((json) {
      return HighlightedPlace(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        address: json['address'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        overallScore: (json['overallScore'] as num).toDouble(),
        totalReviews: json['totalReviews'] as int? ?? 0,
        coverImageUrl: json['coverImageUrl'] as String?,
      );
    }).toList();

    final reviewsList = (data['recentReviews'] as List<dynamic>? ?? []).map((json) {
      final author = json['author'] as Map<String, dynamic>? ?? {};
      final media = (json['media'] as List<dynamic>? ?? [])
          .map((m) => (m['thumbnailUrl'] ?? m['mediaUrl']) as String)
          .toList();

      return RecentFeedReview(
        id: json['id'] as String,
        placeId: json['placeId'] as String,
        placeName: json['placeName'] as String,
        placeAddress: json['placeAddress'] as String,
        generalComment: json['generalComment'] as String?,
        averageScore: (json['averageScore'] as num).toDouble(),
        status: json['status'] as String? ?? 'PUBLISHED',
        createdAt: DateTime.parse(json['createdAt'] as String),
        authorName: author['name'] as String? ?? 'Usuário',
        authorHandle: author['handle'] as String? ?? '@usuario',
        authorAvatarUrl: author['avatarUrl'] as String?,
        mediaThumbnails: media,
      );
    }).toList();

    final eventsList = (data['upcomingEvents'] as List<dynamic>? ?? []).map((json) {
      return FeedEventSummary(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        locationName: json['locationName'] as String,
        address: json['address'] as String,
        rsvpCount: json['rsvpCount'] as int? ?? 0,
        isAttending: json['isAttending'] as bool? ?? false,
        organizerName: json['organizerName'] as String? ?? 'Comunidade',
      );
    }).toList();

    final tipsList = (data['accessibilityTips'] as List<dynamic>? ?? []).map((json) {
      return AccessibilityTip(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        category: json['category'] as String,
      );
    }).toList();

    return FeedData(
      highlightedPlaces: placesList,
      recentReviews: reviewsList,
      upcomingEvents: eventsList,
      accessibilityTips: tipsList,
    );
  }
}
