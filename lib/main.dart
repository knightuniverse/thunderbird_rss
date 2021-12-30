import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import 'src/core/sqlite.dart' as sqlite;
import 'src/core/models.dart' as model;

import 'src/widgets/items.dart';
import 'src/widgets/nav.dart';

void main() async {
  final storage = sqlite.ThunderBirdRSSDataBase(sqlite.openDBConnection());
  final model.App app = model.App(storage);
  GetIt.I.registerSingleton<sqlite.ThunderBirdRSSDataBase>(storage);
  GetIt.I.registerSingleton<model.App>(app);

  await app.init();

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
    final app = GetIt.I.get<model.App>();

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const FeedsNavigation(),
          Observer(
            builder: (BuildContext context) {
              var feed = app.selectedFeed;
              return Expanded(
                child: feed == null ? Container() : FeedItemsListView(feed),
              );
            },
          ),
          // Expanded(child: _PostContent()),
        ],
      ),
    );
  }
}
