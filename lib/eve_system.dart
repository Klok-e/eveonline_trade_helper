import 'package:flutter/material.dart';

class EveSystem {
  final int id;
  final String name;
  final double secStatus;

  const EveSystem(
      {@required this.secStatus, @required this.name, @required this.id})
      : assert(name != null),
        assert(id != null),
        assert(secStatus != null);

  Color get secColor {
    var secVal = (secStatus * 10.0).round();
    var hex;
    switch (secVal) {
      case 10:
        hex = 0x2FEFEF;
        break;
      case 9:
        hex = 0x48F0C0;
        break;
      case 8:
        hex = 0x00EF47;
        break;
      case 7:
        hex = 0x00F000;
        break;
      case 6:
        hex = 0x8FEF2F;
        break;
      case 5:
        hex = 0xEFEF00;
        break;
      case 4:
        hex = 0xD77700;
        break;
      case 3:
        hex = 0xF06000;
        break;
      case 2:
        hex = 0xF04800;
        break;
      case 1:
        hex = 0xD73000;
        break;
      case 0:
      default:
        hex = 0xF00000;
        break;
    }
    return Color(hex);
  }
}
