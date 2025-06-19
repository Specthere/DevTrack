// controllers/project_controller.dart
import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/data_service.dart';

class ProjectController extends ChangeNotifier {
  final DataService _dataService = DataService();
  
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all projects
  Future<void> loadProjects() async {
    _setLoading(true);
    _error = null;
    
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      _projects = _dataService.getAllProjects();
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat proyek: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Get project by ID
  void selectProject(int projectId) {
    _selectedProject = _dataService.getProjectById(projectId);
    notifyListeners();
  }

  // Filter projects by status
  List<Project> getProjectsByStatus(String status) {
    return _dataService.getProjectsByStatus(status);
  }

  // Get project statistics
  Map<String, int> getStatistics() {
    return _dataService.getProjectStatistics();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedProject() {
    _selectedProject = null;
    notifyListeners();
  }
}