import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;

part 'app_database.g.dart';

class CachedPlaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get address => text()();
  TextColumn get city => text()();
  TextColumn get state => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get overallScore => real()();
  IntColumn get totalReviews => integer()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ReviewDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get placeId => text()();
  TextColumn get generalComment => text().nullable()();
  TextColumn get ratingsJson => text()(); // JSON string of criterionId -> score
  TextColumn get photosJson => text()(); // JSON string of [{ localPath, altText }]
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedEvents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get startTime => dateTime()();
  TextColumn get locationName => text()();
  TextColumn get address => text()();
  TextColumn get accessibilityChecklistJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

QueryExecutor _openConnection() {
  return impl.connect();
}

@DriftDatabase(tables: [CachedPlaces, ReviewDrafts, CachedEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;
}
