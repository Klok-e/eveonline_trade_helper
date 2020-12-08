import 'package:eveonline_trade_helper/models/item_info.dart';
import 'package:eveonline_trade_helper/models/market_cmp_result.dart';
import 'package:eveonline_trade_helper/services/item_data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

class TradesTableSource extends DataTableSource {
  final List<MarketCmpResultF> _data;
  final ItemDataService _itemDataService;

  TradesTableSource(this._itemDataService) : _data = [];

  void setData(List<MarketCmpResultF> data) {
    this._data.clear();
    this._data.addAll(data);
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    return _data[index].when(
      success: (itemId, data) {
        final itemInfo = _itemDataService.itemInfo(itemId);

        final fmt = NumberFormat.compact();
        final fmtPerc = NumberFormat.percentPattern();
        return DataRow(cells: [
          DataCell(FutureBuilder<ItemInfo>(
            future: itemInfo,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("error: ${snapshot.error.toString()}");
              }
              Widget widg;
              if (snapshot.hasData) {
                widg = Stack(
                  children: <Widget>[
                    Center(child: Icon(Icons.image)),
                    Center(
                      child: FadeInImage.memoryNetwork(
                        image: snapshot.data.imageUrl,
                        placeholder: kTransparentImage,
                      ),
                    ),
                  ],
                );
              } else {
                // TODO: change text prettily
                widg = Text("loading...");
              }
              return widg;
            },
          )),
          DataCell(FutureBuilder<ItemInfo>(
            future: itemInfo,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("error: ${snapshot.error.toString()}");
              }
              Widget widg;
              if (snapshot.hasData) {
                widg = Text("${snapshot.data.name}");
              } else {
                // TODO: change text prettily
                widg = Text("loading...");
              }
              return widg;
            },
          )),
          DataCell(Text(fmt.format(data.buy))),
          DataCell(Text(fmt.format(data.sell))),
          DataCell(Text(fmt.format(data.profit))),
          DataCell(Text(fmtPerc.format(data.margin))),
        ]);
      },
      toNotStocked: (itemId, data) {
        return DataRow(cells: [
          DataCell(Text("not:")),
          DataCell(Text("")),
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
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
