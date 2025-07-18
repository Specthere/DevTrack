import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tracedev/controller/mandor_project_controller.dart';
import 'package:tracedev/models/mandor_project.dart';
import 'package:tracedev/services/shared_preferences_services.dart';
import 'package:tracedev/view/buat_laporan.dart';
import 'package:tracedev/widget/detail_laporan.dart';
import '../models/project_model.dart';
import '../models/laporan.dart';
import '../controller/laporan_controller.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectModel project;
  final String? lokasi;

  const ProjectDetailPage({super.key, required this.project, this.lokasi});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLaporanData();
  }

  Future<void> _loadLaporanData() async {
    final laporanController = Provider.of<LaporanController>(
      context,
      listen: false,
    );
    await laporanController.getLaporanByProjectId(widget.project.projectId!);
  }

  Future<void> _refreshReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _loadLaporanData();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  LatLng? _parseLocation(String location) {
    if (location.isEmpty) return null;

    try {
      final coords = location.split(',');
      final lat = double.parse(coords[0].trim());
      final lng = double.parse(coords[1].trim());
      return LatLng(lat, lng);
    } catch (e) {
      debugPrint('Error parsing location: $e');
      return null;
    }
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth radius in kilometers

    double lat1Rad = point1.latitude * (pi / 180);
    double lat2Rad = point2.latitude * (pi / 180);
    double deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    double deltaLngRad = (point2.longitude - point1.longitude) * (pi / 180);

    double a =
        sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLngRad / 2) *
            sin(deltaLngRad / 2);

    double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  // Format distance for display
  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    } else {
      return '${distanceKm.toStringAsFixed(2)} km';
    }
  }

  // Show map in full screen dialog with project location comparison
  void _showMapDialog(
    String location,
    String title, {
    bool isReportLocation = false,
  }) {
    final coordinates = _parseLocation(location);
    if (coordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi tidak valid atau tidak dapat ditampilkan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final projectCoordinates = _parseLocation(widget.project.lokasi);
    double? distance;
    LatLng centerPoint = coordinates;

    if (isReportLocation && projectCoordinates != null) {
      distance = _calculateDistance(coordinates, projectCoordinates);

      double centerLat =
          (coordinates.latitude + projectCoordinates.latitude) / 2;
      double centerLng =
          (coordinates.longitude + projectCoordinates.longitude) / 2;
      centerPoint = LatLng(centerLat, centerLng);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1CA5B8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (distance != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Jarak dari lokasi proyek: ${_formatDistance(distance)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Map
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: centerPoint,
                      initialZoom:
                          distance != null && distance > 1 ? 12.0 : 15.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      if (isReportLocation && projectCoordinates != null)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [projectCoordinates, coordinates],
                              strokeWidth: 3.0,
                              color: const Color(0xFF1CA5B8),
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 100,
                            height: 100,
                            point: coordinates,
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          isReportLocation
                                              ? Colors.blue
                                              : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isReportLocation ? 'Laporan' : 'Proyek',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.location_pin,
                                    color:
                                        isReportLocation
                                            ? Colors.blue
                                            : Colors.red,
                                    size: 40,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isReportLocation && projectCoordinates != null)
                            Marker(
                              width: 100,
                              height: 100,
                              point: projectCoordinates,
                              child: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Proyek',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Footer with location info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current location info
                      Row(
                        children: [
                          Icon(
                            isReportLocation
                                ? Icons.description
                                : Icons.location_on,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      // Project location info (if showing report location)
                      if (isReportLocation && widget.lokasi != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.business,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Proyek: ${widget.lokasi}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Distance info
                      if (distance != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1CA5B8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF1CA5B8).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.straighten,
                                size: 16,
                                color: Color(0xFF1CA5B8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Jarak: ${_formatDistance(distance)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1CA5B8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sedang berjalan':
        return Colors.green;
      case 'selesai':
        return Colors.blue;
      case 'tertunda':
        return Colors.orange;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'ongoing':
        return Icons.play_circle_fill;
      case 'selesai':
      case 'completed':
        return Icons.check_circle;
      case 'tunda':
      case 'paused':
        return Icons.pause_circle_filled;
      case 'batal':
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return '${date.day}/${date.month}/${date.year}: ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _navigateToCreateReport() async {
    int? userId = await SharedPreferencesServices.getInt('userId');
    final MandorProjectController mandorProjectController =
        Provider.of<MandorProjectController>(context, listen: false);
    await mandorProjectController.getMandorProjectById(userId!);
    if (mandorProjectController.mandorProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda belum terdaftar sebagai mandor proyek ini.'),
        ),
      );
      return;
    }
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateLaporanPage(
              projectId: widget.project.projectId!,
              projectName: widget.project.namaProject,
              mandorId: mandorProjectController.mandorProject!.mandorProyekId!,
            ),
      ),
    ).then((result) {
      if (result == true) {
        _refreshReports();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Proyek'),
        backgroundColor: const Color(0xFF1CA5B8),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReports,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Info Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1CA5B8).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.project.foto!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.project.namaProject,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      _getStatusIcon(widget.project.status),
                                      size: 18,
                                      color: _getStatusColor(
                                        widget.project.status,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.project.status.toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(
                                          widget.project.status,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Project Details with clickable location
                      _buildDetailRowWithMap(
                        Icons.location_on,
                        'Lokasi',
                        widget.lokasi ?? '',
                        'Lokasi Proyek: ${widget.project.namaProject}',
                        false,
                        widget.project.lokasi,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Deadline',
                        _formatDate(widget.project.deadline),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Reports Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Laporan Proyek',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: widget.project.status == 'Selesai' ? null : _navigateToCreateReport,
                    icon: const Icon(Icons.add),
                    label: const Text('Buat Laporan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1CA5B8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Consumer<LaporanController>(
                builder: (context, laporanController, child) {
                  return _buildReportsSection(laporanController);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
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
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowWithMap(
    IconData icon,
    String label,
    String value,
    String mapTitle,
    bool isReportLocation,
    String? lokasi,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
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
              GestureDetector(
                onTap:
                    value.isNotEmpty
                        ? () => _showMapDialog(
                          lokasi!,
                          mapTitle,
                          isReportLocation: isReportLocation,
                        )
                        : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          value.isNotEmpty ? value : 'Lokasi tidak tersedia',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                value.isNotEmpty
                                    ? const Color(0xFF1CA5B8)
                                    : Colors.grey,
                            decoration:
                                value.isNotEmpty
                                    ? TextDecoration.underline
                                    : null,
                          ),
                        ),
                      ),
                      if (value.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.map,
                          size: 16,
                          color: Color(0xFF1CA5B8),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportsSection(LaporanController laporanController) {
    if (laporanController.isLoading || _isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1CA5B8)),
              ),
              SizedBox(height: 16),
              Text('Memuat laporan...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (laporanController.errorMessage != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: ${laporanController.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _refreshReports,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1CA5B8),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    debugPrint('Project ID: ${widget.project.projectId}');
    debugPrint('Total reports: ${laporanController.laporans.length}');

    if (laporanController.laporans.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.description, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Belum ada laporan untuk proyek ini',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Klik "Buat Laporan" untuk menambahkan laporan pertama',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _navigateToCreateReport,
                icon: const Icon(Icons.add),
                label: const Text('Buat Laporan Pertama'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1CA5B8),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    laporanController.laporans.sort((a, b) => b.tanggal!.compareTo(a.tanggal!));

    return Column(
      children:
          laporanController.laporans.map((report) {
            return GestureDetector(
              onTap: () => DetailLaporan.show(context, report),
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1CA5B8).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.description,
                              color: Color(0xFF1CA5B8),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Laporan #${report.laporanId}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateTime(
                                    report.tanggal!.toIso8601String(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deskripsi:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              report.deskripsi,
                              style: const TextStyle(fontSize: 14),
                            ),

                            if (report.lokasi.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap:
                                    () => _showMapDialog(
                                      report.lokasi,
                                      'Lokasi Laporan #${report.laporanId}',
                                      isReportLocation: true,
                                    ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1CA5B8,
                                    ).withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF1CA5B8,
                                      ).withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Color(0xFF1CA5B8),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              report.lokasi,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF1CA5B8),
                                                decoration:
                                                    TextDecoration.underline,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              'Tap untuk lihat peta & jarak ke proyek',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.map,
                                        size: 14,
                                        color: Color(0xFF1CA5B8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 12),
                            Text(
                              'Material:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              report.material,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                const Icon(
                                  Icons.people,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${report.jumlahPekerja} pekerja',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            if (report.kendala != null &&
                                report.kendala!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.warning,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Kendala:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          Text(
                                            report.kendala!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
