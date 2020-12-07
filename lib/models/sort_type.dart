import 'package:eveonline_trade_helper/models/market_cmp_result.dart';
import 'package:collection/collection.dart';

enum SortType {
  profit_desc,
  margin_desc,
}

extension SortTypeExt on SortType {
  String get name {
    switch (this) {
      case SortType.profit_desc:
        return "Margin Descending";
      case SortType.margin_desc:
        return "Profit Descending";
    }
  }

  void sort(List<MarketCmpResultF> comparisons) {
    switch (this) {
      case SortType.profit_desc:
        comparisons.sort((a, b) {
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
        comparisons.sort((a, b) {
          return b.maybeWhen(
            success: (itemId, bdata) => bdata.margin.compareTo(b.maybeWhen(
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
  }
}
