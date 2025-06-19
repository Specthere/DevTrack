class RiwayatProject {
  final int projectId;
  final String namaProject;
  final String lokasi;
  final String deadline;
  final String tanggalSelesai;
  final String? catatan;
  final String? foto;
  final int mandorId;
  final String klien;
  final String deskripsi;

  RiwayatProject({
    required this.projectId,
    required this.namaProject,
    required this.lokasi,
    required this.deadline,
    required this.tanggalSelesai,
    this.catatan,
    this.foto,
    required this.mandorId,
    required this.klien,
    required this.deskripsi,
  });

  factory RiwayatProject.fromJson(Map<String, dynamic> json) {
    return RiwayatProject(
      projectId: json['project_id'] ?? 0,
      namaProject: json['nama_project'] ?? '',
      lokasi: json['lokasi'] ?? '',
      deadline: json['deadline'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
      catatan: json['catatan'],
      foto: json['foto'],
      mandorId: json['mandor_id'] ?? 0,
      klien: json['klien'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'nama_project': namaProject,
      'lokasi': lokasi,
      'deadline': deadline,
      'tanggal_selesai': tanggalSelesai,
      'catatan': catatan,
      'foto': foto,
      'mandor_id': mandorId,
      'klien': klien,
      'deskripsi': deskripsi,
    };
  }
}