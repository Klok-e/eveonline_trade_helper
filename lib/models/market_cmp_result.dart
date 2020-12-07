import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_cmp_result.freezed.dart';

@freezed
abstract class MarketCmpResultF with _$MarketCmpResultF {
  const factory MarketCmpResultF.success(int itemId, MarketSuccess data) =
      _Success;

  const factory MarketCmpResultF.fromNotStocked(int itemId) = _FromNotStocked;

  const factory MarketCmpResultF.toNotStocked(
      int itemId, MarketToNotStocked data) = _ToNotStocked;
}

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
}

class MarketToNotStocked {
  final double buy;
  final int buyAvailableVolume;

  MarketToNotStocked(this.buy, this.buyAvailableVolume);
}
