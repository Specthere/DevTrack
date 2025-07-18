import 'package:flutter/material.dart';
import 'package:tracedev/models/mandor_project.dart';
import 'package:tracedev/services/api_services.dart';

class MandorProjectController extends ChangeNotifier {
  final _apiServices = ApiServices();

  List<MandorProject> _mandorsProject = [];
  List<MandorProject> get mandorsProject => _mandorsProject;

  MandorProject? _mandorProject;
  MandorProject? get mandorProject => _mandorProject;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> getAllMandorProject() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mandorsProject = await _apiServices.getAllMandorProject();
      print('[getAllMandorProject] API call successful.');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getMandorProjectById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mandorProject = await _apiServices.getMandorProjectById(id);
      print('[getMandorProjectById] API call successful.');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
