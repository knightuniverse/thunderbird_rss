import 'dart:io';

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';

import 'package:thunderbird_rss/src/core/models.dart' as model;

class ItemContent extends StatelessWidget {
  final model.Feed feed;
  final model.FeedItem item;

  final VoidCallback onClose;

  const ItemContent(this.item, this.feed, this.onClose, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyText2 = Style(
      color: theme.textTheme.bodyText2?.color,
      fontSize: FontSize(
        theme.textTheme.bodyText2?.fontSize,
      ),
      fontWeight: theme.textTheme.bodyText2?.fontWeight,
      letterSpacing: theme.textTheme.bodyText2?.letterSpacing,
    );
    final caption = Style(
      color: theme.textTheme.caption?.color,
      fontSize: FontSize(
        theme.textTheme.caption?.fontSize,
      ),
      fontWeight: theme.textTheme.caption?.fontWeight,
      letterSpacing: theme.textTheme.caption?.letterSpacing,
    );
    final headline5 = Style(
      color: theme.textTheme.headline5?.color,
      fontSize: FontSize(
        theme.textTheme.headline5?.fontSize,
      ),
      fontWeight: theme.textTheme.headline5?.fontWeight,
      letterSpacing: theme.textTheme.headline5?.letterSpacing,
    );
    final headline6 = Style(
      color: theme.textTheme.headline6?.color,
      fontSize: FontSize(
        theme.textTheme.headline6?.fontSize,
      ),
      fontWeight: theme.textTheme.headline6?.fontWeight,
      letterSpacing: theme.textTheme.headline6?.letterSpacing,
    );

    final isDesktopPlatform =
        Platform.isMacOS || Platform.isLinux || Platform.isWindows;

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
                      const SizedBox(height: 4),
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
                        icon: const Icon(Icons.star),
                      ),
                      IconButton(
                        onPressed: () {
                          onClose();
                        },
                        icon: const Icon(Icons.close),
                      ),
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
            // child: RichText(
            //   text: TextSpan(
            //     children: [
            //       TextSpan(
            //           style: Theme.of(context).textTheme.bodyText2,
            //           text:
            //               "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras commodo cursus mi, vitae porta elit. Sed neque tellus, luctus a commodo non, interdum luctus nulla. Etiam vel fermentum erat. Nullam aliquet blandit placerat. Duis efficitur gravida tortor, pulvinar rhoncus velit mollis in. Etiam non iaculis augue. Ut egestas aliquet gravida. In hac habitasse platea dictumst. Morbi ultrices ex quis consectetur posuere. In hac habitasse platea dictumst. Curabitur nec lacinia nisi, porttitor venenatis ex. Duis ut porta orci, a venenatis felis."),
            //       TextSpan(
            //           style: Theme.of(context).textTheme.bodyText2,
            //           text:
            //               "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras commodo cursus mi, vitae porta elit. Sed neque tellus, luctus a commodo non, interdum luctus nulla. Etiam vel fermentum erat. Nullam aliquet blandit placerat. Duis efficitur gravida tortor, pulvinar rhoncus velit mollis in. Etiam non iaculis augue. Ut egestas aliquet gravida. In hac habitasse platea dictumst. Morbi ultrices ex quis consectetur posuere. In hac habitasse platea dictumst. Curabitur nec lacinia nisi, porttitor venenatis ex. Duis ut porta orci, a venenatis felis."),
            //       TextSpan(
            //           style: Theme.of(context).textTheme.bodyText2,
            //           text:
            //               "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras commodo cursus mi, vitae porta elit. Sed neque tellus, luctus a commodo non, interdum luctus nulla. Etiam vel fermentum erat. Nullam aliquet blandit placerat. Duis efficitur gravida tortor, pulvinar rhoncus velit mollis in. Etiam non iaculis augue. Ut egestas aliquet gravida. In hac habitasse platea dictumst. Morbi ultrices ex quis consectetur posuere. In hac habitasse platea dictumst. Curabitur nec lacinia nisi, porttitor venenatis ex. Duis ut porta orci, a venenatis felis."),
            //     ],
            //   ),
            // ),
            child: SingleChildScrollView(
              child: Html(
                customRender: isDesktopPlatform
                    ? {
                        "iframe": (RenderContext context, Widget child) {
                          var width =
                              MediaQuery.of(context.buildContext).size.width;
                          var height = width * 9 / 16;

                          return Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBFCFF),
                              borderRadius: BorderRadius.all(
                                Radius.circular(32),
                              ),
                            ),
                            constraints: const BoxConstraints(
                              maxWidth: 600,
                              minWidth: 200,
                              maxHeight: 450,
                              minHeight: 200,
                            ),
                            height: height,
                            width: width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset("assets/images/empty.png"),
                                Text(
                                  "Your OS does not support iframes.",
                                  style: theme.textTheme.caption,
                                ),
                              ],
                            ),
                          );
                        },
                      }
                    : {},
                data: item.content,
                shrinkWrap: true,
                style: {
                  //   TODO "a": Style(),
                  "div": bodyText2,
                  "figcaption": caption,
                  "h1": headline5,
                  "h2": headline6,
                  "h3": headline6,
                  "h4": headline6,
                  "h5": headline6,
                  "h6": headline6,
                  "p": bodyText2,
                  "span": bodyText2,
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
