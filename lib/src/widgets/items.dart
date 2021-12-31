import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:thunderbird_rss/src/core/models.dart' as model;
import 'package:thunderbird_rss/src/widgets/item_content.dart';

import 'item.dart';

enum _FeedAction {
  onlyStarredItems,
  onlyUnreadItems,
}

typedef OnItemClick = void Function(model.FeedItem item);

class _ExtraSettings extends StatelessWidget {
  final model.Feed feed;

  const _ExtraSettings(this.feed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var onlyUnreadItems = PopupMenuItem<_FeedAction>(
      value: _FeedAction.onlyUnreadItems,
      child: ListTile(
        leading: Observer(
          builder: (BuildContext context) {
            return Checkbox(
              value: feed.onlyUnreadItems,
              onChanged: (value) {
                feed.onlyUnreadItems = value == true;
                feed.reload();
              },
            );
          },
        ),
        title: Text("Only unread"),
      ),
    );

    var onlyStarredItems = PopupMenuItem<_FeedAction>(
      value: _FeedAction.onlyStarredItems,
      child: ListTile(
        leading: Observer(
          builder: (BuildContext context) {
            return Checkbox(
              value: feed.onlyStarredItems,
              onChanged: (value) {
                feed.onlyStarredItems = value == true;
                feed.reload();
              },
            );
          },
        ),
        title: Text("Only starred"),
      ),
    );

    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      onSelected: (_FeedAction result) {
        switch (result) {
          case _FeedAction.onlyStarredItems:
            // feed.onlyStarredItems = !feed.onlyStarredItems;
            break;
          case _FeedAction.onlyUnreadItems:
            // feed.onlyUnreadItems = !feed.onlyUnreadItems;
            break;
          default:
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_FeedAction>>[
        onlyUnreadItems,
        onlyStarredItems,
      ],
    );
  }
}

class _ListView extends StatefulWidget {
  final model.Feed feed;
  final OnItemClick onItemClick;

  const _ListView(this.feed, this.onItemClick, {Key? key}) : super(key: key);

  @override
  _ListViewState createState() => _ListViewState();
}

class _ListViewState extends State<_ListView> {
  final app = GetIt.I.get<model.App>();

  var _multiSelectEnabled = false;
  var _updating = false;
  final _selectedItems = <model.FeedItem>{};

  _update() async {
    setState(() {
      _updating = true;
    });
    await widget.feed.update();
    setState(() {
      _updating = false;
    });
  }

  _toggleMultiSelect() {
    setState(() {
      var enabled = !_multiSelectEnabled;
      _multiSelectEnabled = enabled;

      if (!enabled) {
        _selectedItems.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var feed = widget.feed;
    var items = feed.items;
    var listView = Observer(
      builder: (BuildContext context) {
        return ListView.separated(
          itemBuilder: (BuildContext context, int i) {
            var item = items[i];

            return FeedItem(
              item,
              feed,
              selectable: _multiSelectEnabled,
              selected: _selectedItems.contains(item),
              onSelectionChange: (item, selected) {
                if (selected) {
                  _selectedItems.add(item);
                } else {
                  _selectedItems.remove(item);
                }
                setState(() {});
              },
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
                        onPressed: _updating ? null : _update,
                        icon: const Icon(Icons.refresh),
                      ),
                      IconButton(
                        onPressed: _toggleMultiSelect,
                        icon: const Icon(Icons.checklist_rtl),
                      ),
                      _multiSelectEnabled && _selectedItems.isNotEmpty
                          ? IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.check),
                            )
                          : Container(),
                      _multiSelectEnabled && _selectedItems.isNotEmpty
                          ? IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.star),
                            )
                          : Container(),
                      _multiSelectEnabled && _selectedItems.isNotEmpty
                          ? IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.delete),
                            )
                          : Container(),
                      _ExtraSettings(feed),
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
  model.FeedItem? _reading;

  @override
  Widget build(BuildContext context) {
    var feed = widget.feed;
    var reading = _reading;

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
      child: reading == null
          ? _ListView(
              feed,
              (item) {
                setState(() {
                  _isListView = false;
                  _reading = item;
                });
              },
            )
          : ItemContent(
              reading,
              feed,
              () {
                setState(() {
                  _isListView = true;
                  _reading = null;
                });
              },
            ),
    );
  }
}
