import 'package:eveonline_trade_helper/models/sort_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../logic/services/market_data.dart';

class TradesList extends StatelessWidget {
  const TradesList({Key key, @required List<MarketCmpResult> comparisons})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final worthyItems = sysFrom.cmpSellSell(sysTo);
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
