import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:tracedev/controller/project_controller.dart';
import 'package:tracedev/models/project_model.dart';
import 'package:tracedev/view/laporan_page.dart';

class MonitoringProyek extends StatefulWidget {
  const MonitoringProyek({super.key});

  @override
  State<MonitoringProyek> createState() => _MonitoringProyekState();
}

class _MonitoringProyekState extends State<MonitoringProyek>
    with TickerProviderStateMixin {
  String selectedFilter = 'Semua';
  String searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ProjectController projectController;
  bool isLoading = false;

  final List<String> filters = [
    'Semua',
    'Berjalan',
    'Selesai',
    'Tertunda',
    'Dibatalkan',
  ];

  // Data dummy untuk contoh
  List<ProjectModel> projects = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    projectController = ProjectController();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      isLoading = true;
    });

    try {
      await projectController.getAllProjects();
      setState(() {
        projects = projectController.projects;
      });
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

  Future<String> getCityFromStringCoords(String koordinat) async {
    await projectController.getProjectLocation();
    return projectController.projectLocation[koordinat] ?? "Tidak ditemukan";
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<ProjectModel> get filteredProjects {
    List<ProjectModel> filtered = projects;
    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered.where((project) {
            return project.namaProject.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                project.lokasi.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
          }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadProjects,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFF249EC0),
            title: const Text(
              'Monitoring Proyek',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
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
                              hintText: 'Cari proyek, atau lokasi',
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
                Expanded(
                  child:
                      filteredProjects.isEmpty
                          ? _buildEmptyState()
                          : isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filteredProjects.length,
                            itemBuilder: (context, index) {
                              return _buildProjectCard(
                                filteredProjects[index],
                                index,
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project, int index) {
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
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => LaporanPage(
                              projectId: project.projectId!,
                              projectLocation: project.lokasi,
                            ),
                      ),
                    ),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with thumbnail and status
                      Row(
                        children: [
                          // Thumbnail placeholder
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _getStatusColor(project).withOpacity(0.1),
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
                              _formatDeadline(project.deadline),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
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

  Color _getStatusColor(ProjectModel project) {
    switch (project.status) {
      case "Sedang Berjalan":
        return Colors.green;
      case "Selesai":
        return Colors.blue;
      case "Dibatalkan":
        return Colors.red;
    }
    return Colors.grey;
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;

    if (difference < 0) {
      return '${difference.abs()} hari lalu';
    } else if (difference == 0) {
      return 'Hari ini';
    } else {
      return '$difference hari lagi';
    }
  }
}

// Model classes
enum ProjectStatus { berjalan, selesai, tertunda, dibatalkan }

class Project {
  final String id;
  final String name;
  final String thumbnail;
  final ProjectStatus status;
  final String location;
  final DateTime deadline;
  final double progress;
  final String budget;
  final String contractor;

  Project({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.status,
    required this.location,
    required this.deadline,
    required this.progress,
    required this.budget,
    required this.contractor,
  });
}
