import 'package:equatable/equatable.dart';

class HighlightedPlace extends Equatable {
  final String id;
  final String name;
  final String category;
  final String address;
  final double latitude;
  final double longitude;
  final double overallScore;
  final int totalReviews;
  final String? coverImageUrl;

  const HighlightedPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.overallScore,
    required this.totalReviews,
    this.coverImageUrl,
  });

  @override
  List<Object?> get props => [id, name, overallScore, totalReviews];
}

class RecentFeedReview extends Equatable {
  final String id;
  final String placeId;
  final String placeName;
  final String placeAddress;
  final String? generalComment;
  final double averageScore;
  final String status;
  final DateTime createdAt;
  final String authorName;
  final String authorHandle;
  final String? authorAvatarUrl;
  final List<String> mediaThumbnails;

  const RecentFeedReview({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.placeAddress,
    this.generalComment,
    required this.averageScore,
    required this.status,
    required this.createdAt,
    required this.authorName,
    required this.authorHandle,
    this.authorAvatarUrl,
    required this.mediaThumbnails,
  });

  @override
  List<Object?> get props => [id, placeId, averageScore, status];
}

class FeedEventSummary extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String locationName;
  final String address;
  final int rsvpCount;
  final bool isAttending;
  final String organizerName;

  const FeedEventSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.locationName,
    required this.address,
    required this.rsvpCount,
    required this.isAttending,
    required this.organizerName,
  });

  @override
  List<Object?> get props => [id, title, startTime, rsvpCount, isAttending];
}

class AccessibilityTip extends Equatable {
  final String id;
  final String title;
  final String content;
  final String category;

  const AccessibilityTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
  });

  @override
  List<Object?> get props => [id, title, category];
}

class FeedData extends Equatable {
  final List<HighlightedPlace> highlightedPlaces;
  final List<RecentFeedReview> recentReviews;
  final List<FeedEventSummary> upcomingEvents;
  final List<AccessibilityTip> accessibilityTips;

  const FeedData({
    required this.highlightedPlaces,
    required this.recentReviews,
    required this.upcomingEvents,
    required this.accessibilityTips,
  });

  @override
  List<Object?> get props => [highlightedPlaces, recentReviews, upcomingEvents, accessibilityTips];
}
