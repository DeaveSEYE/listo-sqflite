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
  String firebasePushNotifToken = "";
  // bool daillyTasks = false;
  // bool tasksIn4Hours = false;
  // bool tasksIn2Hours = false;
  // bool tasksIn30Minutes = false;

  factory GlobalState() {
    return _instance;
  }

  GlobalState._internal();
}
