class GlobalState {
  static final GlobalState _instance = GlobalState._internal();
  bool DBChecker = false;
  bool firstInitialize = false;
  bool categorieFirstInitialize = false;
  bool apiInitialize = false;
  bool categorieApiInitialize = false;
  int localDBAutoIncrement = 0;
  String userId = '';
  String email = '';
  String user = '';
  String authId = '';
  String authphotoUrl = '';
  String authSource = '';
  // String userId = 'yQVulGUaY0DhKz00JbRP';
  String newIdFromApi = "";

  factory GlobalState() {
    return _instance;
  }

  GlobalState._internal();
}
