import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;
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

const _idUnreadMessagesFeed = -1;
const _idStarredMessagesFeed = -2;

enum FeedItemFilter {
  all,
  starred,
  unread,
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
  FeedItemFilter filter = FeedItemFilter.unread;

  @observable
  int itemCount = 0;

  @observable
  int unreadItemCount = 0;

  @observable
  ObservableList<FeedItem> items = ObservableList<FeedItem>.of([]);

  final int _limit = 200;

  int _offset = 0;

  get isUnreadItemsAggregation => id == _idUnreadMessagesFeed;

  get isStarredItemsAggregation => id == _idStarredMessagesFeed;

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

    await storage.feedItemsDao.insertAll(
      channel.items.map(
        (e) {
          var content = e.content;
          var pubDate = e.published;
          var authors = e.authors;
          var source = e.source;

          return sqlite.FeedItemsCompanion.insert(
            feedId: feedId,
            title: e.title ?? "",
            author:
                authors.isNotEmpty ? authors.map((e) => e.name).join(",") : "",
            source: source != null ? source.title ?? "" : "",
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

    await load();
  }

  @action
  Future<void> _parseRSS(String xml) async {
    final channel = RssFeed.parse(xml);
    final feedId = id;

    await storage.feedItemsDao.insertAll(
      channel.items.map(
        (e) {
          var author = e.author;
          var content = e.content;
          var source = e.source;
          var description = e.description;
          var pubDate = e.pubDate;

          return sqlite.FeedItemsCompanion.insert(
            feedId: feedId,
            title: e.title ?? "",
            author: author ?? "",
            source: source != null ? source.value : "",
            description: description ?? "",
            content: content != null ? content.value : description ?? "",
            link: e.link ?? "",
            guid: e.guid ?? "",
            publishedAt:
                pubDate != null ? _parsePubDate(pubDate) : DateTime.now(),
          );
        },
      ).toList(),
    );

    await load();
  }

  @action
  Future<void> fetch() async {
    if (id == _idUnreadMessagesFeed || id == _idStarredMessagesFeed) {
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
  clear() {
    items.clear();
  }

  @action
  collectStatistics() async {
    switch (id) {
      case _idUnreadMessagesFeed:
        itemCount = await storage.feedItemsDao.itemCount();
        unreadItemCount = await storage.feedItemsDao.unreadItemCount();

        break;
      case _idStarredMessagesFeed:
        itemCount = await storage.feedItemsDao.starredItemCount();
        unreadItemCount = await storage.feedItemsDao.unreadStarredItemCount();

        break;
      default:
        itemCount = await storage.feedItemsDao.itemCountOfFeed(id);
        unreadItemCount = await storage.feedItemsDao.unreadItemCountOfFeed(id);

        break;
    }
  }

  @action
  decreaseUnreadItemCount() {
    unreadItemCount -= 1;
  }

  @action
  load() async {
    switch (id) {
      case _idUnreadMessagesFeed:
        items.addAll((await storage.feedItemsDao.findUnreadItems(
          limit: _limit,
          offset: _offset,
          isStarred: filter == FeedItemFilter.starred ? true : null,
        ))
            .map((e) => _mapSQLiteFeedItem(e, storage: storage)));

        break;
      case _idStarredMessagesFeed:
        items.addAll((await storage.feedItemsDao.findStarredItems(
          limit: _limit,
          offset: _offset,
          isRead: filter == FeedItemFilter.all
              ? null
              : !(filter == FeedItemFilter.unread),
        ))
            .map((e) => _mapSQLiteFeedItem(e, storage: storage)));

        break;
      default:
        items.addAll((await storage.feedItemsDao.findItemsOfFeed(
          id,
          limit: _limit,
          offset: _offset,
          isRead: filter == FeedItemFilter.all
              ? null
              : !(filter == FeedItemFilter.unread),
          isStarred: filter == FeedItemFilter.starred ? true : null,
        ))
            .map((e) => _mapSQLiteFeedItem(e, storage: storage)));

        break;
    }

    _offset += _limit;
  }

  @action
  Future<void> setItemFilter(FeedItemFilter next) async {
    switch (id) {
      case _idUnreadMessagesFeed:
        if (next != FeedItemFilter.unread) {
          filter = next;
        }

        break;
      case _idStarredMessagesFeed:
        if (next != FeedItemFilter.starred) {
          filter = next;
        }

        break;
      default:
        filter = next;

        break;
    }

    _offset = 0;
    items.clear();

    switch (id) {
      case _idUnreadMessagesFeed:
        items.addAll((await storage.feedItemsDao.findUnreadItems(
          limit: _limit,
          offset: _offset,
          isStarred: filter == FeedItemFilter.starred ? true : null,
        ))
            .map((e) => _mapSQLiteFeedItem(e, storage: storage)));

        break;
      case _idStarredMessagesFeed:
        items.addAll((await storage.feedItemsDao.findStarredItems(
          limit: _limit,
          offset: _offset,
          isRead: filter == FeedItemFilter.all
              ? null
              : !(filter == FeedItemFilter.unread),
        ))
            .map((e) => _mapSQLiteFeedItem(e, storage: storage)));

        break;
      default:
        items.addAll((await storage.feedItemsDao.findItemsOfFeed(
          id,
          limit: _limit,
          offset: _offset,
          isRead: filter == FeedItemFilter.all
              ? null
              : !(filter == FeedItemFilter.unread),
          isStarred: filter == FeedItemFilter.starred ? true : null,
        ))
            .map((e) => _mapSQLiteFeedItem(e, storage: storage)));

        break;
    }
  }

  // @action
  // Future<void> search(String keyword) async {}
}

class App = _AppBase with _$App;

abstract class _AppBase with Store {
  final sqlite.ThunderBirdRSSDataBase storage;

  @observable
  Feed unread;

  @observable
  Feed starred;

  @observable
  Feed? selectedFeed;

  @observable
  FeedItem? selectedFeedItem;

  @observable
  ObservableList<Feed> feeds = ObservableList<Feed>.of([]);

  _AppBase(this.storage)
      : unread = Feed(
          storage,
          id: _idUnreadMessagesFeed,
          url: "Unread Messages",
          title: "Unread Messages",
          description: "Unread Messages",
        ),
        starred = Feed(
          storage,
          id: _idStarredMessagesFeed,
          url: "Starred Messages",
          title: "Starred Messages",
          description: "Starred Messages",
        ) {
    selectedFeed = unread;
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

    final feed = Feed(
      storage,
      id: feedId,
      title: channel.title ?? "",
      description: channel.subtitle ?? "",
      link: channel.links.isNotEmpty ? channel.links.first.href ?? "" : "",
      url: feedUrl,
      icon: channel.icon ?? "",
    );

    await storage.feedItemsDao.insertAll(
      channel.items.map(
        (e) {
          var content = e.content;
          var pubDate = e.published;
          var authors = e.authors;
          var source = e.source;

          return sqlite.FeedItemsCompanion.insert(
            feedId: feedId,
            title: e.title ?? "",
            author:
                authors.isNotEmpty ? authors.map((e) => e.name).join(",") : "",
            source: source != null ? source.title ?? "" : "",
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

    checkout(feed);
  }

  @action
  Future<void> _subscribeRSS(String feedUrl, String xml) async {
    final channel = RssFeed.parse(xml);

    String icon = "";
    final source = channel.link;
    if (source != null) {
      final html = await http.get(Uri.parse(source));
      final dom.Document document = htmlparser.parse(html.body);
      final head = document.getElementsByTagName("head").first;
      head.getElementsByTagName("link").forEach((element) {
        RegExp iconPattern = RegExp(
          r"(\.jpg|\.png|\.ico)$",
          caseSensitive: false,
        );
        element.attributes.values.forEach((value) {
          if (iconPattern.hasMatch(value)) {
            icon = value;
          }
        });
      });

      icon = icon.startsWith("https:") || icon.startsWith("http:")
          ? icon
          : icon.startsWith("//")
              ? Uri.parse(source).scheme + ":" + icon
              : Uri.parse(source + icon).toString();
    }

    final feedId = await storage.feedsDao.insert(
      sqlite.FeedsCompanion.insert(
        title: channel.title ?? "",
        description: channel.description ?? "",
        link: channel.link ?? "",
        url: feedUrl,
        icon: icon,
      ),
    );

    final feed = Feed(
      storage,
      id: feedId,
      title: channel.title ?? "",
      description: channel.description ?? "",
      link: channel.link ?? "",
      url: feedUrl,
      icon: icon,
    );

    await storage.feedItemsDao.insertAll(
      channel.items.map(
        (e) {
          var author = e.author;
          var content = e.content;
          var source = e.source;
          var description = e.description;
          var pubDate = e.pubDate;

          return sqlite.FeedItemsCompanion.insert(
            feedId: feedId,
            title: e.title ?? "",
            author: author ?? "",
            source: source != null ? source.value : "",
            description: description ?? "",
            content: content != null ? content.value : description ?? "",
            link: e.link ?? "",
            guid: e.guid ?? "",
            publishedAt:
                pubDate != null ? _parsePubDate(pubDate) : DateTime.now(),
          );
        },
      ).toList(),
    );

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

    if (isRss) {
      return _subscribeRSS(feedUrl, xml);
    }

    if (isAtom) {
      return _subscribeAtom(feedUrl, xml);
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

    await unread.collectStatistics();
    await starred.collectStatistics();
    await Future.wait(feeds.map((element) => element.collectStatistics()));

    final feed = selectedFeed;
    if (feed != null) {
      await feed.load();
    }
  }

  @action
  void checkout(Feed feed) {
    selectedFeed = feed;
    feed.load();
  }

  @action
  void read(FeedItem item) {
    selectedFeedItem = item;
    item.setRead();
  }
}
