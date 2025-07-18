import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tracedev/models/laporan.dart';
import 'package:tracedev/services/api_services.dart';
import 'package:tracedev/services/cloudinary_service.dart';
import 'package:tracedev/widget/show_snackbar.dart';

class LaporanController extends ChangeNotifier {
  final _apiServices = ApiServices();
  final _cloudinaryService = CloudinaryService();

  List<Laporan> _laporans = [];
  List<Laporan> get laporans => _laporans;

  String? _lokasi;
  String? get lokasi => _lokasi;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  TextEditingController descriptionController = TextEditingController();
  TextEditingController materialController = TextEditingController();
  TextEditingController jumlahPekerjaController = TextEditingController();
  TextEditingController kendalaController = TextEditingController();

  Future<void> getAllLaporan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _laporans = await _apiServices.getAllLaporan();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getLaporanByProjectId(int projectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _laporans = await _apiServices.getLaporanByProjectId(projectId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> buatLaporan(
    File? selectedImage,
    int projectId,
    int mandorProyekId,
  ) async {
    _isLoading = true;
    _isSuccess = false;
    _errorMessage = null;
    notifyListeners();

    try {
      String? imageUrl;

      if (selectedImage != null) {
        imageUrl = await _cloudinaryService.uploadGambar(selectedImage);
        if (imageUrl == null) {
          throw Exception('Gagal mengupload gambar ke Cloudinary');
        }
      }

      final laporan = Laporan(
        deskripsi: descriptionController.text.trim(),
        material: materialController.text.trim(),
        lokasi: lokasi!,
        jumlahPekerja: int.parse(jumlahPekerjaController.text.trim()),
        kendala: kendalaController.text.trim(),
        foto: imageUrl,
        projectId: projectId,
        mandorProyekId: mandorProyekId,
      );

      await _apiServices.buatLaporan(laporan);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLaporan(
    File? selectedImage,
    int laporanId,
    String? imageUrlSekarang,
    String? existingLokasi,
  ) async {
    _isLoading = true;
    _isSuccess = false;
    _errorMessage = null;
    notifyListeners();

    try {
      String? imageUrl;

      if (selectedImage != null) {
        imageUrl = await _cloudinaryService.uploadGambar(selectedImage);
        if (imageUrl == null) {
          throw Exception('Gagal mengupload gambar ke Cloudinary');
        }
      } else {
        imageUrl = imageUrlSekarang;
      }

      final laporan = Laporan(
        deskripsi: descriptionController.text.trim(),
        material: materialController.text.trim(),
        lokasi: existingLokasi!,
        jumlahPekerja: int.parse(jumlahPekerjaController.text.trim()),
        kendala: kendalaController.text.trim(),
        foto: imageUrl,
      );

      await _apiServices.updateLaporan(laporan, laporanId);
      _errorMessage = null;
      _isSuccess = true;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearForm() {
    descriptionController.clear();
    materialController.clear();
    jumlahPekerjaController.clear();
    kendalaController.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void dispose() {
    descriptionController.dispose();
    materialController.dispose();
    jumlahPekerjaController.dispose();
    kendalaController.dispose();
    super.dispose();
  }

  Future<void> pickLocation(BuildContext context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ShowSnackbar.show(context, 'Layanan lokasi tidak aktif.', false);
        return;
      }
      PermissionStatus permissionStatus = await Permission.location.status;
      if (permissionStatus.isDenied) {
        permissionStatus = await Permission.location.request();
        if (permissionStatus.isDenied) {
          ShowSnackbar.show(context, 'Izin lokasi ditolak.', false);
          return;
        }
      }

      if (permissionStatus.isPermanentlyDenied) {
        ShowSnackbar.show(
          context,
          'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan.',
          false,
        );
        await openAppSettings();
        return;
      } else {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        _lokasi = '${position.latitude}, ${position.longitude}';
      }
    } catch (e) {
      ShowSnackbar.show(context, 'Gagal mendapatkan lokasi: $e', false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
