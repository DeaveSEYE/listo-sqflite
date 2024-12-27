class GlobalState {
  static final GlobalState _instance = GlobalState._internal();
  bool firstInitialize = false;
  bool apiInitialize = false;

  factory GlobalState() {
    return _instance;
  }

  GlobalState._internal();
}
