import '../entities/event.dart';

abstract class EventsRepository {
  Future<List<EventItem>> getEvents({String? accessibilityFeature});

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
  });

  Future<void> registerRSVP(String eventId, {String status = 'CONFIRMED'});
}
