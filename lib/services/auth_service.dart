import '../model/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  void login(UserModel user) {
    _currentUser = user;
  }

  void logout() {
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null;

  void updateCurrentUser(UserModel user) {
    _currentUser = user;
  }
}
