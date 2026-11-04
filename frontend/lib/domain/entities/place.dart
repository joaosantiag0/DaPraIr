import 'package:frontend/core/base/equatable.dart';

class PlaceCriterionSummary extends Equatable {
  final String id;
  final String code;
  final String title;
  final String iconName;
  final double averageScore;
  final int ratingsCount;

  const PlaceCriterionSummary({
    required this.id,
    required this.code,
    required this.title,
    required this.iconName,
    required this.averageScore,
    required this.ratingsCount,
  });

  @override
  List<Object?> get props => [id, code, title, averageScore, ratingsCount];
}

class PlaceMediaItem extends Equatable {
  final String id;
  final String mediaUrl;
  final String thumbnailUrl;
  final String altText;

  const PlaceMediaItem({
    required this.id,
    required this.mediaUrl,
    required this.thumbnailUrl,
    required this.altText,
  });

  @override
  List<Object?> get props => [id, mediaUrl, altText];
}

class Place extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String category;
  final String address;
  final String city;
  final String state;
  final String? postalCode;
  final double latitude;
  final double longitude;
  final double overallScore;
  final int totalReviews;
  final DateTime? lastReviewedAt;
  final bool isOutdated;
  final int? distanceMeters;
  final String source;
  final List<PlaceCriterionSummary> criteriaBreakdown;
  final List<PlaceMediaItem> media;

  const Place({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.address,
    required this.city,
    required this.state,
    this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.overallScore,
    required this.totalReviews,
    this.lastReviewedAt,
    this.isOutdated = false,
    this.distanceMeters,
    this.source = 'COMMUNITY',
    this.criteriaBreakdown = const [],
    this.media = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        address,
        latitude,
        longitude,
        overallScore,
        totalReviews,
        isOutdated,
      ];
}

class ExternalPlaceSuggestion extends Equatable {
  final String googlePlaceId;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String category;
  final String? alreadyImportedId;

  const ExternalPlaceSuggestion({
    required this.googlePlaceId,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.alreadyImportedId,
  });

  @override
  List<Object?> get props => [
        googlePlaceId,
        name,
        formattedAddress,
        latitude,
        longitude,
        category,
        alreadyImportedId,
      ];
}
