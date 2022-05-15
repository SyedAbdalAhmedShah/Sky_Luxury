class AdminManager {
  AdminManager._privateConstructor();

  static bool isAdminLogedIn = false;
  static String adminUid = '';
  static String adminName = '';
  static final AdminManager _instance = AdminManager._privateConstructor();

  factory AdminManager() {
    return _instance;
  }
}
