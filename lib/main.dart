// import 'package:flutter/material.dart';
// import 'src/app.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_flutter_asset/jaguar_flutter_asset.dart';

import 'src/core/sqlite.dart';
import 'src/app.dart';

void main() async {
  GetIt.I.registerSingleton<ThunderBirdRSSDataBase>(
    ThunderBirdRSSDataBase(openDBConnection()),
  );

  final server = Jaguar(address: "127.0.0.1", port: 9000);
  server.addRoute(serveFlutterAssets());
  await server.serve();

  // const atom = 'https://www.theverge.com/rss/index.xml';
  // const rss = 'https://developer.apple.com/news/releases/rss/releases.rss';
  // final subscriptions = Subscriptions(sqlite);
  // await subscriptions.add(atom);
  // await subscriptions.add(rss);
  // print(subscriptions.feeds.length);
  runApp(const ThunderbirdRSSApp());
}
