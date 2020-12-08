import 'package:eveonline_trade_helper/models/market_cmp_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'compare_systems_state.freezed.dart';
part 'compare_systems_state.g.dart';

@freezed
abstract class CompareSystemsState with _$CompareSystemsState {
  const factory CompareSystemsState.empty() = _Empty;

  const factory CompareSystemsState.error(String message) = _Error;

  const factory CompareSystemsState.loading() = _Loading;

  const factory CompareSystemsState.comparison(
      List<MarketCmpResultF> itemComparisons) = _Comparison;

  factory CompareSystemsState.fromJson(Map<String, dynamic> json) =>
      _$CompareSystemsStateFromJson(json);
}
