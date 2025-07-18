import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracedev/services/api_services.dart';

class AuthController extends ChangeNotifier {
  final ApiServices _apiService = ApiServices();

  String? _token;
  String? get token => _token;

  int? _userId;
  int? get userId => _userId;

  String? _role;
  String? get role => _role;

  Future<void> login(String email, String password) async {
    try {
      final result = await _apiService.login(email, password);
      _token = result['token'];

      Map<String, dynamic> payload = Jwt.parseJwt(_token!);
      _role =
          payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
      _userId = int.tryParse(payload['UserId'].toString());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      print("token: $_token");
      if (_role != null) {
        await prefs.setString('role', _role!);
        print("role: $_role");
      }
      if (_userId != null) {
        await prefs.setInt('userId', _userId!);
        print("userId: $_userId");
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Login Error: $e');
      rethrow;
    }
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('role');
    _token = prefs.getString('token');
    _userId = prefs.getInt('userId');
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');
    await prefs.remove('token');
    await prefs.remove('userId');

    _role = null;
    _token = null;
    _userId = null;

    notifyListeners();
  }
}
