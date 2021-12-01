import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'src/core/sqlite.dart' as sqlite;
import 'src/core/models.dart' as model;
import 'src/app.dart';

void main() async {
  final storage = sqlite.ThunderBirdRSSDataBase(sqlite.openDBConnection());
  final model.App app = model.App(storage);
  GetIt.I.registerSingleton<sqlite.ThunderBirdRSSDataBase>(storage);
  GetIt.I.registerSingleton<model.App>(app);

  app.init();
  // const atom = 'https://www.theverge.com/rss/index.xml';
  // const rss = 'https://developer.apple.com/news/releases/rss/releases.rss';
  // final subscriptions = Subscriptions(sqlite);
  // await subscriptions.add(atom);
  // await subscriptions.add(rss);
  // print(subscriptions.feeds.length);

  // https://www.vgtime.com/rss.jhtml
  // https://rss.cnbeta.com/rss
  // https://feeds.appinn.com/appinns/

  runApp(const ThunderbirdRSSApp());
}
