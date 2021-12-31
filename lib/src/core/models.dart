import 'dart:developer' as developer;

import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';
import 'package:mobx/mobx.dart';
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';

import 'sqlite.dart' as sqlite;

part 'models.g.dart';

DateTime _parsePubDate(String pubDate) {
  return DateFormat("EEE, dd MMM yyyy HH:mm:ss Z").parse(pubDate);
}

List<sqlite.FeedItemsCompanion> _atomItemsToInserts(
  int feedId,
  List<AtomItem> items,
) {
  var inserts = <sqlite.FeedItemsCompanion>[];
  for (var item in items) {
    try {
      var content = item.content;
      var pubDate = item.published;
      var authors = item.authors;
      var source = item.source;
      var publishedAt =
          pubDate != null ? DateTime.parse(pubDate) : DateTime.now();

      inserts.add(
        sqlite.FeedItemsCompanion.insert(
          feedId: feedId,
          title: item.title ?? "",
          author:
              authors.isNotEmpty ? authors.map((e) => e.name).join(",") : "",
          source: source != null ? source.title ?? "" : "",
          description: "",
          content: content ?? "",
          link: item.links.isNotEmpty ? item.links.first.href ?? "" : "",
          guid: item.id ?? "",
          publishedAt: publishedAt,
        ),
      );
    } catch (e) {
      developer.log(e.toString());
      continue;
    }
  }
  return inserts;
}

List<sqlite.FeedItemsCompanion> _rssItemsToInserts(
  int feedId,
  List<RssItem> items,
) {
  var inserts = <sqlite.FeedItemsCompanion>[];
  for (var item in items) {
    try {
      var author = item.author;
      var content = item.content;
      var source = item.source;
      var description = item.description;
      var pubDate = item.pubDate;

      inserts.add(
        sqlite.FeedItemsCompanion.insert(
          feedId: feedId,
          title: item.title ?? "",
          author: author ?? "",
          source: source != null ? source.value : "",
          description: description ?? "",
          content: content != null ? content.value : description ?? "",
          link: item.link ?? "",
          guid: item.guid ?? "",
          publishedAt:
              pubDate != null ? _parsePubDate(pubDate) : DateTime.now(),
        ),
      );
    } catch (e) {
      developer.log(e.toString());
      continue;
    }
  }
  return inserts;
}

_mapSQLiteFeedItem(
  sqlite.FeedItem e, {
  required sqlite.ThunderBirdRSSDataBase storage,
}) {
  return FeedItem(
    storage,
    id: e.id,
    title: e.title,
    author: e.author,
    source: e.source,
    description: e.description,
    link: e.link,
    guid: e.guid,
    content: e.content,
    read: e.read,
    starred: e.starred,
    publishedAt: e.publishedAt,
  );
}

class FeedItem = _FeedItemBase with _$FeedItem;

abstract class _FeedItemBase with Store {
  final sqlite.ThunderBirdRSSDataBase storage;

  int id;
  final String title;
  final String author;
  final String source;
  final String description;
  final String link;
  final String guid;
  final String content;
  final DateTime publishedAt;

  @observable
  bool read = false;

  @observable
  bool starred = false;

  _FeedItemBase(
    this.storage, {
    required this.id,
    required this.link,
    this.title = "",
    this.author = "",
    this.source = "",
    this.description = "",
    this.guid = "",
    this.content = "",
    this.read = false,
    this.starred = false,
    DateTime? publishedAt,
  }) : publishedAt = publishedAt ?? DateTime.now();

  @action
  Future<void> setRead() async {
    storage.feedItemsDao.setRead(id);
    read = true;
  }

  @action
  Future<void> setUnread() async {
    storage.feedItemsDao.setUnread(id);
    read = false;
  }

  @action
  Future<void> setStarred() async {
    storage.feedItemsDao.setStarred(id);
    starred = true;
  }

  @action
  Future<void> setUnstarred() async {
    storage.feedItemsDao.setUnstarred(id);
    starred = false;
  }
}

