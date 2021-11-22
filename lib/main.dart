import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'src/core/sqlite.dart';
import 'src/app.dart';

void main() async {
  GetIt.I.registerSingleton<ThunderBirdRSSDataBase>(
    ThunderBirdRSSDataBase(openDBConnection()),
  );

  // const atom = 'https://www.theverge.com/rss/index.xml';
  // const rss = 'https://developer.apple.com/news/releases/rss/releases.rss';
  // final subscriptions = Subscriptions(sqlite);
  // await subscriptions.add(atom);
  // await subscriptions.add(rss);
  // print(subscriptions.feeds.length);
  runApp(const ThunderbirdRSSApp());
}
