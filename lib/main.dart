import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
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
  // https://www.ifanr.com/feed

  runApp(const ThunderbirdRSSApp());
}

class ThunderbirdRSSApp extends StatelessWidget {
  const ThunderbirdRSSApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ThunderbirdRSSApp',
      home: HomePage(),
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('ThunderRSS'),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8,
                    left: 8,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(48),
                      maximumSize: Size.fromHeight(48),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (__) => _SubscriptionDialog(),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        Text("New"),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RSS'),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.refresh),
                      )
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.message),
                  title: Text('Messages'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Profile'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {},
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8, left: 8),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Container(
                  constraints: BoxConstraints.expand(height: 48),
                  // decoration: BoxDecoration(color: Colors.red),
                  child: Padding(
                    padding: EdgeInsets.only(right: 8, left: 8),
                    child: Form(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Search",
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 48,
          width: 48,
          child: Image.network("http://via.placeholder.com/48x48"),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "cnbeta",
                    style: Theme.of(context).textTheme.overline,
                  ),
                  Text(
                    "2012/01/01 12:30",
                    style: Theme.of(context)
                        .textTheme
                        .overline
                        ?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Lorem Ipsum",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...",
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(
                              color: Theme.of(context).textTheme.caption!.color,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    height: 56,
                    width: 100,
                    child: Image.network("http://via.placeholder.com/100x56"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Items extends StatelessWidget {
  const _Items({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    "CNBETA",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.refresh),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.checklist_rtl),
                      ),
                      //  hide by defualts
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.check),
                      ),
                      //  hide by defualts
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.star),
                      ),
                      //  hide by defualts
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.delete),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.more_vert),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        Divider(
          thickness: 1,
        ),
        SizedBox(height: 32),
        Expanded(
          child: SizedBox(
            width: 840,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _Item(),
                Divider(
                  indent: 64,
                  thickness: 1,
                ),
                _Item(),
                Divider(
                  indent: 64,
                  thickness: 1,
                ),
                _Item(),
                Divider(
                  indent: 64,
                  thickness: 1,
                ),
                _Item(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PostContent extends StatelessWidget {
  const _PostContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Lorem Ipsum",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "2021/12/20 12:30 / CNBETA / By milo",
                        style: Theme.of(context).textTheme.overline,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.check),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.star),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.close),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        Divider(
          thickness: 1,
        ),
        SizedBox(height: 32),
        Expanded(
          child: SizedBox(
            width: 840,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      text:
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras commodo cursus mi, vitae porta elit. Sed neque tellus, luctus a commodo non, interdum luctus nulla. Etiam vel fermentum erat. Nullam aliquet blandit placerat. Duis efficitur gravida tortor, pulvinar rhoncus velit mollis in. Etiam non iaculis augue. Ut egestas aliquet gravida. In hac habitasse platea dictumst. Morbi ultrices ex quis consectetur posuere. In hac habitasse platea dictumst. Curabitur nec lacinia nisi, porttitor venenatis ex. Duis ut porta orci, a venenatis felis."),
                  TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      text:
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras commodo cursus mi, vitae porta elit. Sed neque tellus, luctus a commodo non, interdum luctus nulla. Etiam vel fermentum erat. Nullam aliquet blandit placerat. Duis efficitur gravida tortor, pulvinar rhoncus velit mollis in. Etiam non iaculis augue. Ut egestas aliquet gravida. In hac habitasse platea dictumst. Morbi ultrices ex quis consectetur posuere. In hac habitasse platea dictumst. Curabitur nec lacinia nisi, porttitor venenatis ex. Duis ut porta orci, a venenatis felis."),
                  TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      text:
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras commodo cursus mi, vitae porta elit. Sed neque tellus, luctus a commodo non, interdum luctus nulla. Etiam vel fermentum erat. Nullam aliquet blandit placerat. Duis efficitur gravida tortor, pulvinar rhoncus velit mollis in. Etiam non iaculis augue. Ut egestas aliquet gravida. In hac habitasse platea dictumst. Morbi ultrices ex quis consectetur posuere. In hac habitasse platea dictumst. Curabitur nec lacinia nisi, porttitor venenatis ex. Duis ut porta orci, a venenatis felis."),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _SubscriptionDialog extends StatelessWidget {
  const _SubscriptionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DialogTheme dialogTheme = DialogTheme.of(context);
    final ThemeData theme = Theme.of(context);

    return Dialog(
      child: IntrinsicHeight(
        child: Container(
          constraints: BoxConstraints(
            // minHeight: 280,
            maxWidth: 320,
            minWidth: 320,
          ),
          child: Padding(
            padding: EdgeInsets.only(right: 8, left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 16, left: 16),
                  child: SizedBox(
                    height: 64,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Add Subscription",
                        style: dialogTheme.titleTextStyle ??
                            theme.textTheme.headline6,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 16, left: 16),
                  child: Form(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "URL",
                        hintText: "Feed URL",
                        icon: Icon(Icons.rss_feed),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Ok"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _Navigation(),
          // Expanded(child: _Items()),
          Expanded(child: _PostContent()),
        ],
      ),
    );
  }
}
