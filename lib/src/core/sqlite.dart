import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:drift/drift.dart';

part 'sqlite.g.dart';

class Feeds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get link => text()();
  TextColumn get url => text().customConstraint("UNIQUE")();
  TextColumn get icon => text()();
}

class FeedItems extends Table {
  IntColumn get feedId => integer()();
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get source => text()();
  TextColumn get description => text()();
  TextColumn get content => text()();
  TextColumn get link => text().customConstraint("UNIQUE")();
  TextColumn get guid => text()();
  DateTimeColumn get publishedAt => dateTime().named('published_at')();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
  BoolColumn get starred => boolean().withDefault(const Constant(false))();
}

openDBConnection({
  bool logStatements = false,
}) {
  const filename = 'thunderbird_rss.sqlite';
  if (Platform.isIOS || Platform.isAndroid) {
    // the LazyDatabase util lets us find the right location for the file async.
    return LazyDatabase(() async {
      // put the database file, called db.sqlite here, into the documents folder
      // for your app.
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(path.join(dbFolder.path, filename));
      return NativeDatabase(file);
    });
  }

  if (Platform.isMacOS || Platform.isLinux) {
    final file = File(filename);
    return NativeDatabase(file, logStatements: logStatements);
  }

  if (Platform.isWindows) {
    final file = File(filename);
    return NativeDatabase(file, logStatements: logStatements);
  }

  return NativeDatabase.memory(logStatements: logStatements);
}

// this annotation tells drift to prepare a database class that uses both of the
// tables we just defined. We'll see how to use that database class in a moment.
@DriftDatabase(tables: [Feeds, FeedItems], daos: [FeedsDao, FeedItemsDao])
class ThunderBirdRSSDataBase extends _$ThunderBirdRSSDataBase {
  ThunderBirdRSSDataBase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}

@DriftAccessor(tables: [Feeds])
class FeedsDao extends DatabaseAccessor<ThunderBirdRSSDataBase>
    with _$FeedsDaoMixin {
  FeedsDao(ThunderBirdRSSDataBase db) : super(db);

  Future<List<Feed>> get all => select(feeds).get();

  Future<Feed?> find(int id) {
    return (select(feeds)
          ..where((tbl) => tbl.id.equals(id))
          ..orderBy(
            [
              (u) => OrderingTerm(expression: u.id, mode: OrderingMode.asc),
            ],
          ))
        .getSingleOrNull();
  }

  Future<int> insert(FeedsCompanion entry) {
    return into(feeds).insert(entry);
  }

  Future<int> remove(int feedId) {
    return (delete(feeds)..where((t) => t.id.equals(feedId))).go();
  }
}