class Feed = _FeedBase with _$Feed;

abstract class _FeedBase with Store {
  final sqlite.ThunderBirdRSSDataBase storage;

  int id;
  String url;
  String title;
  String description;
  String link;
  String icon;

  @observable
  int itemCount = 0;

  @observable
  int unreadItemCount = 0;

  @observable
  String keyword = "";

  @observable
  bool onlyUnreadItems = false;

  @observable
  bool onlyStarredItems = false;

  @observable
  ObservableList<FeedItem> items = ObservableList<FeedItem>.of([]);

  final int _limit = 200;
  int _next = 0;
  int _prev = 0;

  _FeedBase(
    this.storage, {
    required this.id,
    required this.url,
    this.title = "",
    this.description = "",
    this.link = "",
    this.icon = "",
  });

  @action
  Future<void> _parseAtom(String xml) async {
    final channel = AtomFeed.parse(xml);
    final feedId = id;
    final inserts = _atomItemsToInserts(feedId, channel.items);
    unreadItemCount += inserts.length;

    await storage.feedItemsDao.insertAll(inserts);
    await load();
  }

  @action
  Future<void> _parseRSS(String xml) async {
    final channel = RssFeed.parse(xml);
    final feedId = id;
    final inserts = _rssItemsToInserts(feedId, channel.items);
    unreadItemCount += inserts.length;

    await storage.feedItemsDao.insertAll(inserts);
    await load();
  }

  @action
  Future<void> update() async {
    if (id == 0) {
      return Future.value();
    }

    final response = await http.get(Uri.parse(url));
    final xml = response.body;
    final doc = XmlDocument.parse(xml);
    final isRSS = doc.findAllElements('rss').isNotEmpty;
    final isAtom = doc.findAllElements('feed').isNotEmpty;

    if (isAtom) {
      await _parseAtom(xml);
    }

    if (isRSS) {
      await _parseRSS(xml);
    }
  }

  @action
  void reset() {
    _next = 0;
    _prev = 0;
    keyword = "";
    items.clear();
  }

  @action
  collectStatistics() async {
    if (id == 0) {
      itemCount = await storage.feedItemsDao.itemCount();
      unreadItemCount = await storage.feedItemsDao.unreadItemCount();
      return;
    }

    itemCount = await storage.feedItemsDao.itemCountOfFeed(id);
    unreadItemCount = await storage.feedItemsDao.unreadItemCountOfFeed(id);
  }

  @action
  decreaseUnreadItemCount() {
    unreadItemCount -= 1;
  }

  @action
  _load() async {
    if (keyword.isEmpty) {
      var rows = await storage.feedItemsDao.findItems(
        feedId: id > 0 ? id : null,
        limit: _limit,
        offset: _next,
        isUnread: onlyUnreadItems == true ? true : null,
        isStarred: onlyStarredItems == true ? true : null,
      );
      items.addAll(rows.map((e) => _mapSQLiteFeedItem(e, storage: storage)));
      return;
    }

    var rows = await storage.feedItemsDao.search(
      keyword,
      feedId: id > 0 ? id : null,
      limit: _limit,
      offset: _next,
      isUnread: onlyUnreadItems == true ? true : null,
      isStarred: onlyStarredItems == true ? true : null,
    );
    items.addAll(rows.map((e) => _mapSQLiteFeedItem(e, storage: storage)));
  }

  @action
  load() async {
    await _load();
    _prev = _next;
    _next += _limit;
  }

  @action
  reload() async {
    _next = _prev;
    items.clear();
    await _load();
  }

  @action
  Future<void> search(String next) async {
    keyword = next;
    _next = 0;
    items.clear();
    await _load();
  }
}

class App = _AppBase with _$App;

abstract class _AppBase with Store {
  final sqlite.ThunderBirdRSSDataBase storage;

  @observable
  Feed all;

  @observable
  Feed? selectedFeed;

