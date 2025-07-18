import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tracedev/models/mandor_project_project.dart';
import 'package:tracedev/services/api_services.dart';

class MandorProjectProjectController extends ChangeNotifier {
  final _apiServices = ApiServices();

  List<MandorProjectProject> _mandorProjectProjects = [];
  List<MandorProjectProject> get mandorProjectProjects =>
      _mandorProjectProjects;

  List<MandorProjectProject> _allMandor = [];
  List<MandorProjectProject> get allMandor => _allMandor;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  String? _errorMessage = null;
  String? get errorMessage => _errorMessage;

  static Future<String> getCityFromStringCoords(String koordinat) async {
    try {
      final parts = koordinat.split(',');
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final kecamatan = place.subLocality;
        final kota = place.locality ?? place.subAdministrativeArea;
        final provinsi = place.administrativeArea;

        final parts = [
          if (kecamatan != null && kecamatan.isNotEmpty) kecamatan,
          if (kota != null && kota.isNotEmpty) kota,
          if (provinsi != null && provinsi.isNotEmpty) provinsi,
        ];
        return parts.join(', ');
      } else {
        return "Tidak ditemukan";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  Future<void> getAllMandorProjectProject() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allMandor = await _apiServices.getAllMandorProjectProject();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getProjectByMandor() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mandorProjectProjects = await _apiServices.getProjectByMandor();
      print('[getProjectByMandor] API call successful.');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tugaskanMandor(int mandorProyekId, int projectId) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final mpp = MandorProjectProject(
        mandorProyekId: mandorProyekId,
        projectId: projectId,
      );
      bool success = await _apiServices.tugaskanMandor(mpp);
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
