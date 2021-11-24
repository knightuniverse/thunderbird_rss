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

class FeedItem = _FeedItemBase with _$FeedItem;

abstract class _FeedItemBase with Store {
  final sqlite.ThunderBirdRSSDataBase storage;

  int id;
  final String author;
  final String title;
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
    this.author = "",
    this.title = "",
    this.description = "",
    this.guid = "",
    this.content = "",
    this.read = false,
    this.starred = false,
    DateTime? publishedAt,
  }) : publishedAt = publishedAt ?? DateTime.now();

  @action
  Future<void> setRead() async {
    read = true;
  }

  @action
  Future<void> setUnread() async {
    read = false;
  }

  @action
  Future<void> setStarred() async {
    starred = true;
  }

  @action
  Future<void> setUnstarred() async {
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
  ObservableList<FeedItem> items = ObservableList<FeedItem>.of([]);

  final int _limit = 200;
  int _offset = 0;

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

  @action
  collectStatistics() async {
    itemCount = await storage.feedItemsDao.itemCount(id);
    unreadItemCount = await storage.feedItemsDao.unreadItemCount(id);

    print(itemCount);
    print(unreadItemCount);
  }
}

class App = _AppBase with _$App;

abstract class _AppBase with Store {
  final sqlite.ThunderBirdRSSDataBase storage;

  @observable
  Feed? selectedFeed;

  @observable
  FeedItem? selectedFeedItem;

  @observable
  ObservableList<Feed> feeds = ObservableList<Feed>.of([]);

  _AppBase(this.storage);

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
            author: author ?? (source != null ? source.value : ""),
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

    await Future.wait(feeds.map((element) => element.collectStatistics()));

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
