import 'dart:collection';

import 'package:dart_eveonline_esi/api.dart';

import 'eve_system.dart';

/// For fast validation of system name correctness
class SystemSearch {
  final UniverseApi _universeApi;
  final SearchApi _searchApi;

  HashSet<String> _systemNames = HashSet();

  SystemSearch(UniverseApi universeApi, SearchApi searchApi)
      : assert(universeApi != null),
        assert(searchApi != null),
        _universeApi = universeApi,
        _searchApi = searchApi;

  Future<Iterable<EveSystem>> searchSystems(
      String pattern, int takeFirst) async {
    assert(pattern != null);
    assert(takeFirst != null);

    var systems = await _searchApi.getSearch(<String>["solar_system"], pattern);
    if (systems.solarSystem == null) {
      return <EveSystem>[];
    }

    var sys = await Future.wait(
        systems.solarSystem.take(takeFirst).map((sysid) async {
      var sysinfo = await _universeApi.getUniverseSystemsSystemId(sysid);
      return EveSystem(
        sysinfo.securityStatus,
        sysinfo.name,
        sysid,
      );
    }));
    _systemNames.addAll(sys.map((e) => e.name));
    return sys;
  }

  bool systemNameExists(String name) {
    assert(name != null);
    return _systemNames.contains(name);
  }
}
