import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:tracedev/controller/project_controller.dart';
import 'package:tracedev/models/project_model.dart';
import 'package:tracedev/view/edit_proyek.dart';
import 'package:tracedev/view/tambah_projek.dart';
import 'package:tracedev/view/tugaskan_mandor.dart';
import 'package:tracedev/widget/detail_proyek.dart';
import 'package:intl/intl.dart';

class DashboardDev extends StatefulWidget {
  const DashboardDev({super.key});

  @override
  State<DashboardDev> createState() => _DashboardDevState();
}

class _DashboardDevState extends State<DashboardDev>
    with TickerProviderStateMixin {
  String selectedFilter = 'Semua';
  String searchQuery = '';
  late ProjectController projectController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<ProjectModel> filteredProjects = [];
  bool isLoading = false;

  final List<String> filters = [
    'Semua',
    'Sedang Berjalan',
    'Selesai',
    'Belum Mulai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    projectController = ProjectController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      isLoading = true;
    });

    try {
      await projectController.getAllProjects();
      setState(() {
        filteredProjects = projectController.projects;
      });
      print("Filtered Project: ${filteredProjects.length}");
    } catch (e) {
      print("Error loading projects: $e");
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data proyek: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshProjects() async {
    await _loadProjects();
  }

  Future<String> getCityFromStringCoords(String koordinat) async {
    await projectController.getProjectLocation();
    return projectController.projectLocation[koordinat] ?? "Tidak ditemukan";
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<ProjectModel> get filteredProyek {
    List<ProjectModel> filtered = filteredProjects;
    final listLokasi = projectController.projectLocation;

    // Filter by status
    if (selectedFilter != 'Semua') {
      filtered =
          filtered.where((project) {
            switch (selectedFilter) {
              case 'Sedang Berjalan':
                return project.status == "Sedang Berjalan";
              case 'Selesai':
                return project.status == "Selesai";
              case 'Belum Mulai':
                return project.status == "Belum Mulai";
              case 'Dibatalkan':
                return project.status == "Dibatalkan";
              default:
                return true;
            }
          }).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered.where((project) {
            final lokasi = listLokasi[project.lokasi]?.toLowerCase() ?? '';
            return project.namaProject.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                lokasi.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF249EC0),
          title: const Text(
            'Manajemen Proyek',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _refreshProjects,
          color: const Color(0xFF249EC0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header with stats
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
                      // Stats cards
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Proyek',
                                projectController.projects.length.toString(),
                                Icons.assignment,
                                Colors.white,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildStatCard(
                                'Sedang Berjalan',
                                projectController.projects
                                    .where((p) => p.status == "Sedang Berjalan")
                                    .length
                                    .toString(),
                                Icons.play_circle,
                                Colors.green[100]!,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildStatCard(
                                'Selesai',
                                projectController.projects
                                    .where((p) => p.status == "Selesai")
                                    .length
                                    .toString(),
                                Icons.check_circle,
                                Colors.blue[100]!,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Search bar
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
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari nama proyek atau lokasi',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Filter chips
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filters.length,
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: FilterChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : const Color(0xFF249EC0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF249EC0),
                          checkmarkColor: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.black26,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Projects list
                Expanded(
                  child:
                      isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF249EC0),
                            ),
                          )
                          : filteredProjects.isEmpty
                          ? _buildEmptyState()
                          : filteredProyek.isEmpty
                          ? _buildNoResultsState()
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filteredProyek.length,
                            itemBuilder: (context, index) {
                              var project = filteredProyek[index];
                              print("Project: $project");
                              return _buildProjectCard(project, index);
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.pushNamed(context, TambahProjek.routeName);
            // Refresh data after adding new project
            _refreshProjects();
          },
          backgroundColor: const Color(0xFF249EC0),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Tambah Proyek',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF249EC0), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF249EC0),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project, int index) {
    String formatTanggal(DateTime date) {
      return DateFormat('yyyy-MM-dd').format(date); // contoh: 2025-06-02
    }

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () async {
                  final kecamatan = await getCityFromStringCoords(
                    project.lokasi,
                  );
                  showDialog(
                    context: context,
                    builder:
                        (_) => DetailProyek(
                          id: project.projectId!,
                          title: project.namaProject,
                          lokasi: kecamatan,
                          status: project.status,
                          deadline: formatTanggal(project.deadline),
                          imageUrl: project.foto ?? '',
                        ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                project.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                project.foto ?? '',
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color: Colors.grey,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.white,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.namaProject,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          _buildStatusBadge(project.status),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: FutureBuilder<String>(
                              future: getCityFromStringCoords(project.lokasi),
                              builder:
                                  (context, snapshot) => _buildInfoItem(
                                    Icons.location_on_outlined,
                                    'Lokasi',
                                    snapshot.data ?? '-',
                                  ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildInfoItem(
                              Icons.schedule_outlined,
                              'Deadline',
                              formatTanggal(project.deadline),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Budget and action button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Text(
                          //       'Anggaran',
                          //       style: TextStyle(
                          //         fontSize: 12,
                          //         color: Colors.grey[600],
                          //       ),
                          //     ),
                          //     Text(
                          //       project.budget,
                          //       style: const TextStyle(
                          //         fontSize: 14,
                          //         fontWeight: FontWeight.bold,
                          //         color: Color(0xFF249EC0),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    String text = status;
    Color color = Colors.grey;

    switch (status) {
      case "Sedang Berjalan":
        color = Colors.green;
        break;
      case "Selesai":
        color = Colors.blue;
        break;
      case "Dibatalkan":
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Belum ada proyek',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tambahkan proyek pertama Anda',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _refreshProjects,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF249EC0),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Tidak ada proyek ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Coba ubah filter atau kata kunci pencarian',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Sedang Berjalan":
        return Colors.green;
      case "Selesai":
        return Colors.blue;
      case "Dibatalkan":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
