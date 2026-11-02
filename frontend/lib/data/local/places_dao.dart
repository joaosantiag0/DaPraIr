import 'dart:convert';
import 'package:drift/drift.dart';
import 'app_database.dart';

part 'places_dao.g.dart';

@DriftAccessor(tables: [CachedPlaces, ReviewDrafts])
class PlacesDao extends DatabaseAccessor<AppDatabase> with _$PlacesDaoMixin {
  PlacesDao(super.db);

  Future<void> cachePlaces(List<CachedPlacesCompanion> places) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(cachedPlaces, places);
    });
  }

  Future<List<CachedPlace>> getCachedPlaces() => select(cachedPlaces).get();

  Future<void> saveDraft({
    required String placeId,
    String? generalComment,
    required Map<String, int> ratings,
    List<Map<String, String>> photos = const [],
  }) async {
    final entry = ReviewDraftsCompanion(
      id: Value(placeId),
      placeId: Value(placeId),
      generalComment: Value(generalComment),
      ratingsJson: Value(jsonEncode(ratings)),
      photosJson: Value(jsonEncode(photos)),
      updatedAt: Value(DateTime.now()),
    );
    await into(reviewDrafts).insertOnConflictUpdate(entry);
  }

  Future<ReviewDraft?> getDraft(String placeId) async {
    return (select(reviewDrafts)..where((tbl) => tbl.placeId.equals(placeId))).getSingleOrNull();
  }

  Future<void> deleteDraft(String placeId) async {
    await (delete(reviewDrafts)..where((tbl) => tbl.placeId.equals(placeId))).go();
  }
}
