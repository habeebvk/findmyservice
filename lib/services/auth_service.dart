import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  static const String _userKey = 'user_session';

  UserModel? get currentUser => _currentUser;

  Future<void> login(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toMap()));
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  bool get isLoggedIn => _currentUser != null;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _currentUser = UserModel.fromMap(json.decode(userJson));
    }
  }

  void updateCurrentUser(UserModel user) {
    _currentUser = user;
    // Also persist updates if needed
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_userKey, json.encode(user.toMap()));
    });
  }
}
