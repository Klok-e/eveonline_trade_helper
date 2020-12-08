class EveIconService {
  final String Url;

  EveIconService(this.Url);

  String getIcon(int typeId) {
    return "$Url/types/$typeId/icon";
  }
}