@DriftAccessor(tables: [FeedItems])
class FeedItemsDao extends DatabaseAccessor<ThunderBirdRSSDataBase>
    with _$FeedItemsDaoMixin {
  FeedItemsDao(ThunderBirdRSSDataBase db) : super(db);

  Future<List<FeedItem>> findItems({
    int limit = 20,
    int offset = 0,
    int? feedId,
    bool? isUnread,
    bool? isStarred,
  }) {
    final query = select(feedItems);

    if (feedId != null && feedId > 0) {
      query.where((tbl) => tbl.feedId.equals(feedId));
    }

    if (isUnread != null) {
      query.where((tbl) => tbl.read.equals(!isUnread));
    }

    if (isStarred != null) {
      query.where((tbl) => tbl.starred.equals(isStarred));
    }

    query
      ..limit(limit, offset: offset)
      ..orderBy(
        [
          (u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc),
        ],
      );

    return query.get();
  }

  Future<List<FeedItem>> findItemsOfFeed(
    int feedId, {
    int limit = 20,
    int offset = 0,
    bool? isUnread,
    bool? isStarred,
  }) {
    return findItems(
      limit: limit,
      offset: offset,
      feedId: feedId,
      isUnread: isUnread,
      isStarred: isStarred,
    );
  }

  Future<List<FeedItem>> findUnreadItems({
    int limit = 20,
    int offset = 0,
    bool? isStarred,
  }) {
    return findItems(
      limit: limit,
      offset: offset,
      isUnread: false,
      isStarred: isStarred,
    );
  }

  Future<List<FeedItem>> findStarredItems({
    int limit = 20,
    int offset = 0,
    bool? isUnread,
  }) {
    return findItems(
      limit: limit,
      offset: offset,
      isUnread: isUnread,
      isStarred: true,
    );
  }

  Future<void> insert(FeedItemsCompanion entry) async {
    await into(feedItems).insert(entry);
  }

  Future<void> insertAll(List<FeedItemsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(feedItems, entries, mode: InsertMode.replace);
    });
  }

  Future<void> setRead(int id) async {
    await (update(feedItems)..where((tbl) => tbl.id.equals(id))).write(
      const FeedItemsCompanion(
        read: Value<bool>(true),
      ),
    );
  }

  Future<void> setUnread(int id) async {
    await (update(feedItems)..where((tbl) => tbl.id.equals(id))).write(
      const FeedItemsCompanion(
        read: Value<bool>(false),
      ),
    );
  }

  Future<void> setStarred(int id) async {
    await (update(feedItems)..where((tbl) => tbl.id.equals(id))).write(
      const FeedItemsCompanion(
        starred: Value<bool>(true),
      ),
    );
  }

  Future<void> setUnstarred(int id) async {
    await (update(feedItems)..where((tbl) => tbl.id.equals(id))).write(
      const FeedItemsCompanion(
        starred: Value<bool>(false),
      ),
    );
  }

  Future<int> itemCount() async {
    return customSelect(
      "SELECT COUNT(*) AS c FROM feed_items",
      readsFrom: {feedItems},
    ).map((p0) => p0.read<int>('c')).getSingle();
  }

  Future<int> unreadItemCount() async {
    return customSelect(
      "SELECT COUNT(*) AS c FROM feed_items WHERE read = 0",
      readsFrom: {feedItems},
    ).map((p0) => p0.read<int>('c')).getSingle();
  }

  Future<int> itemCountOfFeed(int feedId) async {
    return customSelect(
      "SELECT COUNT(*) AS c FROM feed_items WHERE feed_id = $feedId",
      readsFrom: {feedItems},
    ).map((p0) => p0.read<int>('c')).getSingle();
  }

  Future<int> unreadItemCountOfFeed(int feedId) async {
    return customSelect(
      "SELECT COUNT(*) AS c FROM feed_items WHERE feed_id = $feedId AND read = 0",
      readsFrom: {feedItems},
    ).map((p0) => p0.read<int>('c')).getSingle();
  }

  Future<int> starredItemCount() async {
    return customSelect(
      "SELECT COUNT(*) AS c FROM feed_items WHERE starred = 1",
      readsFrom: {feedItems},
    ).map((p0) => p0.read<int>('c')).getSingle();
  }

  Future<int> unreadStarredItemCount() async {
    return customSelect(
      "SELECT COUNT(*) AS c FROM feed_items WHERE starred = 1 AND read = 0",
      readsFrom: {feedItems},
    ).map((p0) => p0.read<int>('c')).getSingle();
  }

  Future<List<FeedItem>> search(
    String keyword, {
    int limit = 20,
    int offset = 0,
    int? feedId,
    bool? isUnread,
    bool? isStarred,
  }) {
    final query = select(feedItems);

    if (feedId != null && feedId > 0) {
      query.where(
          (tbl) => tbl.feedId.equals(feedId) & tbl.content.like("%$keyword%"));
    } else {
      query.where((tbl) => tbl.content.like("%$keyword%"));
    }

    if (isUnread != null) {
      query.where((tbl) => tbl.read.equals(!isUnread));
    }

    if (isStarred != null) {
      query.where((tbl) => tbl.starred.equals(isStarred));
    }

    query
      ..limit(limit, offset: offset)
      ..orderBy(
        [
          (u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc),
        ],
      );

    return query.get();
  }

  Future<int> removeItemsOfFeed(int feedId) {
    return (delete(feedItems)..where((t) => t.feedId.equals(feedId))).go();
  }
}
