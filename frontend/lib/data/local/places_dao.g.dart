// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'places_dao.dart';

// ignore_for_file: type=lint
mixin _$PlacesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CachedPlacesTable get cachedPlaces => attachedDatabase.cachedPlaces;
  $ReviewDraftsTable get reviewDrafts => attachedDatabase.reviewDrafts;
  PlacesDaoManager get managers => PlacesDaoManager(this);
}

class PlacesDaoManager {
  final _$PlacesDaoMixin _db;
  PlacesDaoManager(this._db);
  $$CachedPlacesTableTableManager get cachedPlaces =>
      $$CachedPlacesTableTableManager(_db.attachedDatabase, _db.cachedPlaces);
  $$ReviewDraftsTableTableManager get reviewDrafts =>
      $$ReviewDraftsTableTableManager(_db.attachedDatabase, _db.reviewDrafts);
}
