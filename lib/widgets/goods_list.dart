import 'package:eveonline_trade_helper/models/market_cmp_result.dart';
import 'package:eveonline_trade_helper/services/item_data_service.dart';
import 'package:eveonline_trade_helper/widgets/trades_table_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TradesList extends StatelessWidget {
  final List<MarketCmpResultF> comparisons;
  final TradesTableSource _source;

  TradesList(
      {Key key,
      @required this.comparisons,
      @required ItemDataService itemDataService})
      : _source = TradesTableSource(itemDataService),
        super(key: key) {
    _source.setData(comparisons);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: PaginatedDataTable(
          columnSpacing: 20.0,
          columns: [
            DataColumn(label: Text("Icon")),
            DataColumn(label: Text("Name")),
            DataColumn(label: Text("Buy")),
            DataColumn(label: Text("Sell")),
            DataColumn(label: Text("Profit")),
            DataColumn(label: Text("Margin")),
          ],
          source: _source,
          header: Container(),
        ));
  }
}
