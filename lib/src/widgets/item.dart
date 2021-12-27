import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Item extends StatelessWidget {
  const Item({Key? key}) : super(key: key);

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
        const SizedBox(width: 16),
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
                          "Lorem Ipsum",
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit.",
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              ?.copyWith(
                                color:
                                    Theme.of(context).textTheme.caption!.color,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
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
        const SizedBox(width: 16),
        Checkbox(value: false, onChanged: (value) {}),
        const SizedBox(width: 16),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          onSelected: (WhyFarther result) {},
          itemBuilder: (BuildContext context) => <PopupMenuEntry<WhyFarther>>[
            const PopupMenuItem<WhyFarther>(
              value: WhyFarther.harder,
              child: Text('Working a lot harder'),
            ),
            const PopupMenuItem<WhyFarther>(
              value: WhyFarther.smarter,
              child: Text('Being a lot smarter'),
            ),
            const PopupMenuItem<WhyFarther>(
              value: WhyFarther.selfStarter,
              child: Text('Being a self-starter'),
            ),
            const PopupMenuItem<WhyFarther>(
              value: WhyFarther.tradingCharter,
              child: Text('Placed in charge of trading charter'),
            ),
          ],
        ),
      ],
    );
  }
}