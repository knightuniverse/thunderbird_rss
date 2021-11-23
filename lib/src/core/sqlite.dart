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
    return (select(feeds)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insert(FeedsCompanion entry) {
    return into(feeds).insert(entry);
  }
}

@DriftAccessor(tables: [FeedItems])
class FeedItemsDao extends DatabaseAccessor<ThunderBirdRSSDataBase>
    with _$FeedItemsDaoMixin {
  FeedItemsDao(ThunderBirdRSSDataBase db) : super(db);

  Future<List<FeedItem>> findItemsOfFeed(
    int feedId, {
    int limit = 20,
    int offset = 0,
  }) {
    return (select(feedItems)
          ..where((tbl) => tbl.feedId.equals(feedId))
          ..limit(limit, offset: offset))
        .get();
  }

  Future<void> insert(FeedItemsCompanion entry) async {
    await into(feedItems).insert(entry);
  }

  Future<void> insertAll(List<FeedItemsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(feedItems, entries);
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

  Future<int> itemCount(int feedId) async {
    return customSelect(
      "SELECT COUNT(*) AS c FROM feed_items WHERE feed_id = $feedId",
      readsFrom: {feedItems},
    ).map((p0) => p0.read<int>('c')).getSingle();
  }

  Future<int> unreadItemCount(int feedId) async {
    return customSelect(
      "SELECT COUNT(*) AS c FROM feed_items WHERE feed_id = $feedId AND read = 0",
      readsFrom: {feedItems},
    ).map((p0) => p0.read<int>('c')).getSingle();
  }
}
