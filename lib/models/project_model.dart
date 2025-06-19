// models/project_model.dart
class Project {
  final int projectId;
  final String namaProject;
  final String status;
  final String lokasi;
  final String deadline;
  final String deskripsi;
  final String klien;

  Project({
    required this.projectId,
    required this.namaProject,
    required this.status,
    required this.lokasi,
    required this.deadline,
    required this.deskripsi,
    required this.klien,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['project_id'],
      namaProject: json['nama_project'],
      status: json['status'],
      lokasi: json['lokasi'],
      deadline: json['deadline'],
      deskripsi: json['deskripsi'],
      klien: json['klien'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'nama_project': namaProject,
      'status': status,
      'lokasi': lokasi,
      'deadline': deadline,
      'deskripsi': deskripsi,
      'klien': klien,
    };
  }
}

