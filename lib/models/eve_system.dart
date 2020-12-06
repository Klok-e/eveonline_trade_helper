import 'package:flutter/material.dart';

class EveSystem {
  final int constellationId;
  final int id;
  final String name;
  final double secStatus;

  const EveSystem(this.secStatus, this.name, this.id, this.constellationId);

  Color get secColor {
    var secVal = (secStatus * 10.0).round();
    int hex;
    switch (secVal) {
      case 10:
        hex = 0xff2FEFEF;
        break;
      case 9:
        hex = 0xff48F0C0;
        break;
      case 8:
        hex = 0xff00EF47;
        break;
      case 7:
        hex = 0xff00F000;
        break;
      case 6:
        hex = 0xff8FEF2F;
        break;
      case 5:
        hex = 0xffEFEF00;
        break;
      case 4:
        hex = 0xffD77700;
        break;
      case 3:
        hex = 0xffF06000;
        break;
      case 2:
        hex = 0xffF04800;
        break;
      case 1:
        hex = 0xffD73000;
        break;
      case 0:
      default:
        hex = 0xffF00000;
        break;
    }
    return Color(hex);
  }
}
