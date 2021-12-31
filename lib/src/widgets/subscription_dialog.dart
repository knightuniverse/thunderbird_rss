import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get_it/get_it.dart';

import 'package:thunderbird_rss/src/core/models.dart' as model;

class SubscriptionDialog extends StatefulWidget {
  const SubscriptionDialog({Key? key}) : super(key: key);

  @override
  _SubscriptionDialogState createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<SubscriptionDialog> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final app = GetIt.I.get<model.App>();
    final DialogTheme dialogTheme = DialogTheme.of(context);
    final ThemeData theme = Theme.of(context);

    return Dialog(
      child: IntrinsicHeight(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 320,
            minWidth: 320,
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16),
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
                  padding: const EdgeInsets.only(right: 16, left: 16),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: "URL",
                        hintText: "Feed URL",
                        icon: Icon(Icons.rss_feed),
                      ),
                      validator: ValidationBuilder().url().build(),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
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
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if ((_formKey.currentState as FormState).validate()) {
                            await app.subscribe(_controller.text);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Ok"),
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
