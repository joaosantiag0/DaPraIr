import 'package:equatable/equatable.dart';
import 'place.dart';

class ReviewRatingItem extends Equatable {
  final String criterionCode;
  final String criterionTitle;
  final int score;
  final String? notes;

  const ReviewRatingItem({
    required this.criterionCode,
    required this.criterionTitle,
    required this.score,
    this.notes,
  });

  @override
  List<Object?> get props => [criterionCode, score, notes];
}

class ReviewAuthor extends Equatable {
  final String id;
  final String name;
  final String handle;
  final String? avatarUrl;

  const ReviewAuthor({
    required this.id,
    required this.name,
    required this.handle,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, handle];
}

class Review extends Equatable {
  final String id;
  final String placeId;
  final ReviewAuthor author;
  final String? generalComment;
  final double averageScore;
  final int reportCount;
  final String status; // PUBLISHED, UNDER_REVIEW, etc.
  final DateTime createdAt;
  final List<ReviewRatingItem> ratings;
  final List<PlaceMediaItem> media;

  const Review({
    required this.id,
    required this.placeId,
    required this.author,
    this.generalComment,
    required this.averageScore,
    required this.reportCount,
    required this.status,
    required this.createdAt,
    this.ratings = const [],
    this.media = const [],
  });

  bool get isUnderReview => status == 'UNDER_REVIEW';

  @override
  List<Object?> get props => [id, placeId, averageScore, status, createdAt];
}
