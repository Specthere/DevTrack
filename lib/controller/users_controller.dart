import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tracedev/models/users.dart';
import 'package:tracedev/services/api_services.dart';
import 'package:tracedev/services/cloudinary_service.dart';

class UsersController extends ChangeNotifier {
  final _apiServices = ApiServices();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  List<Users> _users = [];
  List<Users> get users => _users;

  Users? _mandor;
  Users? get mandor => _mandor;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController noHpController = TextEditingController();
  TextEditingController alamatController = TextEditingController();

  void clearForm() {
    namaController.clear();
    emailController.clear();
    passwordController.clear();
    noHpController.clear();
    alamatController.clear();
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    noHpController.dispose();
    alamatController.dispose();
  }

  Future<void> createMandor(File? _selectedImage) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      String? _imageUrl;

      if (_selectedImage != null) {
        _imageUrl = await _cloudinaryService.uploadGambar(_selectedImage);
        if (_imageUrl == null) {
          throw Exception('Gagal mengupload gambar ke Cloudinary');
        }
      }

      if (namaController.text.trim().isEmpty ||
          emailController.text.trim().isEmpty ||
          passwordController.text.trim().isEmpty ||
          noHpController.text.trim().isEmpty ||
          alamatController.text.trim().isEmpty) {
        throw Exception('Semua field harus diisi');
      }

      print('Nama: ${namaController.text}');
      print('Email: ${emailController.text}');
      print('Password: ${passwordController.text}');
      print('No HP: ${noHpController.text}');
      print('Alamat: ${alamatController.text}');
      print('Error Message: $_errorMessage');

      final mandor = Users(
        nama: namaController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        noHp: noHpController.text.trim(),
        alamat: alamatController.text.trim(),
        foto: _selectedImage != null ? _imageUrl : null,
        isActive: true,
      );

      await _apiServices.createMandor(mandor);
      _isSuccess = true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllMandors() async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      _users = await _apiServices.getAllMandors();
      _isSuccess = true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> getMandorById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      _mandor = await _apiServices.getMandorById(id);
      _isSuccess = true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleMandorStatus(int id) async {
    try {
      await _apiServices.toggleMandorStatus(id);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Error: $_errorMessage');
      return false;
    }
  }

  Future<bool> updateAkunMandor(
    int id,
    File? _selectedImage,
    String _imgUrlSekarang,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      String? _imageUrl;

      if (_selectedImage != null) {
        _imageUrl = await _cloudinaryService.uploadGambar(_selectedImage);
        if (_imageUrl == null) {
          throw Exception('Gagal mengupload gambar ke Cloudinary');
        }
      } else {
        _imageUrl = _imgUrlSekarang;
      }

      final mandor = Users(
        nama: namaController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        noHp: noHpController.text.trim(),
        alamat: alamatController.text.trim(),
        foto: _imageUrl,
        isActive: true,
      );

      await _apiServices.editMandor(id, mandor);
      _isSuccess = true;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Error: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
