import 'package:dart_eveonline_esi/api.dart';
import 'package:eveonline_trade_helper/eve_system.dart';
import 'package:eveonline_trade_helper/main.dart';
import 'package:eveonline_trade_helper/select_systems_dialog.dart';
import 'package:eveonline_trade_helper/sort_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TradesList extends StatelessWidget {
  final SortType sortType;
  final SelectedSystems systems;

  const TradesList({Key key, this.sortType, this.systems})
      : assert(sortType != null),
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

enum Order { Buy, Sell }

class OrderData {
  final double price;
  final int volumeRemain;
  final int typeId;
  final Order order;

  const OrderData(this.price, this.volumeRemain, this.typeId, this.order);
}

class SystemMarketData {
  final List<OrderData> _sell;
  final List<OrderData> _buy;

  const SystemMarketData(this._sell, this._buy);
}

class MarketData {
  final MarketApi _marketApi;
  final UniverseApi _universeApi;

  MarketData(MarketApi marketApi, UniverseApi _universeApi)
      : assert(marketApi != null),
        assert(_universeApi != null),
        _marketApi = marketApi,
        _universeApi = _universeApi;

  Future<SystemMarketData> systemData(EveSystem system) async {
    // first get region id for orders
    var constellation = await _universeApi
        .getUniverseConstellationsConstellationId(system.constellationId);
    var regionId = constellation.regionId;

    // get ALL THE ORDERS
    var regionOrders = <GetMarketsRegionIdOrders200Ok>[];
    List<GetMarketsRegionIdOrders200Ok> pageOrders;
    do {
      pageOrders = await _marketApi.getMarketsRegionIdOrders("all", regionId);
      regionOrders.addAll(pageOrders);
    } while (pageOrders.length >= 1000);

    var systemOrders = regionOrders.where((el) => el.systemId == system.id).map(
        (e) => OrderData(e.price, e.volumeRemain, e.typeId,
            e.isBuyOrder ? Order.Buy : Order.Sell));

    return SystemMarketData(
        List.unmodifiable(systemOrders.where((ord) => ord.order == Order.Sell)),
        List.unmodifiable(systemOrders.where((ord) => ord.order == Order.Buy)));
  }
}
