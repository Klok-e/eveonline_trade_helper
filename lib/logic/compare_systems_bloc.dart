import 'package:eveonline_trade_helper/models/eve_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'services/market_data.dart';
import 'services/system_search.dart';

@immutable
class CmpSystems {
  final EveSystem from;
  final EveSystem to;

  CmpSystems(this.from, this.to);
}

class CompareSystemsBloc extends Bloc<CmpSystems, List<MarketCmpResult>> {
  final MarketData marketData;

  CompareSystemsBloc(List<MarketCmpResult> initialState, this.marketData)
      : super(initialState);

  @override
  Stream<List<MarketCmpResult>> mapEventToState(CmpSystems event) async* {
    final fromData = await this.marketData.systemData(event.from);
    final toData = await this.marketData.systemData(event.to);
    yield fromData.cmpSellSell(toData);
  }
}
