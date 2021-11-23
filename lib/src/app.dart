import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import 'core/sqlite.dart' as sqlite;
import 'core/models.dart' as model;

class _SubscribeDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SubscribeDialogState();
  }
}

class _SubscribeDialogState extends State<_SubscribeDialog> {
  final model.App _app = model.App(
    GetIt.I.get<sqlite.ThunderBirdRSSDataBase>(),
  );

  final TextEditingController _urlController = TextEditingController();

  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          TextField(
            autofocus: true,
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: "RSS",
              hintText: "RSS",
              prefixIcon: Icon(Icons.person),
            ),
          ),
          ElevatedButton(
            child: const Text("移动焦点"),
            onPressed: () async {
              if (_busy) {
                return;
              }

              setState(() {
                _busy = true;
              });

              await _app.subscribe(_urlController.text);

              setState(() {
                _busy = false;
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class ThunderbirdRSSApp extends StatelessWidget {
  const ThunderbirdRSSApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final model.App _app = model.App(
    GetIt.I.get<sqlite.ThunderBirdRSSDataBase>(),
  );

  @override
  void initState() {
    super.initState();
    _app.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          Container(
            child: Observer(
              builder: (ctx) {
                final IconThemeData iconTheme = IconTheme.of(ctx);
                return ListView.builder(
                  itemCount: _app.feeds.length,
                  itemBuilder: (BuildContext context, int index) {
                    final feed = _app.feeds[index];
                    return ListTile(
                      leading: feed.icon.isNotEmpty
                          ? SizedBox(
                              child: Image.network(
                                feed.icon,
                                fit: BoxFit.fill,
                              ),
                              height: iconTheme.size,
                              width: iconTheme.size,
                            ) //ImageIcon(NetworkImage(feed.icon))
                          : const Icon(Icons.rss_feed),
                      title: Text(feed.title + "( ${feed.unreadItemCount} )"),
                      onTap: () {
                        _app.checkout(feed);
                      },
                    );
                  },
                );
              },
            ),
            width: 250,
          ),
          const VerticalDivider(
            thickness: 1,
            width: 2,
          ),
          Observer(
            builder: (_) {
              final feed = _app.selectedFeed;
              return feed != null
                  ? Container(
                      child: ListView.builder(
                        itemCount: feed.items.length,
                        itemBuilder: (BuildContext context, int i) {
                          final item = feed.items[i];
                          return ListTile(
                            title: Text(item.title),
                            onTap: () {
                              _app.read(item);
                            },
                          );
                        },
                      ),
                      width: 320,
                    )
                  : Container(
                      width: 320,
                    );
            },
          ),
          const VerticalDivider(
            thickness: 1,
            width: 2,
          ),
          Observer(
            builder: (_) {
              final item = _app.selectedFeedItem;
              return item != null
                  ? Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          child: Padding(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 536,
                              ),
                              child: Html(
                                data: item.content,
                                shrinkWrap: true,
                              ),
                            ),
                            padding: const EdgeInsets.only(left: 32, right: 32),
                          ),
                        ),
                      ),
                    )
                  : Container();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) {
              return _SubscribeDialog();
            },
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
