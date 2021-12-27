import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'src/core/sqlite.dart' as sqlite;
import 'src/core/models.dart' as model;

import 'src/widgets/item_content.dart';
import 'src/widgets/items.dart';
import 'src/widgets/nav.dart';

void main() async {
  final storage = sqlite.ThunderBirdRSSDataBase(sqlite.openDBConnection());
  final model.App app = model.App(storage);
  GetIt.I.registerSingleton<sqlite.ThunderBirdRSSDataBase>(storage);
  GetIt.I.registerSingleton<model.App>(app);

  await app.init();
  // const atom = 'https://www.theverge.com/rss/index.xml';
  // const rss = 'https://developer.apple.com/news/releases/rss/releases.rss';
  // final subscriptions = Subscriptions(sqlite);
  // await subscriptions.add(atom);
  // await subscriptions.add(rss);
  // print(subscriptions.feeds.length);

  // https://www.vgtime.com/rss.jhtml
  // https://rss.cnbeta.com/rss
  // https://feeds.appinn.com/appinns/
  // https://www.ifanr.com/feed

  runApp(const ThunderbirdRSSApp());
}

class ThunderbirdRSSApp extends StatelessWidget {
  const ThunderbirdRSSApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ThunderbirdRSSApp',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FeedsNavigation(),
          Expanded(child: FeedItemsListView()),
          // Expanded(child: _PostContent()),
        ],
      ),
    );
  }
}
