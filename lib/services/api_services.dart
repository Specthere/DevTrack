import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tracedev/models/ganti_password_model.dart';
import 'package:tracedev/models/laporan.dart';
import 'package:tracedev/models/mandor_project.dart';
import 'package:tracedev/models/mandor_project_project.dart';
import 'package:tracedev/models/project_model.dart';
import 'package:tracedev/models/riwayat.dart';
import 'package:tracedev/models/users.dart';
import 'package:tracedev/services/shared_preferences_services.dart';

class ApiServices {
  static const String baseUrl = "http://devtrack.runasp.net";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/Auth/login');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      throw Exception('Login gagal. Email atau password salah');
    } else if (response.statusCode == 401) {
      throw Exception('Akun sedang nonaktif bisa hubungi developer');
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData.containsKey('message')
                ? errorData['message']
                : 'Error ${response.statusCode}: ${response.reasonPhrase}';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception(
          'Unexpected error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }

  Future<bool> gantiPassword(GantiPasswordModel gantiPasswordModel) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http.put(
      Uri.parse('$baseUrl/api/UserManagement/edit-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(gantiPasswordModel.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData.containsKey('message') ? errorData['message'] : '';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception(
          'Unexpected error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }

  Future<List<ProjectModel>> getAllProjects() async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/Project'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => ProjectModel.fromJson(e)).toList();
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData.containsKey('message')
                ? errorData['message']
                : 'Error ${response.statusCode}: ${response.reasonPhrase}';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception(
          'Unexpected error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }

  Future<ProjectModel> getProjectById(int id) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/Project/$id'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return ProjectModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal mengambil data project');
    }
  }

  Future<bool> createProject(ProjectModel project) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http.post(
      Uri.parse('$baseUrl/api/Project/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(project.toCreateJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData.containsKey('message')
                ? errorData['message']
                : 'Error ${response.statusCode}: ${response.reasonPhrase}';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception(
          'Unexpected error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }

  Future<bool> updateProject(int id, ProjectModel project) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http.put(
      Uri.parse('$baseUrl/api/Project/edit/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(project.toCreateJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData.containsKey('message')
                ? errorData['message']
                : 'Error ${response.statusCode}: ${response.reasonPhrase}';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception(
          'Unexpected error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }

  Future<List<Users>> getAllMandors() async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/UserManagement/mandor'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Users.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data project');
    }
  }

  Future<Users> getMandorById(int id) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/UserManagement/mandor/$id'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return Users.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal mengambil data project');
    }
  }

  Future<bool> createMandor(Users users) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http.post(
      Uri.parse('$baseUrl/api/UserManagement/add-mandor'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(users.toCreateJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData.containsKey('message')
                ? "Error di API ${errorData['message']}"
                : 'Error ${response.statusCode}: ${response.reasonPhrase}';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception(
          'Unexpected error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }

  Future<bool> toggleMandorStatus(int id) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http.put(
      Uri.parse('$baseUrl/api/UserManagement/ToggleStatus/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Status berhasil diubah menjadi: ${data['is_active']}');
      return data['is_active'];
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData.containsKey('message')
                ? "Error di API ${errorData['message']}"
                : 'Error ${response.statusCode}: ${response.reasonPhrase}';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception(
          'Unexpected error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }

  Future<Users> editMandor(int id, Users user) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http.put(
      Uri.parse('$baseUrl/api/UserManagement/edit-mandor/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(user.toCreateJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Users.fromJson(data['mandor']);
    }

    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage =
          errorData.containsKey('message')
              ? "Error di API ${errorData['message']}"
              : 'Error ${response.statusCode}: ${response.reasonPhrase}';
      throw Exception(errorMessage);
    } catch (_) {
      throw Exception(
        'Unexpected error ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<List<MandorProject>> getAllMandorProject() async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/MandorProject'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => MandorProject.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data project');
    }
  }

  Future<MandorProject> getMandorProjectById(int id) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/MandorProject/$id'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return MandorProject.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal mengambil data project');
    }
  }

  Future<List<MandorProjectProject>> getProjectByMandor() async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/MandorProjectProject/byMandor'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => MandorProjectProject.fromJson(e)).toList();
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData.containsKey('message')
                ? "Error di API ${errorData['message']}"
                : 'Error ${response.statusCode}: ${response.reasonPhrase}';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception(
          'Unexpected error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }

  Future<List<MandorProjectProject>> getAllMandorProjectProject() async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/MandorProjectProject'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => MandorProjectProject.fromJson(e)).toList();
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData.containsKey('message')
                ? "Error di API ${errorData['message']}"
                : 'Error ${response.statusCode}: ${response.reasonPhrase}';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception(
          'Unexpected error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }

  Future<bool> tugaskanMandor(MandorProjectProject mpp) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/MandorProjectProject/assign'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(mpp.toCreateJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return true;
    }
    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage =
          errorData.containsKey('message')
              ? "Error di API ${errorData['message']}"
              : 'Error ${response.statusCode}: ${response.reasonPhrase}';
      throw Exception(errorMessage);
    } catch (_) {
      throw Exception(
        'Unexpected error ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<List<Laporan>> getAllLaporan() async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/Report/all'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Laporan.fromJson(e)).toList();
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData.containsKey('message')
                ? "Error di API ${errorData['message']}"
                : 'Error ${response.statusCode}: ${response.reasonPhrase}';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception(
          'Unexpected error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }

  Future<Laporan> getLaporanById(int id) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/Report/$id'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return Laporan.fromJson(json.decode(response.body));
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData.containsKey('message')
                ? "Error di API ${errorData['message']}"
                : 'Error ${response.statusCode}: ${response.reasonPhrase}';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception(
          'Unexpected error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }

  Future<List<Laporan>> getLaporanByProjectId(int id) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/Report/byProject/$id'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Laporan.fromJson(e)).toList();
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData.containsKey('message')
                ? "Error di API ${errorData['message']}"
                : 'Error ${response.statusCode}: ${response.reasonPhrase}';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception(
          'Unexpected error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }

  Future<bool> buatLaporan(Laporan laporan) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/Report/submit'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(laporan.toCreateJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return true;
    }
    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage =
          errorData.containsKey('message')
              ? "Error di API ${errorData['message']}"
              : 'Error ${response.statusCode}: ${response.reasonPhrase}';
      throw Exception(errorMessage);
    } catch (_) {
      throw Exception(
        'Unexpected error ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<bool> updateLaporan(Laporan laporan, int id) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .put(
          Uri.parse('$baseUrl/api/Report/edit/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(laporan.toUpdateJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return true;
    }
    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage =
          errorData.containsKey('message')
              ? "Error di API ${errorData['message']}"
              : 'Error ${response.statusCode}: ${response.reasonPhrase}';
      throw Exception(errorMessage);
    } catch (_) {
      throw Exception(
        'Unexpected error ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<List<Riwayat>> getAllRiwayat() async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/Riwayat/view'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Riwayat.fromJson(e)).toList();
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData.containsKey('message')
                ? "Error di API ${errorData['message']}"
                : 'Error ${response.statusCode}: ${response.reasonPhrase}';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception(
          'Unexpected error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }

  Future<bool> buatRiwayat(Riwayat riwayat) async {
    String? token = await SharedPreferencesServices.getString('token');
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/Riwayat/add-riwayat'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(riwayat.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return true;
    }
    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage =
          errorData.containsKey('message')
              ? "Error di API ${errorData['message']}"
              : 'Error ${response.statusCode}: ${response.reasonPhrase}';
      throw Exception(errorMessage);
    } catch (_) {
      throw Exception(
        'Unexpected error ${response.statusCode}: ${response.body}',
      );
    }
  }
}
