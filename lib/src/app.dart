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
          ) //ImageIcon(NetworkImage(feed.icon))
        : const Icon(Icons.rss_feed);
  }
}

class _Feed extends StatelessWidget {
  final model.Feed feed;

  const _Feed(this.feed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Column(
        children: [
          AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.star_border_outlined),
                tooltip: 'Only show starred items',
                onPressed: () {
                  //  TODO
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This is a snackbar'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.circle_outlined),
                tooltip: 'Only show starred items',
                onPressed: () {
                  //  TODO
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This is a snackbar'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.message_outlined),
                tooltip: 'Show all items',
                onPressed: () {
                  //  TODO
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This is a snackbar'),
                    ),
                  );
                },
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
              child: Column(
                children: [
                  TextFormField(
                    autofocus: false,
                    decoration: const InputDecoration(
                      hintText: "Keyword",
                      suffixIcon: Icon(Icons.search),
                    ),
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
      ),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    feed.title,
                    style: theme.textTheme.overline,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 10,
                      ),
                      const SizedBox(width: 8),
                      //  TODO 更新时间
                      Text(
                        "12:00",
                        style: theme.textTheme.overline,
                      ),
                    ],
                  ),
                ],
              ),
              images.isEmpty
                  ? Text(
                      item.title,
                      style: theme.textTheme.subtitle2,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            softWrap: true,
                            style: theme.textTheme.subtitle2,
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

    return Expanded(
      child: Align(
        alignment: Alignment.topCenter,
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
                    style: theme.textTheme.overline,
                  ),

                  Text(
                    item.title,
                    style: theme.textTheme.headline1,
                  ),

                  item.author.isNotEmpty
                      ? Text(
                          item.author,
                          style: theme.textTheme.overline,
                        )
                      : Container(),

                  item.source.isNotEmpty
                      ? Text(
                          item.source,
                          style: theme.textTheme.overline,
                        )
                      : Container(),

                  Html(
                    data: item.content,
                    shrinkWrap: true,
                    style: {
                      //   TODO "a": Style(),
                      "div": Style(
                        color: theme.textTheme.bodyText2?.color,
                        fontSize: FontSize(
                          theme.textTheme.bodyText2?.fontSize,
                        ),
                        fontWeight: theme.textTheme.bodyText2?.fontWeight,
                        letterSpacing: theme.textTheme.bodyText2?.letterSpacing,
                      ),
                      "figcaption": Style(
                        color: theme.textTheme.caption?.color,
                        fontSize: FontSize(
                          theme.textTheme.caption?.fontSize,
                        ),
                        fontWeight: theme.textTheme.caption?.fontWeight,
                        letterSpacing: theme.textTheme.caption?.letterSpacing,
                      ),
                      "h1": Style(
                        color: theme.textTheme.headline1?.color,
                        fontSize: FontSize(
                          theme.textTheme.headline1?.fontSize,
                        ),
                        fontWeight: theme.textTheme.headline1?.fontWeight,
                        letterSpacing: theme.textTheme.headline1?.letterSpacing,
                      ),
                      "h2": Style(
                        color: theme.textTheme.headline2?.color,
                        fontSize: FontSize(
                          theme.textTheme.headline2?.fontSize,
                        ),
                        fontWeight: theme.textTheme.headline2?.fontWeight,
                        letterSpacing: theme.textTheme.headline2?.letterSpacing,
                      ),
                      "h3": Style(
                        color: theme.textTheme.headline3?.color,
                        fontSize: FontSize(
                          theme.textTheme.headline3?.fontSize,
                        ),
                        fontWeight: theme.textTheme.headline3?.fontWeight,
                        letterSpacing: theme.textTheme.headline3?.letterSpacing,
                      ),
                      "h4": Style(
                        color: theme.textTheme.headline4?.color,
                        fontSize: FontSize(
                          theme.textTheme.headline4?.fontSize,
                        ),
                        fontWeight: theme.textTheme.headline4?.fontWeight,
                        letterSpacing: theme.textTheme.headline4?.letterSpacing,
                      ),
                      "h5": Style(
                        color: theme.textTheme.headline5?.color,
                        fontSize: FontSize(
                          theme.textTheme.headline5?.fontSize,
                        ),
                        fontWeight: theme.textTheme.headline5?.fontWeight,
                        letterSpacing: theme.textTheme.headline5?.letterSpacing,
                      ),
                      "h6": Style(
                        color: theme.textTheme.headline6?.color,
                        fontSize: FontSize(
                          theme.textTheme.headline6?.fontSize,
                        ),
                        fontWeight: theme.textTheme.headline6?.fontWeight,
                        letterSpacing: theme.textTheme.headline6?.letterSpacing,
                      ),
                      "p": Style(
                        color: theme.textTheme.bodyText2?.color,
                        fontSize: FontSize(
                          theme.textTheme.bodyText2?.fontSize,
                        ),
                        fontWeight: theme.textTheme.bodyText2?.fontWeight,
                        letterSpacing: theme.textTheme.bodyText2?.letterSpacing,
                      ),
                      "span": Style(
                        color: theme.textTheme.bodyText2?.color,
                        fontSize: FontSize(
                          theme.textTheme.bodyText2?.fontSize,
                        ),
                        fontWeight: theme.textTheme.bodyText2?.fontWeight,
                        letterSpacing: theme.textTheme.bodyText2?.letterSpacing,
                      ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          headline1: TextStyle(
            color: Colors.black,
            fontSize: 48,
            fontWeight: FontWeight.w500,
            letterSpacing: -1.5,
          ),
          headline2: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
          ),
          headline3: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w500,
          ),
          headline4: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
          headline5: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
          headline6: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
          subtitle1: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
          ),
          subtitle2: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          bodyText1: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.5,
          ),
          bodyText2: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            height: 1.5,
          ),
          button: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.25,
          ),
          caption: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
          ),
          overline: TextStyle(
            color: Color(0xFF666666),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
          ),
        ),
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

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
                      const ListTile(
                        leading: Icon(Icons.message),
                        title: Text('Messages'),
                      ),
                      const ListTile(
                        leading: Icon(Icons.star),
                        title: Text('Starred'),
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
