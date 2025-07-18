import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tracedev/controller/laporan_controller.dart';
import 'package:tracedev/controller/mandor_project_project_controller.dart';
import 'package:tracedev/controller/project_controller.dart';
import 'package:tracedev/controller/riwayat_controller.dart';
import 'package:tracedev/models/mandor_project_project.dart';
import 'package:tracedev/models/riwayat.dart';
import 'package:tracedev/view/laporan_page.dart';

class RiwayatProyek extends StatefulWidget {
  const RiwayatProyek({super.key});

  @override
  State<RiwayatProyek> createState() => _RiwayatProyekState();
}

class _RiwayatProyekState extends State<RiwayatProyek> {
  final TextEditingController _searchController = TextEditingController();
  String? lokasi;
  String _searchQuery = '';
  String _sortOrder = 'terbaru'; // 'terbaru' atau 'terlama'

  final Map<String, String> _locationCache = {};
  final Map<String, Future<String>> _locationFutures = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _getLocationWithCache(String koordinat) {
    if (_locationCache.containsKey(koordinat)) {
      return Future.value(_locationCache[koordinat]!);
    }

    if (_locationFutures.containsKey(koordinat)) {
      return _locationFutures[koordinat]!;
    }

    final future = MandorProjectProjectController.getCityFromStringCoords(
          koordinat,
        )
        .then((location) {
          _locationCache[koordinat] = location ?? 'Lokasi tidak diketahui';
          _locationFutures.remove(koordinat);
          return _locationCache[koordinat]!;
        })
        .catchError((error) {
          _locationCache[koordinat] = 'Gagal memuat lokasi';
          _locationFutures.remove(koordinat);
          return _locationCache[koordinat]!;
        });

    _locationFutures[koordinat] = future;
    return future;
  }

  Future<void> _loadData() async {
    final riwayatController = context.read<RiwayatController>();
    final projectController = context.read<ProjectController>();
    final mandorProjectController =
        context.read<MandorProjectProjectController>();

    await Future.wait([
      riwayatController.getAllRiwayat(),
      mandorProjectController.getProjectByMandor(),
      mandorProjectController.getAllMandorProjectProject(),
    ]);
    print("mandor: ${mandorProjectController.allMandor.length}");

    await projectController.getProjectLocation();
  }

