import 'package:tracedev/view/monitoring_proyek.dart';

class Riwayat {
  final int? riwayatId;
  final DateTime? tanggalSelesai;
  final String? catatan;
  final int projectId;
  final Project? project;

  Riwayat({
    this.riwayatId,
    this.tanggalSelesai,
    this.catatan,
    required this.projectId,
    this.project,
  });

  factory Riwayat.fromJson(Map<String, dynamic> json) {
    return Riwayat(
      riwayatId: json['riwayatId'],
      tanggalSelesai: DateTime.parse(json['tanggalSelesai']),
      catatan: json['catatan'],
      projectId: json['projectId'],
      project: json['project'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggalSelesai': DateTime.now().toUtc().toIso8601String(),
      'catatan': catatan,
      'projectId': projectId,
    };
  }
}
