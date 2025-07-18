// services/data_service.dart
import '../models/project_model.dart';
import '../models/laporan.dart';
import '../models/riwayat.dart';


class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Static data untuk projects
  final List<ProjectModel> _projects = [
    ProjectModel(
      projectId: 1,
      namaProject: "Pembangunan Jembatan Sungai Brantas",
      status: "aktif",
      lokasi: "Jember, Jawa Timur",
      deadline: DateTime(2025, 12, 15),
      foto: "https://source.unsplash.com/1600x900/?jembatan,brantas,indonesia",
    ),
    ProjectModel(
      projectId: 2,
      namaProject: "Renovasi Gedung Perkantoran",
      status: "tunda",
      lokasi: "Surabaya, Jawa Timur",
      deadline: DateTime(2024, 9, 30),
      foto: "https://source.unsplash.com/1600x900/?gedung,renovasi,indonesia",
    ),
    ProjectModel(
      projectId: 3,
      namaProject: "Konstruksi Rumah Sakit",
      status: "selesai",
      lokasi: "Malang, Jawa Timur",
      deadline: DateTime(2023, 6, 10),
      foto: "https://source.unsplash.com/1600x900/?rumah,sakit,indonesia",
    ),
  ];

  // Static data untuk reports (beberapa project sudah memiliki laporan)

  // Methods untuk ProjectModel
  List<ProjectModel> getAllProjects() {
    return List.from(_projects);
  }

  ProjectModel? getProjectById(int projectId) {
    try {
      return _projects.firstWhere((project) => project.projectId == projectId);
    } catch (e) {
      return null;
    }
  }

  List<ProjectModel> getProjectsByStatus(String status) {
    return _projects.where((project) => project.status.toLowerCase() == status.toLowerCase()).toList();
  }

  List<ProjectModel> getCompletedProjectsByMandor(int mandorId) {
    return _projects.where((project) => project.status.toLowerCase() == 'selesai').toList();
  }

  // Methods untuk Laporan

  // Method untuk menambah laporan baru
  

  // Method untuk mendapatkan laporan terbaru
    

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
