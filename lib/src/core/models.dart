import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';
import 'package:mobx/mobx.dart';
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';

import 'sqlite.dart' as sqlite;

part 'models.g.dart';

_parsePubDate(String pubDate) {
  return DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US").parse(pubDate);
}

class FeedItem = FeedItemBase with _$FeedItem;

abstract class FeedItemBase with Store {
  final sqlite.ThunderBirdRSSDataBase storage;

  int id;
  String author;
  String title;
  String description;
  String link;
  String guid;
  String content;
  DateTime publishedAt;
  bool read = false;
  bool starred = false;

  FeedItemBase(
    this.storage, {
    required this.id,
    required this.link,
    this.author = "",
    this.title = "",
    this.description = "",
    this.guid = "",
    this.content = "",
    this.read = false,
    this.starred = false,
    DateTime? publishedAt,
  }) : publishedAt = publishedAt ?? DateTime.now();
}

class Feed = FeedBase with _$Feed;

abstract class FeedBase with Store {
  final sqlite.ThunderBirdRSSDataBase storage;

  int id;
  String url;
  String title;
  String description;
  String link;
  String icon;

  final int _limit = 200;
  int _offset = 0;

  FeedBase(
    this.storage, {
    required this.id,
    required this.url,
    this.title = "",
    this.description = "",
    this.link = "",
    this.icon = "",
  });

  ObservableList<FeedItem> items = ObservableList<FeedItem>();

  @action
  clear() {
    items.clear();
  }

  @action
  load() async {
    final items = (await storage.feedItemsDao.findItemsOfFeed(
      id,
      limit: _limit,
      offset: _offset,
    ))
        .map(
      (e) => FeedItem(
        storage,
        id: e.id,
        author: e.author,
        title: e.title,
        description: e.description,
        link: e.link,
        guid: e.guid,
        content: e.content,
        read: e.read,
        starred: e.starred,
        publishedAt: e.publishedAt,
      ),
    );

    _offset += _limit;

    this.items.addAll(items);
  }
}

class App = AppBase with _$App;

abstract class AppBase with Store {
  final sqlite.ThunderBirdRSSDataBase storage;

  @observable
  Feed? selectedFeed;

  @observable
  FeedItem? selectedFeedItem;

  ObservableList<Feed> feeds = ObservableList<Feed>();

  AppBase(this.storage);

  @action
  Future<void> subscribe(String feedUrl) async {
    final response = await http.get(Uri.parse(feedUrl));
    final xml = response.body;
    final doc = XmlDocument.parse(xml);
    final isRss = doc.findAllElements('rss').isNotEmpty;
    final isAtom = doc.findAllElements('feed').isNotEmpty;

    if (isRss) {
      final channel = RssFeed.parse(xml);

      final feedId = await storage.feedsDao.insert(
        sqlite.FeedsCompanion.insert(
          title: channel.title ?? "",
          description: channel.description ?? "",
          link: channel.link ?? "",
          url: feedUrl,
          icon: channel.image != null ? channel.image!.url ?? "" : "",
        ),
      );

      final feed = Feed(
        storage,
        id: feedId,
        url: feedUrl,
        title: channel.title ?? "",
        description: channel.description ?? "",
        link: channel.link ?? "",
        icon: channel.image != null ? channel.image!.url ?? "" : "",
      );

      await storage.feedItemsDao.insertItems(
        channel.items.map(
          (e) {
            var content = e.content;
            var pubDate = e.pubDate;

            return sqlite.FeedItemsCompanion.insert(
              feedId: feedId,
              title: e.title ?? "",
              author: e.author ?? "",
              description: e.description ?? "",
              content: content != null ? content.value : "",
              link: e.link ?? "",
              guid: e.guid ?? "",
              publishedAt:
                  pubDate != null ? _parsePubDate(pubDate) : DateTime.now(),
            );
          },
        ).toList(),
      );

      feeds.add(feed);
    }

    if (isAtom) {
      final channel = AtomFeed.parse(xml);

      final feedId = await storage.feedsDao.insert(
        sqlite.FeedsCompanion.insert(
          title: channel.title ?? "",
          description: channel.subtitle ?? "",
          link: channel.links.isNotEmpty ? channel.links.first.href ?? "" : "",
          url: feedUrl,
          icon: channel.icon ?? "",
        ),
      );

      final feed = Feed(
        storage,
        id: feedId,
        title: channel.title ?? "",
        description: channel.subtitle ?? "",
        link: channel.links.isNotEmpty ? channel.links.first.href ?? "" : "",
        url: feedUrl,
        icon: channel.icon ?? "",
      );

      feed.items.addAll(
        channel.items.map(
          (e) {
            var content = e.content;
            var pubDate = e.published;

            return FeedItem(
              storage,
              id: 0,
              author: e.authors.isNotEmpty
                  ? e.authors.map((e) => e.name).join(",")
                  : "",
              title: e.title ?? "",
              description: "",
              content: content ?? "",
              link: e.links.isNotEmpty ? e.links.first.href ?? "" : "",
              guid: e.id ?? "",
              publishedAt:
                  pubDate != null ? DateTime.parse(pubDate) : DateTime.now(),
            );
          },
        ),
      );

      await storage.feedItemsDao.insertItems(
        channel.items.map(
          (e) {
            var content = e.content;
            var pubDate = e.published;

            return sqlite.FeedItemsCompanion.insert(
              feedId: feedId,
              author: e.authors.isNotEmpty
                  ? e.authors.map((e) => e.name).join(",")
                  : "",
              title: e.title ?? "",
              description: "",
              content: content ?? "",
              link: e.links.isNotEmpty ? e.links.first.href ?? "" : "",
              guid: e.id ?? "",
              publishedAt:
                  pubDate != null ? DateTime.parse(pubDate) : DateTime.now(),
            );
          },
        ).toList(),
      );

      feeds.add(feed);
    }
  }

  @action
  Future<void> init() async {
    feeds.addAll(
      (await storage.feedsDao.all).map(
        (e) => Feed(
          storage,
          id: e.id,
          url: e.url,
          title: e.title,
          description: e.description,
          link: e.link,
          icon: e.icon,
        ),
      ),
    );
    if (feeds.isNotEmpty) {
      selectedFeed = feeds.first;
    }
  }

  @action
  void checkout(Feed feed) {
    feed.load();
    selectedFeed = feed;
  }

  @action
  void read(FeedItem item) {
    selectedFeedItem = item;
  }

}
