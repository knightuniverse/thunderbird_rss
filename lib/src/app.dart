import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import 'core/sqlite.dart' as sqlite;
import 'core/models.dart' as model;

class ThunderbirdRSSApp extends StatelessWidget {
  const ThunderbirdRSSApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
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
    GetIt.I.get<sqlite.ThunderBirdRSSDataBase>(),
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
              return item != null
                  ? Expanded(
                      child: Html(
                        data: item.content,
                      ),
                    )
                  : Container();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
