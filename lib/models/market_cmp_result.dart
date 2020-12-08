import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_cmp_result.freezed.dart';

part 'market_cmp_result.g.dart';

@freezed
abstract class MarketCmpResultF with _$MarketCmpResultF {
  const factory MarketCmpResultF.success(int itemId, MarketSuccess data) =
      _Success;

  const factory MarketCmpResultF.toNotStocked(
      int itemId, MarketToNotStocked data) = _ToNotStocked;

  factory MarketCmpResultF.fromJson(Map<String, dynamic> json) =>
      _$MarketCmpResultFFromJson(json);
}

@JsonSerializable()
class MarketSuccess {
  final double margin;
  final double profit;
  final double buy;
  final double sell;
  final int buyAvailableVolume;
  final int sellVolume;

  MarketSuccess(
      {@required this.margin,
      @required this.profit,
      @required this.buy,
      @required this.sell,
      @required this.buyAvailableVolume,
      @required this.sellVolume});

  factory MarketSuccess.fromJson(Map<String, dynamic> json) =>
      _$MarketSuccessFromJson(json);

  Map<String, dynamic> toJson() => _$MarketSuccessToJson(this);
}

@JsonSerializable()
class MarketToNotStocked {
  final double buy;
  final int buyAvailableVolume;

  MarketToNotStocked(this.buy, this.buyAvailableVolume);

  factory MarketToNotStocked.fromJson(Map<String, dynamic> json) =>
      _$MarketToNotStockedFromJson(json);

  Map<String, dynamic> toJson() => _$MarketToNotStockedToJson(this);
}
