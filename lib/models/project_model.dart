class ProjectModel {
  final int? projectId;
  final String namaProject;
  final String lokasi;
  final DateTime deadline;
  final String status;
  final String? foto;

  ProjectModel({
    this.projectId,
    required this.namaProject,
    required this.lokasi,
    required this.deadline,
    required this.status,
    this.foto,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: json['projectId'],
      namaProject: json['namaProject'],
      lokasi: json['lokasi'],
      deadline: DateTime.parse(json['deadline']).toLocal(),
      status: json['status'],
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProjectId': projectId,
      'NamaProject': namaProject,
      'Lokasi': lokasi,
      'Deadline': deadline.toUtc().toIso8601String(),
      'Status': status,
      'Foto': foto,
    };
  }

  Map<String, dynamic> toCreateJson() {
    final deadlineAtNoon = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      12,
    );
    return {
      'NamaProject': namaProject,
      'Lokasi': lokasi,
      'Deadline': deadlineAtNoon.toUtc().toIso8601String(),
      'Status': status,
      'Foto': foto,
    };
  }
}
