import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dart_eveonline_esi/api.dart';
import 'package:eveonline_trade_helper/models/market_cmp_result.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';

import '../models/eve_system.dart';

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

  const ItemOrders(this.orders, this.order);
}

class SystemMarketData {
  Map<int, ItemOrders> _sell;

  SystemMarketData(List<OrderData> orders) {
    final buySell = groupBy<OrderData, Order>(orders, (x) => x.order);
    buySell[Order.Buy] = buySell[Order.Buy] ?? [];
    buySell[Order.Sell] = buySell[Order.Sell] ?? [];

    _sell = groupBy<OrderData, int>(buySell[Order.Sell], (v) => v.typeId).map(
        (k, v) => MapEntry(
            k, ItemOrders(v.map((e) => e.orderData).toList(), Order.Sell)));
    // _buy = groupBy<OrderData, int>(
    //         orders.where((ord) => ord.order == Order.Buy).toList(),
    //         (v) => v.typeId)
    //     .map((k, v) => MapEntry(
    //         k, ItemOrders(v.map((e) => e.orderData).toList(), Order.Buy, k)));
  }

  static MarketCmpResultF _cmpItems(
      int itemId, ItemOrders from, ItemOrders to) {
    if (from == null && to == null) {
      throw ArgumentError("from and to cant both be null");
    }
    if (from == null || from.orders.isEmpty) {
      throw ArgumentError("from cant both be null or empty");
    }

    // find min buy price
    final fromPrice = from.orders
        .fold<double>(from.orders.first.price, (acc, x) => min(acc, x.price));
    final fromVol = from.orders.fold<int>(
        from.orders.first.volumeRemain, (acc, x) => acc + x.volumeRemain);

    if (to == null || to.orders.isEmpty) {
      return MarketCmpResultF.toNotStocked(
        itemId,
        MarketToNotStocked(fromPrice, fromVol),
      );
    }

    // find either min (if sell order) or max (if buy order) sell price
    final toPrice = to.orders.fold<double>(
        to.orders.first.price,
        (acc, x) =>
            from.order == Order.Sell ? min(acc, x.price) : max(acc, x.price));
    final toVol = from.orders.fold<int>(
        from.orders.first.volumeRemain, (acc, x) => acc + x.volumeRemain);

    return MarketCmpResultF.success(
        itemId,
        MarketSuccess(
            margin: (toPrice - fromPrice) / fromPrice,
            profit: toPrice - fromPrice,
            buy: fromPrice,
            sell: toPrice,
            buyAvailableVolume: fromVol,
            sellVolume: toVol));
  }

  List<MarketCmpResultF> cmpSellSell(SystemMarketData other) {
    final compared = _sell.entries.map((entry) {
      return _cmpItems(entry.key, entry.value, other._sell[entry.key]);
    });
    return compared.toList();
  }
}

class MarketDataService {
  final MarketApi _marketApi;
  final UniverseApi _universeApi;
  final Logger _logger;

  MarketDataService(this._marketApi, this._universeApi, this._logger);

  Future<SystemMarketData> systemData(EveSystem system) async {
    _logger.v("system market data for system ${system.name} requested");
    // first get region id for orders
    var constellation = await _universeApi
        .getUniverseConstellationsConstellationId(system.constellationId);
    var regionId = constellation.regionId;

    // get ALL THE ORDERS
    var regionOrders = <GetMarketsRegionIdOrders200Ok>[];
    List<GetMarketsRegionIdOrders200Ok> pageOrders;
    var page = 1;
    do {
      pageOrders = await _marketApi.getMarketsRegionIdOrders("all", regionId,
          page: page++);
      regionOrders.addAll(pageOrders);
      _logger.v(
          "system ${system.name}: page ${page} finished download: ${pageOrders.length} orders downloaded");
    } while (pageOrders.length >= 1000);

    var systemOrders = regionOrders.where((el) => el.systemId == system.id).map(
        (e) => OrderData(ItemOrderData(e.price, e.volumeRemain), e.typeId,
            e.isBuyOrder ? Order.Buy : Order.Sell));

    return SystemMarketData(systemOrders.toList());
  }
}
