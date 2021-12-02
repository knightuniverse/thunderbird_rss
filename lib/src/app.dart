import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;
import 'package:get_it/get_it.dart';

import 'core/models.dart' as model;

class _FeedLogo extends StatelessWidget {
  final model.Feed feed;

  const _FeedLogo(this.feed);

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);

    return feed.icon.isNotEmpty
        ? SizedBox(
            child: Image.network(
              feed.icon,
              fit: BoxFit.fill,
            ),
            height: iconTheme.size,
            width: iconTheme.size,
          )
        : const Icon(Icons.rss_feed);
  }
}

class _Feed extends StatefulWidget {
  final model.Feed feed;

  const _Feed(this.feed, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FeedState();
  }
}

class _FeedState extends State<_Feed> {
  final GlobalKey _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final feed = widget.feed;

    return Column(
      children: [
        AppBar(
          actions: [
            Observer(
              builder: (_) => PopupMenuButton<model.FeedItemFilter>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<model.FeedItemFilter>(
                    value: model.FeedItemFilter.starred,
                    child: ListTile(
                      enabled: !feed.isStarredItemsAggregation,
                      leading: const Icon(Icons.star_border_outlined),
                      selected: feed.filter == model.FeedItemFilter.starred,
                      title: const Text('Only starred items'),
                    ),
                  ),
                  PopupMenuItem<model.FeedItemFilter>(
                    value: model.FeedItemFilter.unread,
                    child: ListTile(
                      enabled: !feed.isUnreadItemsAggregation,
                      leading: const Icon(Icons.circle_outlined),
                      selected: feed.filter == model.FeedItemFilter.unread,
                      title: const Text('Only unread items'),
                    ),
                  ),
                  PopupMenuItem<model.FeedItemFilter>(
                    value: model.FeedItemFilter.all,
                    child: ListTile(
                      leading: const Icon(Icons.message_outlined),
                      selected: feed.filter == model.FeedItemFilter.all,
                      title: const Text('All items'),
                    ),
                  ),
                ],
                onSelected: (model.FeedItemFilter result) {
                  feed.setItemFilter(result);
                },
              ),
            ),
          ],
          elevation: 0,
          title: Text(
            feed.title,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  autofocus: false,
                  decoration: const InputDecoration(
                    hintText: "Keyword",
                    suffixIcon: Icon(Icons.search),
                  ),
                  initialValue: "",
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (value) {
                    feed.search(value);
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Observer(
            builder: (_) => ListView.builder(
              itemCount: feed.items.length,
              itemBuilder: (BuildContext context, int i) {
                final item = feed.items[i];
                return _FeedItem(
                  feed: feed,
                  item: item,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedItem extends StatelessWidget {
  final model.Feed feed;
  final model.FeedItem item;

  const _FeedItem({
    required this.feed,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final app = GetIt.I.get<model.App>();

    final dom.Document document = htmlparser.parse("""
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="referrer" content="no-referrer">
    <meta http-equiv="Content-Security-Policy"
        content="default-src 'none'; script-src 'self'; img-src http: https: data:; style-src 'self' 'unsafe-inline'; frame-src http: https:; media-src http: https:; connect-src https: http:">
    <title>${item.title}</title>
</head>
<body>${item.content}</body>
</html>
    """);
    final images = document.getElementsByTagName("img");

    return Observer(
      builder: (context) {
        final theme = Theme.of(context);

        return ListTile(
          leading: _FeedLogo(feed),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    feed.title,
                    style: item.read
                        ? theme.textTheme.overline
                            ?.copyWith(color: Colors.black54)
                        : theme.textTheme.overline,
                  ),
                  item.starred
                      ? Row(
                          children: [
                            //  TODO 星标
                            Icon(
                              Icons.star,
                              size: 10,
                              color: item.read ? Colors.black54 : Colors.black,
                            ),
                            const SizedBox(width: 8),
                            //  TODO 更新时间
                            Text(
                              "12:00",
                              style: item.read
                                  ? theme.textTheme.overline
                                      ?.copyWith(color: Colors.black54)
                                  : theme.textTheme.overline,
                            ),
                          ],
                        )
                      : Text(
                          "12:00",
                          style: item.read
                              ? theme.textTheme.overline
                                  ?.copyWith(color: Colors.black54)
                              : theme.textTheme.overline,
                        ),
                ],
              ),
              images.isEmpty
                  ? Text(
                      item.title,
                      style: item.read
                          ? theme.textTheme.subtitle2
                              ?.copyWith(color: Colors.black54)
                          : theme.textTheme.subtitle2,
                      softWrap: true,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            softWrap: true,
                            style: item.read
                                ? theme.textTheme.subtitle2
                                    ?.copyWith(color: Colors.black54)
                                : theme.textTheme.subtitle2,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                          width: 80,
                          child: Image.network(images.first.attributes["src"]!),
                        ),
                      ],
                    ),
            ],
          ),
          onTap: () {
            app.read(item);
          },
        );
      },
    );
  }
}

class _FeedItemContent extends StatelessWidget {
  final model.FeedItem item;

  const _FeedItemContent(this.item);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyText2 = Style(
      color: theme.textTheme.bodyText2?.color,
      fontSize: FontSize(
        theme.textTheme.bodyText2?.fontSize,
      ),
      fontWeight: theme.textTheme.bodyText2?.fontWeight,
      letterSpacing: theme.textTheme.bodyText2?.letterSpacing,
    );
    final caption = Style(
      color: theme.textTheme.caption?.color,
      fontSize: FontSize(
        theme.textTheme.caption?.fontSize,
      ),
      fontWeight: theme.textTheme.caption?.fontWeight,
      letterSpacing: theme.textTheme.caption?.letterSpacing,
    );
    final headline5 = Style(
      color: theme.textTheme.headline5?.color,
      fontSize: FontSize(
        theme.textTheme.headline5?.fontSize,
      ),
      fontWeight: theme.textTheme.headline5?.fontWeight,
      letterSpacing: theme.textTheme.headline5?.letterSpacing,
    );
    final headline6 = Style(
      color: theme.textTheme.headline6?.color,
      fontSize: FontSize(
        theme.textTheme.headline6?.fontSize,
      ),
      fontWeight: theme.textTheme.headline6?.fontWeight,
      letterSpacing: theme.textTheme.headline6?.letterSpacing,
    );

    final isDesktopPlatform =
        Platform.isMacOS || Platform.isLinux || Platform.isWindows;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppBar(
            elevation: 0,
            title: const Text(""),
            actions: [
              Observer(
                builder: (_) {
                  return IconButton(
                    icon: Icon(
                      item.read ? Icons.circle_outlined : Icons.circle,
                    ),
                    onPressed: () {
                      if (item.read) {
                        item.setUnread();
                      } else {
                        item.setRead();
                      }
                    },
                  );
                },
              ),
              Observer(
                builder: (_) {
                  return IconButton(
                    icon: Icon(
                      item.starred ? Icons.star : Icons.star_border_outlined,
                    ),
                    onPressed: () {
                      if (item.starred) {
                        item.setUnstarred();
                      } else {
                        item.setStarred();
                      }
                    },
                  );
                },
              ),
            ],
          ),
          Expanded(
            // child: Align(
            //   alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 52, right: 48, left: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 800,
                  ),
                  //  TODO Windows MacOS Linux平台上，不支持iframe渲染，需要设置一个placeholder
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //  TODO 更新时间
                      Text(
                        "12:00",
                        style: theme.textTheme.headline5
                            ?.copyWith(color: Colors.black54),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        item.title,
                        style: theme.textTheme.headline4
                            ?.copyWith(color: Colors.black87),
                      ),

                      const SizedBox(height: 8),

                      item.author.isNotEmpty
                          ? Text(
                              item.author,
                              style: theme.textTheme.headline5
                                  ?.copyWith(color: Colors.black54),
                            )
                          : Container(),

                      item.author.isNotEmpty
                          ? const SizedBox(height: 8)
                          : Container(),

                      item.source.isNotEmpty
                          ? Text(
                              item.source,
                              style: theme.textTheme.headline5
                                  ?.copyWith(color: Colors.black54),
                            )
                          : Container(),

                      item.source.isNotEmpty
                          ? const SizedBox(height: 8)
                          : Container(),

                      // TODO 我们有必要编写一套类似  https://github.com/postlight/mercury-parser 的工具了
                      Html(
                        customRender: isDesktopPlatform
                            ? {
                                "iframe":
                                    (RenderContext context, Widget child) {
                                  var width =
                                      MediaQuery.of(context.buildContext)
                                          .size
                                          .width;
                                  var height = width * 9 / 16;

                                  return Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFBFCFF),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(32),
                                      ),
                                    ),
                                    constraints: const BoxConstraints(
                                      maxWidth: 600,
                                      minWidth: 200,
                                      maxHeight: 450,
                                      minHeight: 200,
                                    ),
                                    height: height,
                                    width: width,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset("assets/images/empty.png"),
                                        Text(
                                          "Your OS does not support iframes.",
                                          style: theme.textTheme.caption,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              }
                            : {},
                        data: item.content,
                        shrinkWrap: true,
                        style: {
                          //   TODO "a": Style(),
                          "div": bodyText2,
                          "figcaption": caption,
                          "h1": headline5,
                          "h2": headline6,
                          "h3": headline6,
                          "h4": headline6,
                          "h5": headline6,
                          "h6": headline6,
                          "p": bodyText2,
                          "span": bodyText2,
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ),
          ),
        ],
      ),
    );
  }
}

