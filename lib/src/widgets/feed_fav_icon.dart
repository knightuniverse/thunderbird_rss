import 'package:flutter/material.dart';

import 'package:thunderbird_rss/src/core/models.dart' as core;

class FeedFavIcon extends StatelessWidget {
  final core.Feed feed;
  double? size;

  FeedFavIcon(this.feed, {Key? key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);

    return feed.icon.isNotEmpty
        ? SizedBox(
            child: Image.network(
              feed.icon,
              fit: BoxFit.fill,
            ),
            height: size ?? iconTheme.size,
            width: size ?? iconTheme.size,
          )
        : const Icon(Icons.rss_feed);
  }
}
