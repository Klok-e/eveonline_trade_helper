import 'package:dart_eveonline_esi/api.dart';
import 'package:eveonline_trade_helper/models/item_info.dart';
import 'package:eveonline_trade_helper/services/eve_icon_service.dart';

class ItemDataService {
  final UniverseApi _universeApi;
  final EveIconService _eveIconService;

  ItemDataService(this._universeApi, this._eveIconService);

  Future<ItemInfo> itemInfo(int itemId) async {
    final info = await _universeApi.getUniverseTypesTypeId(itemId);
    final image = _eveIconService.getIcon(info.typeId);
    return ItemInfo(name: info.name, imageUrl: image);
  }
}
