import 'package:eveonline_trade_helper/models/eve_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'services/market_data.dart';
import 'services/system_search.dart';

part 'compare_systems_bloc.freezed.dart';

@immutable
class CmpSystems {
  final EveSystem from;
  final EveSystem to;

  CmpSystems(this.from, this.to);
}

@freezed
abstract class CompareSystemsState with _$CompareSystemsState {
  const factory CompareSystemsState() = _Empty;

  const factory CompareSystemsState.error(String message) = _Error;

  const factory CompareSystemsState.loading() = _Loading;


  const factory CompareSystemsState.comparison(
      List<MarketCmpResult> itemComparisons) = _Comparison;
}

class CompareSystemsBloc extends Bloc<CmpSystems, CompareSystemsState> {
  final MarketDataService marketData;

  CompareSystemsBloc(this.marketData) : super(CompareSystemsState());

  @override
  Stream<CompareSystemsState> mapEventToState(CmpSystems event) async* {
    yield CompareSystemsState.loading();

    try {
      final fromData = await this.marketData.systemData(event.from);
      final toData = await this.marketData.systemData(event.to);
      yield CompareSystemsState.comparison(fromData.cmpSellSell(toData));
    } on Exception catch (e) {
      yield CompareSystemsState.error(e.toString());
      rethrow;
    }
  }
}
