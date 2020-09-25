import 'package:eveonline_trade_helper/sort_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'market_data.dart';

class TradesList extends StatelessWidget {
  final SortType sortType;
  final SystemMarketData sysFrom;
  final SystemMarketData sysTo;

  const TradesList({Key key, this.sortType, this.sysFrom, this.sysTo})
      : assert(sortType != null),
        assert(sysFrom != null),
        assert(sysTo != null),
        super(key: key);

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
