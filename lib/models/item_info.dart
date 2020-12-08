import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class ItemInfo {
  final String name;
  final String imageUrl;

  ItemInfo({@required this.name, @required this.imageUrl});
}
