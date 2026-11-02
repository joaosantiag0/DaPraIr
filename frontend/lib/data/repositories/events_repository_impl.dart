import 'package:dio/dio.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';

class EventsRepositoryImpl implements EventsRepository {
  final Dio dio;

  EventsRepositoryImpl(this.dio);

  @override
  Future<List<EventItem>> getEvents({String? accessibilityFeature}) async {
    final queryParams = <String, dynamic>{};
    if (accessibilityFeature != null && accessibilityFeature.isNotEmpty) {
      queryParams['accessibilityFeature'] = accessibilityFeature;
    }

    final response = await dio.get('/api/v1/events', queryParameters: queryParams);
    final data = response.data as List<dynamic>;

    return data.map((json) => _mapToEventItem(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<EventItem> createEvent({
    String? placeId,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String locationName,
    required String address,
    double? latitude,
    double? longitude,
    required Map<String, bool> accessibilityChecklist,
    int? maxAttendees,
  }) async {
    final response = await dio.post('/api/v1/events', data: {
      if (placeId != null) 'placeId': placeId,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'locationName': locationName,
      'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'accessibilityChecklist': accessibilityChecklist,
      if (maxAttendees != null) 'maxAttendees': maxAttendees,
    });

    return _mapToEventItem(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> registerRSVP(String eventId, {String status = 'CONFIRMED'}) async {
    await dio.post('/api/v1/events/$eventId/rsvp', data: {
      'status': status,
    });
  }

  EventItem _mapToEventItem(Map<String, dynamic> json) {
    final organizerJson = json['organizer'] as Map<String, dynamic>;
    final checklistRaw = json['accessibilityChecklist'] as Map<String, dynamic>? ?? {};
    final checklist = checklistRaw.map((k, v) => MapEntry(k, v == true));

    return EventItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      locationName: json['locationName'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      accessibilityChecklist: checklist,
      maxAttendees: json['maxAttendees'] as int?,
      status: json['status'] as String? ?? 'SCHEDULED',
      rsvpCount: json['rsvpCount'] as int? ?? 0,
      isAttending: json['isAttending'] as bool? ?? false,
      organizer: EventOrganizer(
        id: organizerJson['id'] as String,
        name: organizerJson['name'] as String,
        handle: organizerJson['handle'] as String,
        avatarUrl: organizerJson['avatar_url'] as String?,
      ),
    );
  }
}
