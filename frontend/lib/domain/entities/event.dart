import 'package:equatable/equatable.dart';

class EventOrganizer extends Equatable {
  final String id;
  final String name;
  final String handle;
  final String? avatarUrl;

  const EventOrganizer({
    required this.id,
    required this.name,
    required this.handle,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, handle];
}

class EventItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String locationName;
  final String address;
  final double? latitude;
  final double? longitude;
  final Map<String, bool> accessibilityChecklist;
  final int? maxAttendees;
  final String status;
  final int rsvpCount;
  final bool isAttending;
  final EventOrganizer organizer;

  const EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.locationName,
    required this.address,
    this.latitude,
    this.longitude,
    required this.accessibilityChecklist,
    this.maxAttendees,
    required this.status,
    required this.rsvpCount,
    required this.isAttending,
    required this.organizer,
  });

  @override
  List<Object?> get props => [id, title, startTime, status, rsvpCount, isAttending];
}
