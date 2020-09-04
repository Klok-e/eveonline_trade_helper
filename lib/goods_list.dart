import 'package:dart_eveonline_esi/api.dart';
import 'package:eveonline_trade_helper/main.dart';
import 'package:eveonline_trade_helper/sort_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GoodsList extends StatelessWidget {
  final SortType sortType;

  const GoodsList({Key key, this.sortType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: [
            Icon(
              Icons.image,
              size: 50,
            ),
            Text("shit1"),
            Spacer(),
            Text("buy xxx"),
            Spacer(),
            Text("sell xxx"),
            Spacer(),
            Text("margin zzz")
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.image,
              size: 50,
            ),
            Text(
              "shit2",
            ),
            Spacer(),
            Text("buy yyy"),
            Spacer(),
            Text("sell yyy"),
            Spacer(),
            Text("margin zzz")
          ],
        ),
      ],
    );
  }
}