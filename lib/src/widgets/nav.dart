import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import 'package:thunderbird_rss/src/core/models.dart' as model;

import 'subscription_dialog.dart';
import 'feed_fav_icon.dart';

class _FeedsNavigationState extends State<FeedsNavigation> {
  final app = GetIt.I.get<model.App>();

  bool _updating = false;
  bool _subscribing = false;

  @override
  Widget build(BuildContext context) {
    var feeds = app.feeds;
    var listView = Observer(
      builder: (BuildContext context) {
        return ListView(
          children: [
            const ListTile(
              title: Text('ThunderRSS'),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  maximumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  //  TODO Add Feed
                  showDialog(
                    context: context,
                    builder: (_) => SubscriptionDialog(),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    Text("Subscription"),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('RSS'),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: "Upladte all feeds",
                    onPressed: () async {
                      if (_updating) {
                        return;
                      }

                      setState(() {
                        _updating = true;
                      });

                      await app.udpateAllFeeds();

                      setState(() {
                        _updating = false;
                      });
                    },
                  )
                ],
              ),
            ),
            ...feeds
                .map(
                  (feed) => ListTile(
                    leading: FeedFavIcon(feed),
                    title: SizedBox(
                      width: 80,
                      child: Text(
                        feed.title,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                    trailing: Text("${feed.unreadItemCount}"),
                    onTap: () {
                      app.checkout(feed);
                    },
                  ),
                )
                .toList(),
            const Padding(
              padding: EdgeInsets.only(right: 8, left: 8),
              child: Divider(
                thickness: 1,
              ),
            ),
            Container(
              constraints: const BoxConstraints.expand(height: 48),
              child: Padding(
                padding: const EdgeInsets.only(right: 8, left: 8),
                child: Form(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Search",
                      icon: Icon(Icons.search),
                    ),
                    onFieldSubmitted: (keyword) {
                      //  TODO global search
                      print(keyword);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: listView,
          ),
        ],
      ),
    );
  }
}

class FeedsNavigation extends StatefulWidget {
  const FeedsNavigation({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FeedsNavigationState();
  }
}
