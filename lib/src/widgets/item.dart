import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:intl/intl.dart';

import 'package:thunderbird_rss/src/core/models.dart' as model;
import 'package:thunderbird_rss/src/widgets/feed_fav_icon.dart';

typedef OnSelectionChange = void Function(model.FeedItem item, bool selected);

void _onTap() {}
void _onSelectionChange(model.FeedItem item, bool selected) {}

enum _FeedItemAction {
  markAsRead,
  markAsUnread,
  remove,
  star,
  unstar,
}

class _Actions extends StatelessWidget {
  final model.Feed feed;
  final model.FeedItem item;

  const _Actions(this.item, this.feed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      var actions = <PopupMenuEntry<_FeedItemAction>>[
        item.read
            ? const PopupMenuItem<_FeedItemAction>(
                value: _FeedItemAction.markAsUnread,
                child: ListTile(
                  leading: Icon(Icons.mark_as_unread),
                  title: Text('Mark as unread'),
                ),
              )
            : const PopupMenuItem<_FeedItemAction>(
                value: _FeedItemAction.markAsRead,
                child: ListTile(
                  leading: Icon(Icons.check),
                  title: Text('Mark as read'),
                ),
              ),
        item.starred
            ? const PopupMenuItem<_FeedItemAction>(
                value: _FeedItemAction.unstar,
                child: ListTile(
                  leading: Icon(Icons.star),
                  title: Text('Star'),
                ),
              )
            : const PopupMenuItem<_FeedItemAction>(
                value: _FeedItemAction.star,
                child: ListTile(
                  leading: Icon(Icons.star),
                  title: Text('Star'),
                ),
              ),
        const PopupMenuItem<_FeedItemAction>(
          value: _FeedItemAction.remove,
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('Remove'),
          ),
        ),
      ];

      return PopupMenuButton(
        icon: const Icon(Icons.more_vert),
        onSelected: (_FeedItemAction result) {
          //  TODO 收藏，删除，设置已读，设置未读

          switch (result) {
            case _FeedItemAction.markAsRead:
              item.setRead();
              break;
            case _FeedItemAction.markAsUnread:
              item.setUnread();
              break;
            case _FeedItemAction.star:
              item.setStarred();
              break;
            case _FeedItemAction.unstar:
              item.setUnread();
              break;
            case _FeedItemAction.remove:
              break;
            default:
              break;
          }

          log(result.toString());
        },
        itemBuilder: (BuildContext context) => actions,
      );
    });
  }
}

class FeedItem extends StatefulWidget {
  final model.Feed feed;
  final model.FeedItem item;
  final bool selectable;
  final bool selected;
  final OnSelectionChange onSelectionChange;
  final VoidCallback onTap;

  const FeedItem(
    this.item,
    this.feed, {
    Key? key,
    this.selectable = false,
    this.selected = false,
    this.onSelectionChange = _onSelectionChange,
    this.onTap = _onTap,
  }) : super(key: key);

  @override
  _FeedItemState createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  @override
  Widget build(BuildContext context) {
    var feed = widget.feed;
    var item = widget.item;
    var document = htmlparser.parse("""
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="referrer" content="no-referrer">
    <meta http-equiv="Content-Security-Policy"
        content="default-src 'none'; script-src 'self'; img-src http: https: data:; style-src 'self' 'unsafe-inline'; frame-src http: https:; media-src http: https:; connect-src https: http:">
    <title>${item.title}</title>
</head>
<body>${item.content}</body>
</html>
    """);
    var body = document.getElementsByTagName("body").first;
    var images = document.getElementsByTagName("img");
    var headImage =
        images.isNotEmpty ? images.first.attributes["src"] ?? "" : "";

    return GestureDetector(
      onTap: widget.onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // SizedBox(
          //   height: 48,
          //   width: 48,
          //   child: Image.network("http://via.placeholder.com/48x48"),
          // ),
          FeedFavIcon(feed, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      feed.title.toUpperCase(),
                      style: Theme.of(context).textTheme.overline,
                    ),
                    Text(
                      // "2012/01/01 12:30",
                      DateFormat('yyyy-MM-dd kk:mm').format(item.publishedAt),
                      style: Theme.of(context)
                          .textTheme
                          .overline
                          ?.copyWith(color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            // "Lorem Ipsum",
                            item.title,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            // "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit.",
                            // item.description,
                            body.text.trim(),
                            softWrap: true,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodyText2?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .color,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    // const SizedBox(width: 16),
                    // SizedBox(
                    //   height: 56,
                    //   width: 100,
                    //   child: Image.network("http://via.placeholder.com/100x56"),
                    // ),
                    headImage.isEmpty ? Container() : const SizedBox(width: 16),
                    // headImage.isEmpty
                    //     ? Container()
                    //     : SizedBox(
                    //         height: 56,
                    //         width: 100,
                    //         child: Image.network(headImage),
                    //       ),
                    headImage.isEmpty
                        ? Container()
                        : Container(
                            height: 56,
                            width: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fitHeight,
                                image: NetworkImage(headImage),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          widget.selectable == true
              ? Checkbox(
                  value: widget.selected,
                  onChanged: (value) {
                    widget.onSelectionChange(item, value == true);
                  },
                )
              : Container(),
          const SizedBox(width: 16),
          _Actions(item, feed),
        ],
      ),
    );
  }
}