  @observable
  FeedItem? selectedFeedItem;

  @observable
  ObservableList<Feed> feeds = ObservableList<Feed>.of([]);

  final _feedMap = <int, Feed>{};

  _AppBase(this.storage)
      : all = Feed(
          storage,
          id: 0,
          url: "All Messages",
          title: "All Messages",
          description: "All Messages",
        ) {
    selectedFeed = all;
  }

  @action
  Future<void> _subscribeAtom(String feedUrl, String xml) async {
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

    await storage.feedItemsDao.insertAll(
      _atomItemsToInserts(feedId, channel.items),
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

    await feed.collectStatistics();

    feeds.add(feed);

    checkout(feed);
  }

  @action
  Future<void> _subscribeRSS(String feedUrl, String xml) async {
    final channel = RssFeed.parse(xml);

    String favIcon = "";
    final source = channel.link;
    if (source != null) {
      favIcon = await _fetchFavIcon(source);
    }

    final feedId = await storage.feedsDao.insert(
      sqlite.FeedsCompanion.insert(
        title: channel.title ?? "",
        description: channel.description ?? "",
        link: channel.link ?? "",
        url: feedUrl,
        icon: favIcon,
      ),
    );

    await storage.feedItemsDao.insertAll(
      _rssItemsToInserts(feedId, channel.items),
    );

    final feed = Feed(
      storage,
      id: feedId,
      title: channel.title ?? "",
      description: channel.description ?? "",
      link: channel.link ?? "",
      url: feedUrl,
      icon: favIcon,
    );

    await feed.collectStatistics();

    feeds.add(feed);

    checkout(feed);
  }

  @action
  Future<void> subscribe(String feedUrl) async {
    final response = await http.get(Uri.parse(feedUrl));
    final xml = response.body;
    final doc = XmlDocument.parse(xml);
    final isRss = doc.findAllElements('rss').isNotEmpty;
    final isAtom = doc.findAllElements('feed').isNotEmpty;

    if (isAtom) {
      return _subscribeAtom(feedUrl, xml);
    }

    if (isRss) {
      return _subscribeRSS(feedUrl, xml);
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

    await all.collectStatistics();
    await Future.wait(feeds.map((element) => element.collectStatistics()));

    for (var item in feeds) {
      _feedMap[item.id] = item;
    }

    final feed = selectedFeed;
    if (feed != null) {
      await feed.load();
    }
  }

  @action
  Future<void> checkout(Feed feed) {
    if (selectedFeed != feed) {
      selectedFeed?.reset();
      selectedFeed = feed;
      return feed.load();
    }

    return Future.value();
  }

  @action
  Future<void> udpateAllFeeds() {
    return Future.wait(feeds.map((element) => element.update()));
  }

  @action
  Future<void> read(FeedItem item) {
    if (selectedFeedItem != item) {
      selectedFeedItem = item;
      return item.setRead();
    }

    return Future.value();
  }

  Feed? findFeed(int id) {
    return _feedMap[id];
  }

  Future<String> _fetchFavIcon(String source) async {
    String favIcon = "";

    final html = await http.get(Uri.parse(source));
    final dom.Document document = htmlparser.parse(html.body);
    final head = document.getElementsByTagName("head").first;
    head.getElementsByTagName("link").forEach((element) {
      RegExp iconPattern = RegExp(
        r"(\.jpg|\.png|\.ico)$",
        caseSensitive: false,
      );

      for (var value in element.attributes.values) {
        if (iconPattern.hasMatch(value)) {
          favIcon = value;
        }
      }
    });

    if (favIcon.startsWith("https:") || favIcon.startsWith("http:")) {
      return favIcon;
    }

    if (favIcon.startsWith("//")) {
      favIcon = Uri.parse(source).scheme + ":" + favIcon;
      return favIcon;
    }

    favIcon = Uri.parse(source).origin +
        (favIcon.startsWith("/") ? "/$favIcon" : favIcon);
    return favIcon;
  }
}
