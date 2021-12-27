import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:thunderbird_rss/src/core/models.dart' as core;

import 'feed_fav_icon.dart';
import 'item.dart';

enum WhyFarther { harder, smarter, selfStarter, tradingCharter }

class FeedItemsListView extends StatefulWidget {
  const FeedItemsListView({Key? key}) : super(key: key);

  @override
  _FeedItemsListViewState createState() => _FeedItemsListViewState();
}

class _FeedItemsListViewState extends State<FeedItemsListView> {
  final app = GetIt.I.get<core.App>();

  @override
  Widget build(BuildContext context) {
    var feed = app.selectedFeed;

    if (feed == null) {
      //  TODO Empty items
      return Container();
    }

    var items = feed.items;
    var listView = Observer(
      builder: (BuildContext context) {
        return ListView.separated(
          itemBuilder: (BuildContext context, int i) {
            return FeedItem(items[i], feed);
          },
          separatorBuilder: (BuildContext context, int i) {
            return const Divider(
              indent: 64,
              thickness: 1,
            );
          },
          itemCount: items.length,
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 56,
              width: 840,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    feed.title,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.refresh),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.checklist_rtl),
                      ),
                      //  hide by defualts
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.check),
                      ),
                      //  hide by defualts
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.star),
                      ),
                      //  hide by defualts
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.delete),
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (WhyFarther result) {},
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<WhyFarther>>[
                          const PopupMenuItem<WhyFarther>(
                            value: WhyFarther.harder,
                            child: Text('Working a lot harder'),
                          ),
                          const PopupMenuItem<WhyFarther>(
                            value: WhyFarther.smarter,
                            child: Text('Being a lot smarter'),
                          ),
                          const PopupMenuItem<WhyFarther>(
                            value: WhyFarther.selfStarter,
                            child: Text('Being a self-starter'),
                          ),
                          const PopupMenuItem<WhyFarther>(
                            value: WhyFarther.tradingCharter,
                            child: Text('Placed in charge of trading charter'),
                          ),
                        ],
                      ),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: Icon(Icons.more_vert),
                      // ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        const Divider(
          thickness: 1,
        ),
        const SizedBox(height: 32),
        Expanded(
          child: SizedBox(
            width: 840,
            child: listView,
            // child: ListView(
            //   padding: EdgeInsets.zero,
            //   children: [
            //     FeedItem(),
            //     Divider(
            //       indent: 64,
            //       thickness: 1,
            //     ),
            //     FeedItem(),
            //     Divider(
            //       indent: 64,
            //       thickness: 1,
            //     ),
            //     FeedItem(),
            //     Divider(
            //       indent: 64,
            //       thickness: 1,
            //     ),
            //     FeedItem(),
            //   ],
            // ),
          ),
        ),
      ],
    );
  }
}
