import 'package:dart_eveonline_esi/api.dart';

import 'eve_system.dart';

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
        systemOrders.where((ord) => ord.order == Order.Sell).toList(),
        systemOrders.where((ord) => ord.order == Order.Buy).toList());
  }
}
