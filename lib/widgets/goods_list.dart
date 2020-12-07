import 'package:eveonline_trade_helper/models/market_cmp_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TradesList extends StatelessWidget {
  final List<MarketCmpResultF> comparisons;

  const TradesList({Key key, @required this.comparisons}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: comparisons.map((e) {
        return e.when(
          success: (itemId, data) {
            return EveItem(
              itemName: "item ${itemId}",
              buyPrice: data.buy,
              sellPrice: data.sell,
              margin: data.margin,
              buyAvailableVolume: data.buyAvailableVolume,
              sellVolume: data.sellVolume,
            );
          },
          fromNotStocked: (itemId) {
            return Text("not implemented: from not stocked");
          },
          toNotStocked: (itemId, data) {
            return Text("not implemented: to not stocked");
          },
        );
      }).toList(),
    );
  }
}

class EveItem extends StatelessWidget {
  final String itemName;

  final double buyPrice;
  final double sellPrice;
  final double margin;
  final int buyAvailableVolume;
  final int sellVolume;

  const EveItem(
      {Key key,
      @required this.itemName,
      @required this.buyPrice,
      @required this.sellPrice,
      @required this.margin,
      @required this.buyAvailableVolume,
      @required this.sellVolume})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.compact();
    final fmtPerc = NumberFormat.percentPattern();
    return Row(
      children: [
        Icon(
          Icons.image,
          size: 50,
        ),
        Text(itemName),
        Spacer(),
        Text(fmt.format(buyPrice)),
        Spacer(),
        Text(fmt.format(sellPrice)),
        Spacer(),
        Text(fmtPerc.format(margin))
      ],
    );
  }
}
