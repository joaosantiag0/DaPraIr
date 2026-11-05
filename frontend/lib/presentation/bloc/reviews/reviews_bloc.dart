import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/base/equatable.dart';
import '../../../domain/entities/review.dart';
import '../../../domain/repositories/places_repository.dart';

// Events
abstract class ReviewsEvent extends Equatable {
  const ReviewsEvent();
  @override
  List<Object?> get props => [];
}

class LoadReviewsEvent extends ReviewsEvent {
  final String placeId;
  const LoadReviewsEvent(this.placeId);
  @override
  List<Object?> get props => [placeId];
}

class SubmitReviewEvent extends ReviewsEvent {
  final String placeId;
  final String? generalComment;
  final List<Map<String, dynamic>> ratings;
  final List<String>? mediaIds;
  final List<int>? photoBytes;
  final String? photoAltText;
  final String? photoFileName;

  const SubmitReviewEvent({
    required this.placeId,
    this.generalComment,
    required this.ratings,
    this.mediaIds,
    this.photoBytes,
    this.photoAltText,
    this.photoFileName,
  });

  @override
  List<Object?> get props => [
        placeId,
        generalComment,
        ratings,
        mediaIds,
        photoBytes,
        photoAltText,
        photoFileName,
      ];
}

class SaveReviewDraftEvent extends ReviewsEvent {
  final String placeId;
  final String? generalComment;
  final Map<String, int> ratings;
  final List<Map<String, String>> photos;

  const SaveReviewDraftEvent({
    required this.placeId,
    this.generalComment,
    required this.ratings,
    this.photos = const [],
  });

  @override
  List<Object?> get props => [placeId, generalComment, ratings, photos];
}

class LoadReviewDraftEvent extends ReviewsEvent {
  final String placeId;
  const LoadReviewDraftEvent(this.placeId);
  @override
  List<Object?> get props => [placeId];
}

// States
abstract class ReviewsState extends Equatable {
  const ReviewsState();
  @override
  List<Object?> get props => [];
}

class ReviewsInitial extends ReviewsState {}
class ReviewsLoading extends ReviewsState {}

class ReviewsLoaded extends ReviewsState {
  final List<Review> reviews;
  final Map<String, dynamic>? draft;
  final bool submitSuccess;

  const ReviewsLoaded({
    required this.reviews,
    this.draft,
    this.submitSuccess = false,
  });

  ReviewsLoaded copyWith({
    List<Review>? reviews,
    Map<String, dynamic>? draft,
    bool? submitSuccess,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? this.reviews,
      draft: draft ?? this.draft,
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }

  @override
  List<Object?> get props => [reviews, draft, submitSuccess];
}

class ReviewsError extends ReviewsState {
  final String message;
  const ReviewsError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  final PlacesRepository repository;

  ReviewsBloc({required this.repository}) : super(ReviewsInitial()) {
    on<LoadReviewsEvent>(_onLoadReviews);
    on<SubmitReviewEvent>(_onSubmitReview);
    on<SaveReviewDraftEvent>(_onSaveDraft);
    on<LoadReviewDraftEvent>(_onLoadDraft);
  }

  Future<void> _onLoadReviews(LoadReviewsEvent event, Emitter<ReviewsState> emit) async {
    emit(ReviewsLoading());
    try {
      final reviews = await repository.getPlaceReviews(event.placeId);
      final draft = await repository.getReviewDraft(event.placeId);
      emit(ReviewsLoaded(reviews: reviews, draft: draft));
    } catch (e) {
      emit(ReviewsError(e.toString()));
    }
  }

  Future<void> _onSubmitReview(SubmitReviewEvent event, Emitter<ReviewsState> emit) async {
    emit(ReviewsLoading());
    try {
      List<String>? effectiveMediaIds = event.mediaIds != null ? List<String>.from(event.mediaIds!) : null;

      if (event.photoBytes != null &&
          event.photoAltText != null &&
          event.photoAltText!.trim().length >= 5) {
        final uploadedMediaId = await repository.uploadPhoto(
          placeId: event.placeId,
          altText: event.photoAltText!.trim(),
          bytes: event.photoBytes!,
          fileName: event.photoFileName ?? 'review_photo.jpg',
        );
        effectiveMediaIds = [...(effectiveMediaIds ?? []), uploadedMediaId];
      }

      final review = await repository.submitReview(
        placeId: event.placeId,
        generalComment: event.generalComment,
        ratings: event.ratings,
        mediaIds: effectiveMediaIds,
      );
      final updatedReviews = await repository.getPlaceReviews(event.placeId);
      emit(ReviewsLoaded(
        reviews: updatedReviews.isNotEmpty ? updatedReviews : [review],
        draft: null,
        submitSuccess: true,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          errorMessage = data['message'].toString();
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'Você precisa estar logado para publicar uma avaliação.';
        }
      }
      emit(ReviewsError(errorMessage));
    }
  }

  Future<void> _onSaveDraft(SaveReviewDraftEvent event, Emitter<ReviewsState> emit) async {
    try {
      await repository.saveReviewDraft(
        placeId: event.placeId,
        generalComment: event.generalComment,
        ratings: event.ratings,
        photos: event.photos,
      );
      if (state is ReviewsLoaded) {
        emit((state as ReviewsLoaded).copyWith(
          draft: {
            'placeId': event.placeId,
            'generalComment': event.generalComment,
            'ratings': event.ratings,
            'photos': event.photos,
          },
        ));
      }
    } catch (_) {}
  }

  Future<void> _onLoadDraft(LoadReviewDraftEvent event, Emitter<ReviewsState> emit) async {
    try {
      final draft = await repository.getReviewDraft(event.placeId);
      if (state is ReviewsLoaded) {
        emit((state as ReviewsLoaded).copyWith(draft: draft));
      }
    } catch (_) {}
  }
}
