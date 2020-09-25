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
    final worthyItems = sysFrom.cmpSellSell(sysTo);
    return ListView(
      children: [
        EveItem(),
      ],
    );
  }
}

class EveItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
