import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'core/sqlite.dart';
import 'core/models.dart' as model;

class _FeedItems extends StatelessWidget {
  final model.Feed feed;

  _FeedItems(this.feed) {
    feed.load();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return ListView.separated(
          itemCount: feed.items.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(feed.items[index].title),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            Widget divider1 = const Divider(
              color: Colors.blue,
            );
            Widget divider2 = const Divider(
              color: Colors.green,
            );
            return index % 2 == 0 ? divider1 : divider2;
          },
        );
      },
    );
  }
}

class _Post extends StatelessWidget {
  final model.FeedItem item;

  _Post(this.item);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }

    return WebView(
      gestureNavigationEnabled: true,
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          print('blocking navigation to $request}');
          return NavigationDecision.prevent;
        }
        print('allowing navigation to $request');
        return NavigationDecision.navigate;
      },
      onWebViewCreated: (WebViewController webViewController) {
        var localUrl = "http://127.0.0.1:9000/post/index.html";
        var a = Uri.encodeComponent(item.content);
        localUrl += "?a=$a";
        webViewController.loadUrl(localUrl);
      },
      onProgress: (int progress) {
        print("WebView is loading (progress : $progress%)");
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url) {
        print('Page finished loading: $url');
      },
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final model.App app = model.App(
    GetIt.I.get<ThunderBirdRSSDataBase>(),
  );

  @override
  void initState() {
    super.initState();
    app.init();
    //  TODO remove
    app
        .subscribe("https://developer.apple.com/news/releases/rss/releases.rss")
        .then((_) => app.checkout(app.feeds.first));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          //  what if it's empty feeds
          Container(
            child: Observer(
              builder: (_) {
                return ListView.separated(
                  itemCount: app.feeds.length,
                  itemBuilder: (BuildContext context, int index) {
                    final feed = app.feeds[index];
                    return ListTile(
                      title: Text(feed.title),
                      onTap: () {
                        app.checkout(feed);
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    Widget divider1 = const Divider(
                      color: Colors.blue,
                    );
                    Widget divider2 = const Divider(
                      color: Colors.green,
                    );
                    return index % 2 == 0 ? divider1 : divider2;
                  },
                );
              },
            ),
            width: 240,
          ),

          Observer(
            builder: (_) {
              final feed = app.selectedFeed;
              return feed != null
                  ? Container(
                      child: ListView.separated(
                        itemCount: feed.items.length,
                        itemBuilder: (BuildContext context, int i) {
                          final item = feed.items[i];
                          return ListTile(
                            title: Text(item.title),
                            onTap: () {
                              app.read(item);
                            },
                          );
                        },
                        separatorBuilder: (BuildContext context, int i) {
                          Widget divider1 = const Divider(
                            color: Colors.blue,
                          );
                          Widget divider2 = const Divider(
                            color: Colors.green,
                          );
                          return i % 2 == 0 ? divider1 : divider2;
                        },
                      ),
                      width: 240,
                    )
                  : Container(
                      width: 240,
                    );
            },
          ),

          Observer(
            builder: (_) {
              final item = app.selectedFeedItem;
              return item != null ? Expanded(child: _Post(item)) : Container();
            },
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
