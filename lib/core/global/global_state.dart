class GlobalState {
  static final GlobalState _instance = GlobalState._internal();
  bool firstInitialize = false;
  bool apiInitialize = false;
  int localDBAutoIncrement = 0;
  String newIdFromApi = "";

  factory GlobalState() {
    return _instance;
  }

  GlobalState._internal();
}
