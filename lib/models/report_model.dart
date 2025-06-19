// models/report_model.dart
class Report {
  final int laporanId;
  final int projectId;
  final String tanggal;
  final String deskripsi;
  final String material;
  final int jumlahPekerja;
  final String? kendala;
  final String? foto;
  final String lokasi;

  Report({
    required this.laporanId,
    required this.projectId,
    required this.tanggal,
    required this.deskripsi,
    required this.material,
    required this.jumlahPekerja,
    this.kendala,
    this.foto,
    required this.lokasi,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      laporanId: json['laporan_id'],
      projectId: json['project_id'],
      tanggal: json['tanggal'],
      deskripsi: json['deskripsi'],
      material: json['material'],
      jumlahPekerja: json['jumlah_pekerja'],
      kendala: json['kendala'],
      foto: json['foto'],
      lokasi: json['lokasi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'laporan_id': laporanId,
      'project_id': projectId,
      'tanggal': tanggal,
      'deskripsi': deskripsi,
      'material': material,
      'jumlah_pekerja': jumlahPekerja,
      'kendala': kendala,
      'foto': foto,
      'lokasi': lokasi,
    };
  }
}