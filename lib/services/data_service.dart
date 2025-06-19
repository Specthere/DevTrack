// services/data_service.dart
import '../models/project_model.dart';
import '../models/report_model.dart';
import '../models/riwayat_model.dart';


class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Static data untuk projects
  final List<Project> _projects = [
    Project(
      projectId: 1,
      namaProject: "Pembangunan Jembatan Sungai Brantas",
      status: "aktif",
      lokasi: "Jember, Jawa Timur",
      deadline: "2025-12-31",
      deskripsi: "Proyek pembangunan jembatan dengan panjang 120 meter untuk menghubungkan dua sisi sungai Brantas. Meliputi konstruksi pondasi, struktur utama, dan akses jalan.",
      klien: "Dinas Pekerjaan Umum Jember",
    ),
    Project(
      projectId: 2,
      namaProject: "Renovasi Gedung Perkantoran",
      status: "tunda",
      lokasi: "Surabaya, Jawa Timur",
      deadline: "2025-10-15",
      deskripsi: "Renovasi total gedung perkantoran 5 lantai meliputi perbaikan struktur, sistem MEP, dan interior design modern.",
      klien: "PT. Maju Bersama",
    ),
    Project(
      projectId: 3,
      namaProject: "Konstruksi Rumah Sakit",
      status: "selesai",
      lokasi: "Malang, Jawa Timur",
      deadline: "2025-06-01",
      deskripsi: "Pembangunan rumah sakit tipe B dengan kapasitas 200 tempat tidur, dilengkapi fasilitas IGD, ICU, dan ruang operasi modern.",
      klien: "Yayasan Kesehatan Malang",
    ),
    Project(
      projectId: 4,
      namaProject: "Pembangunan Perumahan Cluster",
      status: "aktif",
      lokasi: "Banyuwangi, Jawa Timur",
      deadline: "2026-03-20",
      deskripsi: "Pengembangan perumahan cluster dengan 50 unit rumah tipe 36-70, fasilitas taman, dan akses jalan lingkungan.",
      klien: "PT. Griya Asri Developer",
    ),
    Project(
      projectId: 5,
      namaProject: "Infrastruktur Jalan Tol",
      status: "batal",
      lokasi: "Probolinggo, Jawa Timur",
      deadline: "2025-08-30",
      deskripsi: "Pembangunan akses jalan tol sepanjang 5 km dengan 2 interchange dan sistem drainase terintegrasi.",
      klien: "PT. Jasa Marga Regional",
    ),
  ];

  // Static data untuk reports (beberapa project sudah memiliki laporan)
  final List<Report> _reports = [
    Report(
      laporanId: 1,
      projectId: 1,
      tanggal: "2025-06-15T08:30:00.000Z",
      deskripsi: "Pekerjaan galian pondasi pier 1 dan pier 2 telah selesai. Kedalaman galian mencapai 8 meter sesuai spesifikasi.",
      material: "Semen Portland 50 ton, Besi beton D16-D25 total 15 ton, Agregat kasar 100 m³",
      jumlahPekerja: 25,
      kendala: "Cuaca hujan menyebabkan penundaan 2 hari",
      lokasi: "-8.1689, 113.7007",
      foto: null,
    ),
    Report(
      laporanId: 2,
      projectId: 1,
      tanggal: "2025-06-14T07:00:00.000Z",
      deskripsi: "Pemasangan bekisting untuk abutment kiri jembatan. Pemeriksaan elevasi dan alignment telah sesuai gambar kerja.",
      material: "Kayu bekisting 15 m³, Kawat bendrat 50 kg, Minyak bekisting 20 liter",
      jumlahPekerja: 18,
      kendala: null,
      lokasi: "-8.1689, 113.7007",
      foto: null,
    ),
    Report(
      laporanId: 3,
      projectId: 3,
      tanggal: "2025-05-28T09:15:00.000Z",
      deskripsi: "Pekerjaan finishing interior ruang ICU lantai 3. Pemasangan medical gas pipeline dan instalasi listrik khusus.",
      material: "Pipa copper medical gas 200 m, Panel listrik medical grade 5 unit, Lampu LED operasi 12 unit",
      jumlahPekerja: 12,
      kendala: "Keterlambatan pengiriman peralatan medical gas 1 minggu",
      lokasi: "-7.9797, 112.6304",
      foto: null,
    ),
    Report(
      laporanId: 4,
      projectId: 4,
      tanggal: "2025-06-16T06:45:00.000Z",
      deskripsi: "Pengecoran pondasi rumah tipe 45 blok A1-A5. Total 5 unit rumah dalam tahap pondasi.",
      material: "Beton ready mix K-250 sebanyak 75 m³, Besi beton D12-D16 total 8 ton",
      jumlahPekerja: 20,
      kendala: null,
      lokasi: "-8.2194, 114.3691",
      foto: null,
    ),
  ];

  // Methods untuk Project
  List<Project> getAllProjects() {
    return List.from(_projects);
  }

  Project? getProjectById(int projectId) {
    try {
      return _projects.firstWhere((project) => project.projectId == projectId);
    } catch (e) {
      return null;
    }
  }

  List<Project> getProjectsByStatus(String status) {
    return _projects.where((project) => project.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Methods untuk Report
  List<Report> getAllReports() {
    return List.from(_reports);
  }

  List<Report> getReportsByProjectId(int projectId) {
    return _reports.where((report) => report.projectId == projectId).toList();
  }

  Report? getReportById(int reportId) {
    try {
      return _reports.firstWhere((report) => report.laporanId == reportId);
    } catch (e) {
      return null;
    }
  }

  // Method untuk menambah laporan baru
  bool addReport(Report report) {
    try {
      // Generate ID baru
      int newId = _reports.isEmpty ? 1 : _reports.map((r) => r.laporanId).reduce((a, b) => a > b ? a : b) + 1;
      
      Report newReport = Report(
        laporanId: newId,
        projectId: report.projectId,
        tanggal: report.tanggal,
        deskripsi: report.deskripsi,
        material: report.material,
        jumlahPekerja: report.jumlahPekerja,
        kendala: report.kendala,
        foto: report.foto,
        lokasi: report.lokasi,
      );
      
      _reports.add(newReport);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Method untuk menghitung statistik
  Map<String, int> getProjectStatistics() {
    Map<String, int> stats = {
      'total': _projects.length,
      'aktif': 0,
      'selesai': 0,
      'tunda': 0,
      'batal': 0,
    };

    for (var project in _projects) {
      String status = project.status.toLowerCase();
      if (stats.containsKey(status)) {
        stats[status] = stats[status]! + 1;
      }
    }

    return stats;
  }

  // Method untuk mendapatkan laporan terbaru
  List<Report> getRecentReports([int limit = 5]) {
    List<Report> sortedReports = List.from(_reports);
    sortedReports.sort((a, b) => DateTime.parse(b.tanggal).compareTo(DateTime.parse(a.tanggal)));
    return sortedReports.take(limit).toList();
  }
    

    static final List<Map<String, dynamic>> _completedProjectsData = [
    {
      'project_id': 101,
      'nama_project': 'Pembangunan Rumah Tipe 36',
      'lokasi': 'Jl. Mawar No. 15, Surabaya',
      'deadline': '2024-12-15',
      'tanggal_selesai': '2024-12-10',
      'catatan': 'Proyek selesai tepat waktu dengan kualitas excellent. Semua spesifikasi telah terpenuhi.',
      'foto': null,
      'mandor_id': 1,
      'klien': 'Budi Santoso',
      'deskripsi': 'Pembangunan rumah tipe 36 dengan spesifikasi modern',
    },
    {
      'project_id': 102,
      'nama_project': 'Renovasi Kantor PT. Sejahtera',
      'lokasi': 'Jl. HR Muhammad No. 45, Surabaya',
      'deadline': '2024-11-30',
      'tanggal_selesai': '2024-11-28',
      'catatan': 'Renovasi lantai 2 dan 3 berhasil diselesaikan. Klien sangat puas dengan hasil.',
      'foto': null,
      'mandor_id': 1,
      'klien': 'PT. Sejahtera Abadi',
      'deskripsi': 'Renovasi kantor lantai 2 dan 3 dengan desain modern',
    },
    {
      'project_id': 103,
      'nama_project': 'Konstruksi Gudang Logistik',
      'lokasi': 'Kawasan Industri Rungkut, Surabaya',
      'deadline': '2024-10-20',
      'tanggal_selesai': '2024-10-18',
      'catatan': 'Gudang dengan luas 500m² berhasil dibangun dengan sistem keamanan modern.',
      'foto': null,
      'mandor_id': 1,
      'klien': 'CV. Logistik Prima',
      'deskripsi': 'Pembangunan gudang logistik dengan sistem keamanan terintegrasi',
    },
    {
      'project_id': 104,
      'nama_project': 'Pembangunan Toko Modern',
      'lokasi': 'Jl. Diponegoro No. 88, Surabaya',
      'deadline': '2024-09-15',
      'tanggal_selesai': '2024-09-12',
      'catatan': 'Toko 2 lantai dengan desain modern dan sistem AC sentral.',
      'foto': null,
      'mandor_id': 2,
      'klien': 'Sari Dewi',
      'deskripsi': 'Pembangunan toko modern 2 lantai dengan fasilitas lengkap',
    },
    {
      'project_id': 105,
      'nama_project': 'Renovasi Rumah Mewah',
      'lokasi': 'Jl. Dharmahusada Indah No. 12, Surabaya',
      'deadline': '2024-08-25',
      'tanggal_selesai': '2024-08-20',
      'catatan': 'Renovasi total dengan tambahan kolam renang dan taman.',
      'foto': null,
      'mandor_id': 1,
      'klien': 'Ahmad Wijaya',
      'deskripsi': 'Renovasi rumah mewah dengan tambahan fasilitas kolam renang',
    },
    {
      'project_id': 106,
      'nama_project': 'Pembangunan Sekolah Dasar',
      'lokasi': 'Jl. Pendidikan No. 25, Surabaya',
      'deadline': '2024-07-30',
      'tanggal_selesai': '2024-07-28',
      'catatan': 'Pembangunan 6 ruang kelas dengan fasilitas laboratorium dan perpustakaan.',
      'foto': null,
      'mandor_id': 2,
      'klien': 'Yayasan Pendidikan Harapan',
      'deskripsi': 'Pembangunan gedung sekolah dasar dengan fasilitas lengkap',
    },
    {
      'project_id': 107,
      'nama_project': 'Renovasi Masjid Al-Hidayah',
      'lokasi': 'Jl. Masjid Raya No. 10, Surabaya',
      'deadline': '2024-06-20',
      'tanggal_selesai': '2024-06-18',
      'catatan': 'Renovasi total masjid dengan penambahan mihrab dan sound system.',
      'foto': null,
      'mandor_id': 1,
      'klien': 'Takmir Masjid Al-Hidayah',
      'deskripsi': 'Renovasi masjid dengan penambahan fasilitas modern',
    },
  ];

  Future<List<RiwayatProject>> getCompletedProjectsByMandor(int mandorId) async {
    // Simulasi loading time
    await Future.delayed(const Duration(seconds: 1));
    
    // Filter berdasarkan mandor_id
    final filteredData = _completedProjectsData
        .where((project) => project['mandor_id'] == mandorId)
        .toList();
    
    return filteredData.map((data) => RiwayatProject.fromJson(data)).toList();
  }

  Future<List<RiwayatProject>> getAllCompletedProjects() async {
    // Simulasi loading time
    await Future.delayed(const Duration(seconds: 1));
    
    return _completedProjectsData.map((data) => RiwayatProject.fromJson(data)).toList();
  }

  RiwayatProject? getCompletedProjectById(int projectId) {
    try {
      final data = _completedProjectsData.firstWhere(
        (project) => project['project_id'] == projectId,
      );
      return RiwayatProject.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Map<String, int> getRiwayatStatistics(int mandorId) {
    final userProjects = _completedProjectsData
        .where((project) => project['mandor_id'] == mandorId)
        .toList();
    
    return {
      'total_completed': userProjects.length,
      'this_month': userProjects.where((project) {
        try {
          final completedDate = DateTime.parse(project['tanggal_selesai']);
          final now = DateTime.now();
          return completedDate.year == now.year && completedDate.month == now.month;
        } catch (e) {
          return false;
        }
      }).length,
    };
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
