class GlobalState {
  static final GlobalState _instance = GlobalState._internal();
  bool firstInitialize = false;

  factory GlobalState() {
    return _instance;
  }

  GlobalState._internal();
}
