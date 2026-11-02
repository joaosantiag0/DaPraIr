// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedPlacesTable extends CachedPlaces
    with TableInfo<$CachedPlacesTable, CachedPlace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPlacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _overallScoreMeta =
      const VerificationMeta('overallScore');
  @override
  late final GeneratedColumn<double> overallScore = GeneratedColumn<double>(
      'overall_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalReviewsMeta =
      const VerificationMeta('totalReviews');
  @override
  late final GeneratedColumn<int> totalReviews = GeneratedColumn<int>(
      'total_reviews', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        address,
        city,
        state,
        latitude,
        longitude,
        overallScore,
        totalReviews,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_places';
  @override
  VerificationContext validateIntegrity(Insertable<CachedPlace> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('overall_score')) {
      context.handle(
          _overallScoreMeta,
          overallScore.isAcceptableOrUnknown(
              data['overall_score']!, _overallScoreMeta));
    } else if (isInserting) {
      context.missing(_overallScoreMeta);
    }
    if (data.containsKey('total_reviews')) {
      context.handle(
          _totalReviewsMeta,
          totalReviews.isAcceptableOrUnknown(
              data['total_reviews']!, _totalReviewsMeta));
    } else if (isInserting) {
      context.missing(_totalReviewsMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPlace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPlace(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      overallScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}overall_score'])!,
      totalReviews: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_reviews'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedPlacesTable createAlias(String alias) {
    return $CachedPlacesTable(attachedDatabase, alias);
  }
}

class CachedPlace extends DataClass implements Insertable<CachedPlace> {
  final String id;
  final String name;
  final String category;
  final String address;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final double overallScore;
  final int totalReviews;
  final DateTime cachedAt;
  const CachedPlace(
      {required this.id,
      required this.name,
      required this.category,
      required this.address,
      required this.city,
      required this.state,
      required this.latitude,
      required this.longitude,
      required this.overallScore,
      required this.totalReviews,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['address'] = Variable<String>(address);
    map['city'] = Variable<String>(city);
    map['state'] = Variable<String>(state);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['overall_score'] = Variable<double>(overallScore);
    map['total_reviews'] = Variable<int>(totalReviews);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedPlacesCompanion toCompanion(bool nullToAbsent) {
    return CachedPlacesCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      address: Value(address),
      city: Value(city),
      state: Value(state),
      latitude: Value(latitude),
      longitude: Value(longitude),
      overallScore: Value(overallScore),
      totalReviews: Value(totalReviews),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedPlace.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPlace(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      address: serializer.fromJson<String>(json['address']),
      city: serializer.fromJson<String>(json['city']),
      state: serializer.fromJson<String>(json['state']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      overallScore: serializer.fromJson<double>(json['overallScore']),
      totalReviews: serializer.fromJson<int>(json['totalReviews']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'address': serializer.toJson<String>(address),
      'city': serializer.toJson<String>(city),
      'state': serializer.toJson<String>(state),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'overallScore': serializer.toJson<double>(overallScore),
      'totalReviews': serializer.toJson<int>(totalReviews),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedPlace copyWith(
          {String? id,
          String? name,
          String? category,
          String? address,
          String? city,
          String? state,
          double? latitude,
          double? longitude,
          double? overallScore,
          int? totalReviews,
          DateTime? cachedAt}) =>
      CachedPlace(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        address: address ?? this.address,
        city: city ?? this.city,
        state: state ?? this.state,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        overallScore: overallScore ?? this.overallScore,
        totalReviews: totalReviews ?? this.totalReviews,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedPlace copyWithCompanion(CachedPlacesCompanion data) {
    return CachedPlace(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      address: data.address.present ? data.address.value : this.address,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      overallScore: data.overallScore.present
          ? data.overallScore.value
          : this.overallScore,
      totalReviews: data.totalReviews.present
          ? data.totalReviews.value
          : this.totalReviews,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPlace(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('overallScore: $overallScore, ')
          ..write('totalReviews: $totalReviews, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, category, address, city, state,
      latitude, longitude, overallScore, totalReviews, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPlace &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.address == this.address &&
          other.city == this.city &&
          other.state == this.state &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.overallScore == this.overallScore &&
          other.totalReviews == this.totalReviews &&
          other.cachedAt == this.cachedAt);
}

class CachedPlacesCompanion extends UpdateCompanion<CachedPlace> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> address;
  final Value<String> city;
  final Value<String> state;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> overallScore;
  final Value<int> totalReviews;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedPlacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.totalReviews = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPlacesCompanion.insert({
    required String id,
    required String name,
    required String category,
    required String address,
    required String city,
    required String state,
    required double latitude,
    required double longitude,
    required double overallScore,
    required int totalReviews,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        category = Value(category),
        address = Value(address),
        city = Value(city),
        state = Value(state),
        latitude = Value(latitude),
        longitude = Value(longitude),
        overallScore = Value(overallScore),
        totalReviews = Value(totalReviews);
  static Insertable<CachedPlace> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? address,
    Expression<String>? city,
    Expression<String>? state,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? overallScore,
    Expression<int>? totalReviews,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (overallScore != null) 'overall_score': overallScore,
      if (totalReviews != null) 'total_reviews': totalReviews,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPlacesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? category,
      Value<String>? address,
      Value<String>? city,
      Value<String>? state,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<double>? overallScore,
      Value<int>? totalReviews,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return CachedPlacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      overallScore: overallScore ?? this.overallScore,
      totalReviews: totalReviews ?? this.totalReviews,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (overallScore.present) {
      map['overall_score'] = Variable<double>(overallScore.value);
    }
    if (totalReviews.present) {
      map['total_reviews'] = Variable<int>(totalReviews.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPlacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('overallScore: $overallScore, ')
          ..write('totalReviews: $totalReviews, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewDraftsTable extends ReviewDrafts
    with TableInfo<$ReviewDraftsTable, ReviewDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _placeIdMeta =
      const VerificationMeta('placeId');
  @override
  late final GeneratedColumn<String> placeId = GeneratedColumn<String>(
      'place_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _generalCommentMeta =
      const VerificationMeta('generalComment');
  @override
  late final GeneratedColumn<String> generalComment = GeneratedColumn<String>(
      'general_comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ratingsJsonMeta =
      const VerificationMeta('ratingsJson');
  @override
  late final GeneratedColumn<String> ratingsJson = GeneratedColumn<String>(
      'ratings_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _photosJsonMeta =
      const VerificationMeta('photosJson');
  @override
  late final GeneratedColumn<String> photosJson = GeneratedColumn<String>(
      'photos_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        placeId,
        generalComment,
        ratingsJson,
        photosJson,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_drafts';
  @override
  VerificationContext validateIntegrity(Insertable<ReviewDraft> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('place_id')) {
      context.handle(_placeIdMeta,
          placeId.isAcceptableOrUnknown(data['place_id']!, _placeIdMeta));
    } else if (isInserting) {
      context.missing(_placeIdMeta);
    }
    if (data.containsKey('general_comment')) {
      context.handle(
          _generalCommentMeta,
          generalComment.isAcceptableOrUnknown(
              data['general_comment']!, _generalCommentMeta));
    }
    if (data.containsKey('ratings_json')) {
      context.handle(
          _ratingsJsonMeta,
          ratingsJson.isAcceptableOrUnknown(
              data['ratings_json']!, _ratingsJsonMeta));
    } else if (isInserting) {
      context.missing(_ratingsJsonMeta);
    }
    if (data.containsKey('photos_json')) {
      context.handle(
          _photosJsonMeta,
          photosJson.isAcceptableOrUnknown(
              data['photos_json']!, _photosJsonMeta));
    } else if (isInserting) {
      context.missing(_photosJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewDraft(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      placeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}place_id'])!,
      generalComment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}general_comment']),
      ratingsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ratings_json'])!,
      photosJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photos_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ReviewDraftsTable createAlias(String alias) {
    return $ReviewDraftsTable(attachedDatabase, alias);
  }
}

class ReviewDraft extends DataClass implements Insertable<ReviewDraft> {
  final String id;
  final String placeId;
  final String? generalComment;
  final String ratingsJson;
  final String photosJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ReviewDraft(
      {required this.id,
      required this.placeId,
      this.generalComment,
      required this.ratingsJson,
      required this.photosJson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['place_id'] = Variable<String>(placeId);
    if (!nullToAbsent || generalComment != null) {
      map['general_comment'] = Variable<String>(generalComment);
    }
    map['ratings_json'] = Variable<String>(ratingsJson);
    map['photos_json'] = Variable<String>(photosJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReviewDraftsCompanion toCompanion(bool nullToAbsent) {
    return ReviewDraftsCompanion(
      id: Value(id),
      placeId: Value(placeId),
      generalComment: generalComment == null && nullToAbsent
          ? const Value.absent()
          : Value(generalComment),
      ratingsJson: Value(ratingsJson),
      photosJson: Value(photosJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReviewDraft.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewDraft(
      id: serializer.fromJson<String>(json['id']),
      placeId: serializer.fromJson<String>(json['placeId']),
      generalComment: serializer.fromJson<String?>(json['generalComment']),
      ratingsJson: serializer.fromJson<String>(json['ratingsJson']),
      photosJson: serializer.fromJson<String>(json['photosJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'placeId': serializer.toJson<String>(placeId),
      'generalComment': serializer.toJson<String?>(generalComment),
      'ratingsJson': serializer.toJson<String>(ratingsJson),
      'photosJson': serializer.toJson<String>(photosJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReviewDraft copyWith(
          {String? id,
          String? placeId,
          Value<String?> generalComment = const Value.absent(),
          String? ratingsJson,
          String? photosJson,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ReviewDraft(
        id: id ?? this.id,
        placeId: placeId ?? this.placeId,
        generalComment:
            generalComment.present ? generalComment.value : this.generalComment,
        ratingsJson: ratingsJson ?? this.ratingsJson,
        photosJson: photosJson ?? this.photosJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ReviewDraft copyWithCompanion(ReviewDraftsCompanion data) {
    return ReviewDraft(
      id: data.id.present ? data.id.value : this.id,
      placeId: data.placeId.present ? data.placeId.value : this.placeId,
      generalComment: data.generalComment.present
          ? data.generalComment.value
          : this.generalComment,
      ratingsJson:
          data.ratingsJson.present ? data.ratingsJson.value : this.ratingsJson,
      photosJson:
          data.photosJson.present ? data.photosJson.value : this.photosJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewDraft(')
          ..write('id: $id, ')
          ..write('placeId: $placeId, ')
          ..write('generalComment: $generalComment, ')
          ..write('ratingsJson: $ratingsJson, ')
          ..write('photosJson: $photosJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, placeId, generalComment, ratingsJson,
      photosJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewDraft &&
          other.id == this.id &&
          other.placeId == this.placeId &&
          other.generalComment == this.generalComment &&
          other.ratingsJson == this.ratingsJson &&
          other.photosJson == this.photosJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReviewDraftsCompanion extends UpdateCompanion<ReviewDraft> {
  final Value<String> id;
  final Value<String> placeId;
  final Value<String?> generalComment;
  final Value<String> ratingsJson;
  final Value<String> photosJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReviewDraftsCompanion({
    this.id = const Value.absent(),
    this.placeId = const Value.absent(),
    this.generalComment = const Value.absent(),
    this.ratingsJson = const Value.absent(),
    this.photosJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewDraftsCompanion.insert({
    required String id,
    required String placeId,
    this.generalComment = const Value.absent(),
    required String ratingsJson,
    required String photosJson,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        placeId = Value(placeId),
        ratingsJson = Value(ratingsJson),
        photosJson = Value(photosJson);
  static Insertable<ReviewDraft> custom({
    Expression<String>? id,
    Expression<String>? placeId,
    Expression<String>? generalComment,
    Expression<String>? ratingsJson,
    Expression<String>? photosJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (placeId != null) 'place_id': placeId,
      if (generalComment != null) 'general_comment': generalComment,
      if (ratingsJson != null) 'ratings_json': ratingsJson,
      if (photosJson != null) 'photos_json': photosJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewDraftsCompanion copyWith(
      {Value<String>? id,
      Value<String>? placeId,
      Value<String?>? generalComment,
      Value<String>? ratingsJson,
      Value<String>? photosJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ReviewDraftsCompanion(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      generalComment: generalComment ?? this.generalComment,
      ratingsJson: ratingsJson ?? this.ratingsJson,
      photosJson: photosJson ?? this.photosJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (placeId.present) {
      map['place_id'] = Variable<String>(placeId.value);
    }
    if (generalComment.present) {
      map['general_comment'] = Variable<String>(generalComment.value);
    }
    if (ratingsJson.present) {
      map['ratings_json'] = Variable<String>(ratingsJson.value);
    }
    if (photosJson.present) {
      map['photos_json'] = Variable<String>(photosJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewDraftsCompanion(')
          ..write('id: $id, ')
          ..write('placeId: $placeId, ')
          ..write('generalComment: $generalComment, ')
          ..write('ratingsJson: $ratingsJson, ')
          ..write('photosJson: $photosJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedEventsTable extends CachedEvents
    with TableInfo<$CachedEventsTable, CachedEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _locationNameMeta =
      const VerificationMeta('locationName');
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
      'location_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accessibilityChecklistJsonMeta =
      const VerificationMeta('accessibilityChecklistJson');
  @override
  late final GeneratedColumn<String> accessibilityChecklistJson =
      GeneratedColumn<String>(
          'accessibility_checklist_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        startTime,
        locationName,
        address,
        accessibilityChecklistJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_events';
  @override
  VerificationContext validateIntegrity(Insertable<CachedEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('location_name')) {
      context.handle(
          _locationNameMeta,
          locationName.isAcceptableOrUnknown(
              data['location_name']!, _locationNameMeta));
    } else if (isInserting) {
      context.missing(_locationNameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('accessibility_checklist_json')) {
      context.handle(
          _accessibilityChecklistJsonMeta,
          accessibilityChecklistJson.isAcceptableOrUnknown(
              data['accessibility_checklist_json']!,
              _accessibilityChecklistJsonMeta));
    } else if (isInserting) {
      context.missing(_accessibilityChecklistJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      locationName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      accessibilityChecklistJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}accessibility_checklist_json'])!,
    );
  }

  @override
  $CachedEventsTable createAlias(String alias) {
    return $CachedEventsTable(attachedDatabase, alias);
  }
}

class CachedEvent extends DataClass implements Insertable<CachedEvent> {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final String locationName;
  final String address;
  final String accessibilityChecklistJson;
  const CachedEvent(
      {required this.id,
      required this.title,
      required this.description,
      required this.startTime,
      required this.locationName,
      required this.address,
      required this.accessibilityChecklistJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['start_time'] = Variable<DateTime>(startTime);
    map['location_name'] = Variable<String>(locationName);
    map['address'] = Variable<String>(address);
    map['accessibility_checklist_json'] =
        Variable<String>(accessibilityChecklistJson);
    return map;
  }

  CachedEventsCompanion toCompanion(bool nullToAbsent) {
    return CachedEventsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      startTime: Value(startTime),
      locationName: Value(locationName),
      address: Value(address),
      accessibilityChecklistJson: Value(accessibilityChecklistJson),
    );
  }

  factory CachedEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedEvent(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      locationName: serializer.fromJson<String>(json['locationName']),
      address: serializer.fromJson<String>(json['address']),
      accessibilityChecklistJson:
          serializer.fromJson<String>(json['accessibilityChecklistJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'startTime': serializer.toJson<DateTime>(startTime),
      'locationName': serializer.toJson<String>(locationName),
      'address': serializer.toJson<String>(address),
      'accessibilityChecklistJson':
          serializer.toJson<String>(accessibilityChecklistJson),
    };
  }

  CachedEvent copyWith(
          {String? id,
          String? title,
          String? description,
          DateTime? startTime,
          String? locationName,
          String? address,
          String? accessibilityChecklistJson}) =>
      CachedEvent(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        startTime: startTime ?? this.startTime,
        locationName: locationName ?? this.locationName,
        address: address ?? this.address,
        accessibilityChecklistJson:
            accessibilityChecklistJson ?? this.accessibilityChecklistJson,
      );
  CachedEvent copyWithCompanion(CachedEventsCompanion data) {
    return CachedEvent(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      address: data.address.present ? data.address.value : this.address,
      accessibilityChecklistJson: data.accessibilityChecklistJson.present
          ? data.accessibilityChecklistJson.value
          : this.accessibilityChecklistJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedEvent(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startTime: $startTime, ')
          ..write('locationName: $locationName, ')
          ..write('address: $address, ')
          ..write('accessibilityChecklistJson: $accessibilityChecklistJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, startTime,
      locationName, address, accessibilityChecklistJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedEvent &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.startTime == this.startTime &&
          other.locationName == this.locationName &&
          other.address == this.address &&
          other.accessibilityChecklistJson == this.accessibilityChecklistJson);
}

class CachedEventsCompanion extends UpdateCompanion<CachedEvent> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> startTime;
  final Value<String> locationName;
  final Value<String> address;
  final Value<String> accessibilityChecklistJson;
  final Value<int> rowid;
  const CachedEventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.startTime = const Value.absent(),
    this.locationName = const Value.absent(),
    this.address = const Value.absent(),
    this.accessibilityChecklistJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedEventsCompanion.insert({
    required String id,
    required String title,
    required String description,
    required DateTime startTime,
    required String locationName,
    required String address,
    required String accessibilityChecklistJson,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description),
        startTime = Value(startTime),
        locationName = Value(locationName),
        address = Value(address),
        accessibilityChecklistJson = Value(accessibilityChecklistJson);
  static Insertable<CachedEvent> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? startTime,
    Expression<String>? locationName,
    Expression<String>? address,
    Expression<String>? accessibilityChecklistJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startTime != null) 'start_time': startTime,
      if (locationName != null) 'location_name': locationName,
      if (address != null) 'address': address,
      if (accessibilityChecklistJson != null)
        'accessibility_checklist_json': accessibilityChecklistJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<DateTime>? startTime,
      Value<String>? locationName,
      Value<String>? address,
      Value<String>? accessibilityChecklistJson,
      Value<int>? rowid}) {
    return CachedEventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      locationName: locationName ?? this.locationName,
      address: address ?? this.address,
      accessibilityChecklistJson:
          accessibilityChecklistJson ?? this.accessibilityChecklistJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (accessibilityChecklistJson.present) {
      map['accessibility_checklist_json'] =
          Variable<String>(accessibilityChecklistJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedEventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startTime: $startTime, ')
          ..write('locationName: $locationName, ')
          ..write('address: $address, ')
          ..write('accessibilityChecklistJson: $accessibilityChecklistJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedPlacesTable cachedPlaces = $CachedPlacesTable(this);
  late final $ReviewDraftsTable reviewDrafts = $ReviewDraftsTable(this);
  late final $CachedEventsTable cachedEvents = $CachedEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cachedPlaces, reviewDrafts, cachedEvents];
}

typedef $$CachedPlacesTableCreateCompanionBuilder = CachedPlacesCompanion
    Function({
  required String id,
  required String name,
  required String category,
  required String address,
  required String city,
  required String state,
  required double latitude,
  required double longitude,
  required double overallScore,
  required int totalReviews,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});
typedef $$CachedPlacesTableUpdateCompanionBuilder = CachedPlacesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<String> address,
  Value<String> city,
  Value<String> state,
  Value<double> latitude,
  Value<double> longitude,
  Value<double> overallScore,
  Value<int> totalReviews,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$CachedPlacesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedPlacesTable> {
  $$CachedPlacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get overallScore => $composableBuilder(
      column: $table.overallScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalReviews => $composableBuilder(
      column: $table.totalReviews, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedPlacesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedPlacesTable> {
  $$CachedPlacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get overallScore => $composableBuilder(
      column: $table.overallScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalReviews => $composableBuilder(
      column: $table.totalReviews,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedPlacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedPlacesTable> {
  $$CachedPlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get overallScore => $composableBuilder(
      column: $table.overallScore, builder: (column) => column);

  GeneratedColumn<int> get totalReviews => $composableBuilder(
      column: $table.totalReviews, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedPlacesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedPlacesTable,
    CachedPlace,
    $$CachedPlacesTableFilterComposer,
    $$CachedPlacesTableOrderingComposer,
    $$CachedPlacesTableAnnotationComposer,
    $$CachedPlacesTableCreateCompanionBuilder,
    $$CachedPlacesTableUpdateCompanionBuilder,
    (
      CachedPlace,
      BaseReferences<_$AppDatabase, $CachedPlacesTable, CachedPlace>
    ),
    CachedPlace,
    PrefetchHooks Function()> {
  $$CachedPlacesTableTableManager(_$AppDatabase db, $CachedPlacesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedPlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedPlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> city = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<double> overallScore = const Value.absent(),
            Value<int> totalReviews = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedPlacesCompanion(
            id: id,
            name: name,
            category: category,
            address: address,
            city: city,
            state: state,
            latitude: latitude,
            longitude: longitude,
            overallScore: overallScore,
            totalReviews: totalReviews,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String category,
            required String address,
            required String city,
            required String state,
            required double latitude,
            required double longitude,
            required double overallScore,
            required int totalReviews,
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedPlacesCompanion.insert(
            id: id,
            name: name,
            category: category,
            address: address,
            city: city,
            state: state,
            latitude: latitude,
            longitude: longitude,
            overallScore: overallScore,
            totalReviews: totalReviews,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedPlacesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedPlacesTable,
    CachedPlace,
    $$CachedPlacesTableFilterComposer,
    $$CachedPlacesTableOrderingComposer,
    $$CachedPlacesTableAnnotationComposer,
    $$CachedPlacesTableCreateCompanionBuilder,
    $$CachedPlacesTableUpdateCompanionBuilder,
    (
      CachedPlace,
      BaseReferences<_$AppDatabase, $CachedPlacesTable, CachedPlace>
    ),
    CachedPlace,
    PrefetchHooks Function()>;
typedef $$ReviewDraftsTableCreateCompanionBuilder = ReviewDraftsCompanion
    Function({
  required String id,
  required String placeId,
  Value<String?> generalComment,
  required String ratingsJson,
  required String photosJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ReviewDraftsTableUpdateCompanionBuilder = ReviewDraftsCompanion
    Function({
  Value<String> id,
  Value<String> placeId,
  Value<String?> generalComment,
  Value<String> ratingsJson,
  Value<String> photosJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ReviewDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewDraftsTable> {
  $$ReviewDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get placeId => $composableBuilder(
      column: $table.placeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get generalComment => $composableBuilder(
      column: $table.generalComment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ratingsJson => $composableBuilder(
      column: $table.ratingsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photosJson => $composableBuilder(
      column: $table.photosJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ReviewDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewDraftsTable> {
  $$ReviewDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get placeId => $composableBuilder(
      column: $table.placeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get generalComment => $composableBuilder(
      column: $table.generalComment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ratingsJson => $composableBuilder(
      column: $table.ratingsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photosJson => $composableBuilder(
      column: $table.photosJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ReviewDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewDraftsTable> {
  $$ReviewDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get placeId =>
      $composableBuilder(column: $table.placeId, builder: (column) => column);

  GeneratedColumn<String> get generalComment => $composableBuilder(
      column: $table.generalComment, builder: (column) => column);

  GeneratedColumn<String> get ratingsJson => $composableBuilder(
      column: $table.ratingsJson, builder: (column) => column);

  GeneratedColumn<String> get photosJson => $composableBuilder(
      column: $table.photosJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReviewDraftsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReviewDraftsTable,
    ReviewDraft,
    $$ReviewDraftsTableFilterComposer,
    $$ReviewDraftsTableOrderingComposer,
    $$ReviewDraftsTableAnnotationComposer,
    $$ReviewDraftsTableCreateCompanionBuilder,
    $$ReviewDraftsTableUpdateCompanionBuilder,
    (
      ReviewDraft,
      BaseReferences<_$AppDatabase, $ReviewDraftsTable, ReviewDraft>
    ),
    ReviewDraft,
    PrefetchHooks Function()> {
  $$ReviewDraftsTableTableManager(_$AppDatabase db, $ReviewDraftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> placeId = const Value.absent(),
            Value<String?> generalComment = const Value.absent(),
            Value<String> ratingsJson = const Value.absent(),
            Value<String> photosJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewDraftsCompanion(
            id: id,
            placeId: placeId,
            generalComment: generalComment,
            ratingsJson: ratingsJson,
            photosJson: photosJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String placeId,
            Value<String?> generalComment = const Value.absent(),
            required String ratingsJson,
            required String photosJson,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewDraftsCompanion.insert(
            id: id,
            placeId: placeId,
            generalComment: generalComment,
            ratingsJson: ratingsJson,
            photosJson: photosJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReviewDraftsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReviewDraftsTable,
    ReviewDraft,
    $$ReviewDraftsTableFilterComposer,
    $$ReviewDraftsTableOrderingComposer,
    $$ReviewDraftsTableAnnotationComposer,
    $$ReviewDraftsTableCreateCompanionBuilder,
    $$ReviewDraftsTableUpdateCompanionBuilder,
    (
      ReviewDraft,
      BaseReferences<_$AppDatabase, $ReviewDraftsTable, ReviewDraft>
    ),
    ReviewDraft,
    PrefetchHooks Function()>;
typedef $$CachedEventsTableCreateCompanionBuilder = CachedEventsCompanion
    Function({
  required String id,
  required String title,
  required String description,
  required DateTime startTime,
  required String locationName,
  required String address,
  required String accessibilityChecklistJson,
  Value<int> rowid,
});
typedef $$CachedEventsTableUpdateCompanionBuilder = CachedEventsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<DateTime> startTime,
  Value<String> locationName,
  Value<String> address,
  Value<String> accessibilityChecklistJson,
  Value<int> rowid,
});

class $$CachedEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedEventsTable> {
  $$CachedEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationName => $composableBuilder(
      column: $table.locationName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accessibilityChecklistJson => $composableBuilder(
      column: $table.accessibilityChecklistJson,
      builder: (column) => ColumnFilters(column));
}

class $$CachedEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedEventsTable> {
  $$CachedEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationName => $composableBuilder(
      column: $table.locationName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accessibilityChecklistJson => $composableBuilder(
      column: $table.accessibilityChecklistJson,
      builder: (column) => ColumnOrderings(column));
}

class $$CachedEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedEventsTable> {
  $$CachedEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get locationName => $composableBuilder(
      column: $table.locationName, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get accessibilityChecklistJson => $composableBuilder(
      column: $table.accessibilityChecklistJson, builder: (column) => column);
}

class $$CachedEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedEventsTable,
    CachedEvent,
    $$CachedEventsTableFilterComposer,
    $$CachedEventsTableOrderingComposer,
    $$CachedEventsTableAnnotationComposer,
    $$CachedEventsTableCreateCompanionBuilder,
    $$CachedEventsTableUpdateCompanionBuilder,
    (
      CachedEvent,
      BaseReferences<_$AppDatabase, $CachedEventsTable, CachedEvent>
    ),
    CachedEvent,
    PrefetchHooks Function()> {
  $$CachedEventsTableTableManager(_$AppDatabase db, $CachedEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<String> locationName = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> accessibilityChecklistJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedEventsCompanion(
            id: id,
            title: title,
            description: description,
            startTime: startTime,
            locationName: locationName,
            address: address,
            accessibilityChecklistJson: accessibilityChecklistJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String description,
            required DateTime startTime,
            required String locationName,
            required String address,
            required String accessibilityChecklistJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedEventsCompanion.insert(
            id: id,
            title: title,
            description: description,
            startTime: startTime,
            locationName: locationName,
            address: address,
            accessibilityChecklistJson: accessibilityChecklistJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedEventsTable,
    CachedEvent,
    $$CachedEventsTableFilterComposer,
    $$CachedEventsTableOrderingComposer,
    $$CachedEventsTableAnnotationComposer,
    $$CachedEventsTableCreateCompanionBuilder,
    $$CachedEventsTableUpdateCompanionBuilder,
    (
      CachedEvent,
      BaseReferences<_$AppDatabase, $CachedEventsTable, CachedEvent>
    ),
    CachedEvent,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedPlacesTableTableManager get cachedPlaces =>
      $$CachedPlacesTableTableManager(_db, _db.cachedPlaces);
  $$ReviewDraftsTableTableManager get reviewDrafts =>
      $$ReviewDraftsTableTableManager(_db, _db.reviewDrafts);
  $$CachedEventsTableTableManager get cachedEvents =>
      $$CachedEventsTableTableManager(_db, _db.cachedEvents);
}
