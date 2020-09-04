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
    return null;
  }
}
