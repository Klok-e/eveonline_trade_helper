import 'package:eveonline_trade_helper/models/market_cmp_result.dart';

enum SortType {
  profit_desc,
  margin_desc,
}

extension SortTypeExt on SortType {
  String get name {
    switch (this) {
      case SortType.margin_desc:
        return "Margin Descending";
      case SortType.profit_desc:
        return "Profit Descending";
    }
  }

  List<MarketCmpResultF> sort(List<MarketCmpResultF> comparisons) {
    final cmps = List<MarketCmpResultF>.from(comparisons);
    switch (this) {
      case SortType.profit_desc:
        cmps.sort((a, b) {
          return b.maybeWhen(
            success: (itemId, bdata) => bdata.profit.compareTo(a.maybeWhen(
              success: (itemId, adata) => adata.profit,
              orElse: () => double.negativeInfinity,
            )),
            orElse: () => a.maybeWhen(
              success: (itemId, adata) => -1,
              orElse: () => 1,
            ),
          );
        });
        break;
      case SortType.margin_desc:
        cmps.sort((a, b) {
          return b.maybeWhen(
            success: (itemId, bdata) => bdata.margin.compareTo(a.maybeWhen(
              success: (itemId, adata) => adata.margin,
              orElse: () => double.negativeInfinity,
            )),
            orElse: () => a.maybeWhen(
              success: (itemId, adata) => -1,
              orElse: () => 1,
            ),
          );
        });
        break;
    }
    return cmps;
  }
}
