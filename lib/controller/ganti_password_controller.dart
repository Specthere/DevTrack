import 'package:flutter/material.dart';
import 'package:tracedev/models/ganti_password_model.dart';
import 'package:tracedev/services/api_services.dart';

class GantiPasswordController extends ChangeNotifier {
  final _apiServices = ApiServices();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  String? _errorMessage = null;
  String? get errorMessage => _errorMessage;

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void clearForm() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  Future<bool> gantiPassword(GantiPasswordModel password) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      bool success = await _apiServices.gantiPassword(password);
      print("Password berhasil diubah $success");
      _isSuccess = success;
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
