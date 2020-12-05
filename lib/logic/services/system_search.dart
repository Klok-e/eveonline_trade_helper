import 'package:dart_eveonline_esi/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/eve_system.dart';

@immutable
class SystemSearchPattern {
  final String pattern;
  final int takeFirst;

  SystemSearchPattern(this.takeFirst, this.pattern);
}

/// For fast validation of system name correctness
class SystemSearch {
  final UniverseApi _universeApi;
  final SearchApi _searchApi;

  Map<String, EveSystem> _systemNames = Map();

  SystemSearch(UniverseApi universeApi, SearchApi searchApi)
      : _universeApi = universeApi,
        _searchApi = searchApi;

  Future<List<EveSystem>> searchSystems(
      String pattern, int takeFirst) async {
    var systems = await _searchApi.getSearch(<String>["solar_system"], pattern);
    // if (systems.solarSystem == null) {
    //   return <EveSystem>[];
    // }

    var sys = await Future.wait(
        (systems.solarSystem ?? []).take(takeFirst).map((sysid) async {
      var sysinfo = await _universeApi.getUniverseSystemsSystemId(sysid);
      return EveSystem(
        sysinfo.securityStatus,
        sysinfo.name,
        sysid,
        sysinfo.constellationId,
      );
    }));
    _systemNames.addEntries(sys.map((s) => MapEntry(s.name, s)));
    return sys;
  }
}