  List<Riwayat> _getFilteredAndSortedRiwayat(
    List<Riwayat> riwayats,
    List<MandorProjectProject> projects,
  ) {
    // Filter berdasarkan search query
    List<Riwayat> filtered =
        riwayats.where((riwayat) {
          if (_searchQuery.isEmpty) return true;

          final project = _findProjectById(projects, riwayat.projectId);
          final projectName = project?.project?.namaProject.toLowerCase() ?? '';

          return projectName.contains(_searchQuery.toLowerCase());
        }).toList();

    // Sort berdasarkan tanggal selesai
    filtered.sort((a, b) {
      if (a.tanggalSelesai == null && b.tanggalSelesai == null) return 0;
      if (a.tanggalSelesai == null) return 1;
      if (b.tanggalSelesai == null) return -1;

      if (_sortOrder == 'terbaru') {
        return b.tanggalSelesai!.compareTo(a.tanggalSelesai!);
      } else {
        return a.tanggalSelesai!.compareTo(b.tanggalSelesai!);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Riwayat Proyek',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xFF249EC0),
        elevation: 0,
      ),
      body: Consumer4<
        RiwayatController,
        ProjectController,
        MandorProjectProjectController,
        LaporanController
      >(
        builder: (
          context,
          riwayatController,
          projectController,
          mandorController,
          laporanController,
          child,
        ) {
          if (riwayatController.isLoading ||
              projectController.isLoading ||
              mandorController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (riwayatController.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${riwayatController.errorMessage}',
                    style: TextStyle(color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (riwayatController.riwayats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat proyek',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final filteredRiwayats = _getFilteredAndSortedRiwayat(
            riwayatController.riwayats,
            mandorController.mandorProjectProjects,
          );

          return Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF249EC0),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari riwayat proyek, atau lokasi',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[400],
                            ),
                            suffixIcon:
                                _searchQuery.isNotEmpty
                                    ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.grey[400],
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                    : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sort, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text(
                      'Urutkan:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          _buildFilterChip('Terbaru', 'terbaru'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Terlama', 'terlama'),
                        ],
                      ),
                    ),
                    Text(
                      '${filteredRiwayats.length} proyek',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child:
                      filteredRiwayats.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada proyek yang sesuai',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredRiwayats.length,
                            itemBuilder: (context, index) {
                              final riwayat = filteredRiwayats[index];
                              final project = _findProjectById(
                                mandorController.mandorProjectProjects,
                                riwayat.projectId,
                              );
                              final mandors = _findMandorsByProjectId(
                                mandorController.allMandor,
                                riwayat.projectId,
                              );

                              return _buildEnhancedRiwayatCard(
                                context,
                                riwayat,
                                project,
                                mandors,
                                mandorController,
                              );
                            },
                          ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _sortOrder == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortOrder = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF249EC0) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  MandorProjectProject? _findProjectById(
    List<MandorProjectProject> projects,
    int projectId,
  ) {
    try {
      return projects.firstWhere((project) => project.projectId == projectId);
    } catch (e) {
      return null;
    }
  }

  List<String> _findMandorsByProjectId(
    List<MandorProjectProject> mandorProjects,
    int projectId,
  ) {
    return mandorProjects
        .where((mp) => mp.projectId == projectId)
        .map((mp) => mp.mandorProject?.users?.nama ?? 'Mandor Tidak Diketahui')
        .toList();
  }

  Widget _buildEnhancedRiwayatCard(
    BuildContext context,
    Riwayat riwayat,
    MandorProjectProject? project,
    List<String> mandors,
    MandorProjectProjectController mandorController,
  ) {
    return GestureDetector(
      onTap: () => _showDetailDialog(context, riwayat, project, mandors),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // Header dengan gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'PROYEK SELESAI',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      if (riwayat.tanggalSelesai != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            DateFormat(
                              'dd MMM yyyy',
                            ).format(riwayat.tanggalSelesai!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Body content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Project Image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              project?.project?.foto != null
                                  ? Image.network(
                                    project!.project!.foto!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 32,
                                          color: Colors.grey[400],
                                        ),
                                      );
                                    },
                                  )
                                  : Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.apartment,
                                      size: 32,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Project Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Project Name
                            Text(
                              project?.project?.namaProject ??
                                  'Proyek Tidak Diketahui',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Location
                            if (project != null)
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.red[400],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: FutureBuilder(
                                      future: _getLocationWithCache(
                                        project.project!.lokasi,
                                      ),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data ?? 'Memuat lokasi...',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            // Mandor
                            if (mandors.isNotEmpty)
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.blue[400],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Mandor: ${mandors.join(', ')}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      // Arrow indicator
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(
    BuildContext context,
    Riwayat riwayat,
    MandorProjectProject? project,
    List<String> mandors,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight:
                  MediaQuery.of(context).size.height *
                  0.9, // Limit dialog height
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header - Fixed at top
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.assignment_turned_in,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Detail Riwayat Proyek',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project Image with constrained height
                        if (project?.project?.foto != null)
                          Center(
                            child: Container(
                              width: double.infinity,
                              height: 160, // Reduced height to prevent overflow
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  project!.project!.foto!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        // Project Details
                        _buildDetailRow(
                          Icons.apartment,
                          'Nama Proyek',
                          project?.project?.namaProject ?? 'Tidak Diketahui',
                          Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.location_on,
                          'Lokasi',
                          null,
                          Colors.red,
                          child: FutureBuilder<String>(
                            future:
                                project != null
                                    ? _getLocationWithCache(
                                      project.project!.lokasi,
                                    )
                                    : Future.value('Tidak Diketahui'),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? 'Memuat...',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.person,
                          'Mandor',
                          mandors.isNotEmpty ? mandors.join(', ') : 'Tidak Ada',
                          Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Tanggal Selesai',
                          riwayat.tanggalSelesai != null
                              ? DateFormat(
                                'dd MMMM yyyy, HH:mm',
                              ).format(riwayat.tanggalSelesai!)
                              : 'Tidak Diketahui',
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.event_available,
                          'Status',
                          project?.project?.status ?? 'Tidak Diketahui',
                          Colors.purple,
                        ),
                        if (riwayat.catatan != null &&
                            riwayat.catatan!.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.note_alt,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Catatan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Constrain the notes text to prevent overflow
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 100, // Limit notes height
                                  ),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      riwayat.catatan!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              String? alamatProject;
                              if (project?.project?.lokasi != null) {
                                alamatProject =
                                    _locationCache[project!.project!.lokasi];
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => LaporanPage(
                                        projectId: project?.projectId ?? 0,
                                        projectLocation:
                                            project?.project?.lokasi ?? '',
                                        alamatProject: alamatProject,
                                      ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.description,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Lihat Laporan Proyek',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF249EC0),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        // Add some bottom padding for better scrolling experience
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Updated _buildDetailRow to handle long text better
  Widget _buildDetailRow(
    IconData icon,
    String label,
    String? value,
    Color color, {
    Widget? child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              child ??
                  Text(
                    value ?? 'Tidak Diketahui',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3, // Limit lines to prevent overflow
                    overflow: TextOverflow.ellipsis,
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