class _SubscribeDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SubscribeDialogState();
  }
}

class _SubscribeDialogState extends State<_SubscribeDialog> {
  final TextEditingController _urlController = TextEditingController();

  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final app = GetIt.I.get<model.App>();

    return Dialog(
      child: Column(
        children: [
          TextField(
            autofocus: true,
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: "RSS",
              hintText: "RSS",
              prefixIcon: Icon(Icons.person),
            ),
          ),
          ElevatedButton(
            child: const Text("移动焦点"),
            onPressed: () async {
              if (_busy) {
                return;
              }

              setState(() {
                _busy = true;
              });

              await app.subscribe(_urlController.text);

              setState(() {
                _busy = false;
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class ThunderbirdRSSApp extends StatelessWidget {
  const ThunderbirdRSSApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final app = GetIt.I.get<model.App>();
    final feeds = app.feeds;

    return Scaffold(
      body: Row(
        children: [
          Container(
            child: Observer(
              builder: (ctx) {
                return Drawer(
                  child: ListView(
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: Theme.of(ctx).primaryColor,
                        ),
                        child: Text(
                          'ThunderBird RSS',
                          style: Theme.of(ctx)
                              .textTheme
                              .headline5!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.message),
                        title: const Text('Unread'),
                        trailing: Text("${app.unread.itemCount}"),
                        onTap: () {
                          app.checkout(app.unread);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.star),
                        title: const Text('Starred'),
                        trailing: Text("${app.unread.unreadItemCount}"),
                        onTap: () {
                          app.checkout(app.starred);
                        },
                      ),
                      const Divider(
                        thickness: 1,
                        height: 1,
                      ),
                      ...feeds
                          .map(
                            (feed) => ListTile(
                              leading: _FeedLogo(feed),
                              title: SizedBox(
                                width: 80,
                                child: Text(
                                  feed.title,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                              trailing: Text("${feed.unreadItemCount}"),
                              onTap: () {
                                app.checkout(feed);
                              },
                            ),
                          )
                          .toList()
                    ],
                  ),
                );
              },
            ),
            width: 250,
          ),
          Observer(
            builder: (_) {
              final feed = app.selectedFeed;
              return feed != null
                  ? Container(
                      child: _Feed(feed),
                      width: 360,
                    )
                  : Container(
                      width: 360,
                    );
            },
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
          ),
          Observer(
            builder: (_) {
              final item = app.selectedFeedItem;
              return item != null ? _FeedItemContent(item) : Container();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) {
              return _SubscribeDialog();
            },
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
