import 'package:animations/animations.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:thunderbird_rss/src/core/models.dart' as model;
import 'package:thunderbird_rss/src/widgets/item_content.dart';

import 'item.dart';

enum _FeedAction { markItemsAsRead, markItemsAsUnread, star, removeItems }

typedef OnItemClick = void Function(model.FeedItem item);

class _ListView extends StatefulWidget {
  final model.Feed feed;
  final OnItemClick onItemClick;

  const _ListView(this.feed, this.onItemClick, {Key? key}) : super(key: key);

  @override
  _ListViewState createState() => _ListViewState();
}

class _ListViewState extends State<_ListView> {
  final app = GetIt.I.get<model.App>();

  @override
  Widget build(BuildContext context) {
    var feed = widget.feed;
    var items = feed.items;
    var listView = Observer(
      builder: (BuildContext context) {
        return ListView.separated(
          itemBuilder: (BuildContext context, int i) {
            return GestureDetector(
              child: FeedItem(items[i], feed),
              onTap: () {
                widget.onItemClick(items[i]);
              },
            );
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
                        onSelected: (_FeedAction result) {},
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<_FeedAction>>[
                          const PopupMenuItem<_FeedAction>(
                            value: _FeedAction.markItemsAsRead,
                            child: Text('Working a lot harder'),
                          ),
                          const PopupMenuItem<_FeedAction>(
                            value: _FeedAction.markItemsAsUnread,
                            child: Text('Being a lot smarter'),
                          ),
                          const PopupMenuItem<_FeedAction>(
                            value: _FeedAction.star,
                            child: Text('Being a self-starter'),
                          ),
                          const PopupMenuItem<_FeedAction>(
                            value: _FeedAction.removeItems,
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
          ),
        ),
      ],
    );
  }
}

class FeedItemsListView extends StatefulWidget {
  final model.Feed feed;

  const FeedItemsListView(this.feed, {Key? key}) : super(key: key);

  @override
  _FeedItemsListViewState createState() => _FeedItemsListViewState();
}

class _FeedItemsListViewState extends State<FeedItemsListView> {
  bool _isListView = true;

  @override
  Widget build(BuildContext context) {
    var feed = widget.feed;

    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 400),
      reverse: !_isListView,
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
        );
      },
      child: _isListView
          ? _ListView(feed, (item) {
              setState(() {
                _isListView = false;
              });
            })
          : ItemContent(() {
              setState(() {
                _isListView = true;
              });
            }),
    );
  }
}

// class FeedItemsListView extends StatelessWidget {
//   final model.Feed feed;

//   const FeedItemsListView(this.feed, {Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return _ListView(feed);

//     return PageTransitionSwitcher(
//       duration: const Duration(milliseconds: 300),
//       reverse: !_isLoggedIn,
//       transitionBuilder: (
//         Widget child,
//         Animation<double> animation,
//         Animation<double> secondaryAnimation,
//       ) {
//         return SharedAxisTransition(
//           child: child,
//           animation: animation,
//           secondaryAnimation: secondaryAnimation,
//           transitionType: _transitionType!,
//         );
//       },
//       child: _isLoggedIn ? _CoursePage() : _SignInPage(),
//     );
//   }
// }
