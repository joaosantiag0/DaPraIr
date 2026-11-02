import '../entities/feed_item.dart';

abstract class FeedRepository {
  Future<FeedData> getFeed({double? latitude, double? longitude, int limit = 10});
}
