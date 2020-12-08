import 'package:eveonline_trade_helper/models/market_cmp_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class _TradesTableSource extends DataTableSource {
  final List<MarketCmpResultF> data;

  _TradesTableSource(this.data);

  @override
  DataRow getRow(int index) {
    return data[index].when(
      success: (itemId, data) {
        return EveItem(
          itemName: "item ${itemId}",
          buyPrice: data.buy,
          sellPrice: data.sell,
          margin: data.margin,
          profit: data.profit,
          buyAvailableVolume: data.buyAvailableVolume,
          sellVolume: data.sellVolume,
        ).createRow();
      },
      toNotStocked: (itemId, data) {
        return DataRow(cells: [
          DataCell(Text("not:")),
          DataCell(Text(":")),
          DataCell(Text("implemented")),
          DataCell(Text("to")),
          DataCell(Text("not")),
          DataCell(Text("stocked")),
        ]);
      },
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

class TradesList extends StatelessWidget {
  final List<MarketCmpResultF> comparisons;

  const TradesList({Key key, @required this.comparisons}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: PaginatedDataTable(
          columns: [
            DataColumn(label: Text("Icon")),
            DataColumn(label: Text("Name")),
            DataColumn(label: Text("Buy")),
            DataColumn(label: Text("Sell")),
            DataColumn(label: Text("Profit")),
            DataColumn(label: Text("Margin")),
          ],
          source: _TradesTableSource(comparisons),
          header: Container(),
        ));
  }
}

class EveItem extends StatelessWidget {
  final String itemName;

  final double buyPrice;
  final double sellPrice;
  final double margin;
  final int buyAvailableVolume;
  final int sellVolume;
  final double profit;

  DataRow createRow() {
    final fmt = NumberFormat.compact();
    final fmtPerc = NumberFormat.percentPattern();
    return DataRow(cells: [
      DataCell(Icon(
        Icons.image,
        size: 50,
      )),
      DataCell(Text(itemName)),
      DataCell(Text(fmt.format(buyPrice))),
      DataCell(Text(fmt.format(sellPrice))),
      DataCell(Text(fmt.format(profit))),
      DataCell(Text(fmtPerc.format(margin))),
    ]);
  }

  const EveItem(
      {Key key,
      @required this.itemName,
      @required this.buyPrice,
      @required this.sellPrice,
      @required this.margin,
      @required this.buyAvailableVolume,
      @required this.sellVolume,
      @required this.profit})
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
        Text(fmt.format(profit)),
        Spacer(),
        Text(fmtPerc.format(margin)),
      ],
    );
  }
}
