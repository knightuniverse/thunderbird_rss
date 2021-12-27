import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Navigation extends StatelessWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const ListTile(
                  title: Text('ThunderRSS'),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8, left: 8),
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
                        const Icon(Icons.add),
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
                        onPressed: () {},
                        icon: Icon(Icons.refresh),
                      )
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.message),
                  title: Text('Messages'),
                  trailing: Text("100"),
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
                const Padding(
                  padding: EdgeInsets.only(right: 8, left: 8),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Container(
                  constraints: const BoxConstraints.expand(height: 48),
                  // decoration: BoxDecoration(color: Colors.red),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, left: 8),
                    child: Form(
                      child: TextFormField(
                        decoration: const InputDecoration(
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
