import 'package:flutter/material.dart';

class ItemContent extends StatelessWidget {
  final VoidCallback onClose;

  const ItemContent(this.onClose, {Key? key}) : super(key: key);

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
