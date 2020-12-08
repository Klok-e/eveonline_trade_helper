import 'package:eveonline_trade_helper/models/eve_system.dart';
import 'package:eveonline_trade_helper/models/market_cmp_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';

import '../services/market_data.dart';

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
      List<MarketCmpResultF> itemComparisons) = _Comparison;
}

class CompareSystemsBloc extends Bloc<CmpSystems, CompareSystemsState> {
  final MarketDataService _marketData;
  final Logger _logger;

  CompareSystemsBloc(this._marketData, this._logger)
      : super(CompareSystemsState());

  @override
  Stream<CompareSystemsState> mapEventToState(CmpSystems event) async* {
    yield CompareSystemsState.loading();

    try {
      final fromTo = await Future.wait(
          [event.from, event.to].map(this._marketData.systemData));
      final fromData = fromTo[0];
      final toData = fromTo[1];
      yield CompareSystemsState.comparison(fromData.cmpSellSell(toData).take(1000).toList());
    } on Exception catch (e) {
      _logger.e(e.toString());
      yield CompareSystemsState.error(e.toString());
    }
  }
}
