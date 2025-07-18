import 'package:flutter/material.dart';
import 'package:tracedev/models/riwayat.dart';
import 'package:tracedev/services/api_services.dart';

class RiwayatController extends ChangeNotifier {
  final _apiServices = ApiServices();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Riwayat> _riwayats = [];
  List<Riwayat> get riwayats => _riwayats;

  TextEditingController catatanController = TextEditingController();

  Future<void> getAllRiwayat() async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      _riwayats = await _apiServices.getAllRiwayat();
      _isSuccess = true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRiwayat(int projectId) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final riwayat = Riwayat(
        projectId: projectId,
        catatan: catatanController.text.trim(),
      );
      await _apiServices.buatRiwayat(riwayat);
      _isSuccess = true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    catatanController.clear();
  }

  void dispose() {
    catatanController.dispose();
  }
}
