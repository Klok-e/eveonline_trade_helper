import 'dart:math';

import 'package:dart_eveonline_esi/api.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/eve_system.dart';

enum Order { Buy, Sell }

@immutable
class OrderData {
  final ItemOrderData orderData;
  final int typeId;
  final Order order;

  const OrderData(this.orderData, this.typeId, this.order);
}

@immutable
class ItemOrderData {
  final double price;
  final int volumeRemain;

  const ItemOrderData(this.price, this.volumeRemain);
}

@immutable
class ItemOrders {
  final List<ItemOrderData> orders;
  final Order order;
  final int itemId;

  const ItemOrders(this.orders, this.order, this.itemId);
}

class SystemMarketData {
  Map<int, ItemOrders> _sell;

  SystemMarketData(List<OrderData> orders)
      : _sell = groupBy<OrderData, int>(
            orders.where((ord) => ord.order == Order.Sell).toList(),
            (v) =>
                v.typeId).map((k, v) => MapEntry(
            k, ItemOrders(v.map((e) => e.orderData).toList(), Order.Sell, k))) {
    // _buy = groupBy<OrderData, int>(
    //         orders.where((ord) => ord.order == Order.Buy).toList(),
    //         (v) => v.typeId)
    //     .map((k, v) => MapEntry(
    //         k, ItemOrders(v.map((e) => e.orderData).toList(), Order.Buy, k)));
  }

  static MarketCmpResult _cmpItems(ItemOrders? from, ItemOrders? to) {
    if (from == null && to == null) {
      throw ArgumentError("from and to cant both be null");
    }

    if (from == null) {
      return MarketFromNotStocked(to!.itemId);
    }
    if (from.orders.isEmpty) {
      return MarketFromNotStocked(from.itemId);
    }

    // find min buy price
    final fromPrice = from.orders
        .fold<double>(from.orders.first.price, (acc, x) => min(acc, x.price));
    final fromVol = from.orders.fold<int>(
        from.orders.first.volumeRemain, (acc, x) => acc + x.volumeRemain);

    if (to == null || to.orders.isEmpty) {
      return MarketToNotStocked(fromPrice, fromVol, from.itemId);
    }

    assert(from.itemId == to.itemId);

    // find either min (if sell order) or max (if buy order) sell price
    final toPrice = to.orders.fold<double>(to.orders.first.price,
        (acc, x) => (from.order == Order.Sell ? min : max)(acc, x.price));
    final toVol = from.orders.fold<int>(
        from.orders.first.volumeRemain, (acc, x) => acc + x.volumeRemain);

    return MarketSuccess((toPrice - fromPrice) / fromPrice, fromPrice, toPrice,
        fromVol, toVol, from.itemId);
  }

  List<MarketCmpResult> cmpSellSell(SystemMarketData other) {
    final compared = _sell.entries.map((entry) {
      return _cmpItems(entry.value, other._sell[entry.key]);
    });
    return compared.toList();
  }
}

class MarketCmpResult {
  final int itemId;

  MarketCmpResult(this.itemId);
}

class MarketSuccess extends MarketCmpResult {
  final double margin;
  final double buy;
  final double sell;
  final int buyAvailableVolume;
  final int sellVolume;

  MarketSuccess(this.margin, this.buy, this.sell, this.buyAvailableVolume,
      this.sellVolume, int itemId)
      : super(itemId);
}

class MarketFromNotStocked extends MarketCmpResult {
  MarketFromNotStocked(int itemId) : super(itemId);
}

class MarketToNotStocked extends MarketCmpResult {
  final double buy;
  final int buyAvailableVolume;

  MarketToNotStocked(this.buy, this.buyAvailableVolume, int itemId)
      : super(itemId);
}

class MarketData {
  final MarketApi _marketApi;
  final UniverseApi _universeApi;

  MarketData(MarketApi marketApi, UniverseApi _universeApi)
      : _marketApi = marketApi,
        _universeApi = _universeApi;

  Future<SystemMarketData> systemData(EveSystem system) async {
    // first get region id for orders
    var constellation = await _universeApi
        .getUniverseConstellationsConstellationId(system.constellationId);
    var regionId = constellation.regionId;

    // get ALL THE ORDERS
    var regionOrders = <GetMarketsRegionIdOrders200Ok>[];
    List<GetMarketsRegionIdOrders200Ok> pageOrders;
    var page = 0;
    do {
      pageOrders = await _marketApi.getMarketsRegionIdOrders("all", regionId,
          page: page++);
      regionOrders.addAll(pageOrders);
    } while (pageOrders.length >= 1000);

    var systemOrders = regionOrders.where((el) => el.systemId == system.id).map(
        (e) => OrderData(ItemOrderData(e.price, e.volumeRemain), e.typeId,
            e.isBuyOrder ? Order.Buy : Order.Sell));

    return SystemMarketData(systemOrders.toList());
  }
}
