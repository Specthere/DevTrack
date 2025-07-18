import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:tracedev/models/laporan.dart';
import 'package:tracedev/controller/laporan_controller.dart';
import 'package:tracedev/widget/detail_laporan.dart';

class LaporanPage extends StatefulWidget {
  final int projectId;
  final String? projectLocation;
  final String? alamatProject;
  const LaporanPage({super.key, required this.projectId, this.projectLocation, this.alamatProject});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String searchQuery = '';
  String selectedFilter = 'Semua';

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

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    } else {
      return '${distanceKm.toStringAsFixed(2)} km';
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LaporanController>().getLaporanByProjectId(widget.projectId);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method untuk menampilkan map lokasi
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

    final projectCoordinates = _parseLocation(widget.projectLocation ?? '');
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
                      if (isReportLocation &&
                          widget.projectLocation != null) ...[
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
                                'Proyek: ${widget.alamatProject}',
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

  List<Laporan> getFilteredLaporan(List<Laporan> laporanList) {
    List<Laporan> filtered =
        laporanList.where((laporan) {
          bool matchesSearch =
              searchQuery.isEmpty ||
              laporan.deskripsi.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );

          bool matchesFilter = true;
          DateTime now = DateTime.now();

          switch (selectedFilter) {
            case 'Hari Ini':
              matchesFilter =
                  laporan.tanggal!.day == now.day &&
                  laporan.tanggal!.month == now.month &&
                  laporan.tanggal!.year == now.year;
              break;
            case 'Minggu Ini':
              DateTime startOfWeek = now.subtract(
                Duration(days: now.weekday - 1),
              );
              DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
              matchesFilter =
                  laporan.tanggal!.isAfter(
                    startOfWeek.subtract(Duration(days: 1)),
                  ) &&
                  laporan.tanggal!.isBefore(endOfWeek.add(Duration(days: 1)));
              break;
            case 'Bulan Ini':
              matchesFilter =
                  laporan.tanggal!.month == now.month &&
                  laporan.tanggal!.year == now.year;
              break;
            default: // 'Semua'
              matchesFilter = true;
          }

          return matchesSearch &&
              matchesFilter &&
              laporan.projectId == widget.projectId;
        }).toList();

    return filtered;
  }

  int getTodayCount(List<Laporan> laporanList) {
    DateTime now = DateTime.now();
    return laporanList
        .where(
          (l) =>
              l.tanggal!.toLocal().day == now.day &&
              l.tanggal!.toLocal().month == now.month &&
              l.tanggal!.toLocal().year == now.year,
        )
        .length;
  }

  String formatTanggal(DateTime tanggal) {
    List<String> bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
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
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_outlined),
            color: Colors.white,
          ),
          title: const Text(
            'Laporan Proyek',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                context.read<LaporanController>().getAllLaporan();
              },
              icon: Icon(Icons.refresh, color: Colors.white),
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<LaporanController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF249EC0),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Memuat laporan...',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              if (controller.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Terjadi Kesalahan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          controller.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          controller.getAllLaporan();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF249EC0),
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              List<Laporan> filteredLaporan = getFilteredLaporan(
                controller.laporans,
              );

              return Column(
                children: [
                  // Header dengan Search Bar
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
                                hintText: 'Cari laporan',
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

                  // Statistics Cards
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Laporan',
                            filteredLaporan.length.toString(),
                            Icons.description,
                            Colors.blue,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            'Hari Ini',
                            getTodayCount(controller.laporans).toString(),
                            Icons.today,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter Chips
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip('Semua'),
                        _buildFilterChip('Hari Ini'),
                        _buildFilterChip('Minggu Ini'),
                        _buildFilterChip('Bulan Ini'),
                      ],
                    ),
                  ),

                  // Laporan List
                  Expanded(
                    child:
                        filteredLaporan.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                              onRefresh: () async {
                                await controller.getAllLaporan();
                              },
                              color: Color(0xFF249EC0),
                              child: ListView.builder(
                                padding: EdgeInsets.all(20),
                                itemCount: filteredLaporan.length,
                                itemBuilder: (context, index) {
                                  return _buildLaporanCard(
                                    filteredLaporan[index],
                                    index,
                                  );
                                },
                              ),
                            ),
                  ),
                ],
              );
            },
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
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return Container(
      margin: EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = label;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Color(0xFF249EC0),
        checkmarkColor: Colors.white,
        elevation: 2,
        pressElevation: 4,
      ),
    );
  }

  Widget _buildLaporanCard(Laporan laporan, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 500 + (index * 100)),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => DetailLaporan.show(context, laporan),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Row(
                    children: [
                      Text(
                        formatTanggal(laporan.tanggal!),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Deskripsi
                  Text(
                    laporan.deskripsi,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 12),

                  // Info Grid - Modified to include location
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          Icons.construction_rounded,
                          'Material',
                          laporan.material,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          Icons.people,
                          'Pekerja',
                          '${laporan.jumlahPekerja} orang',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  // Location Info - New addition
                  if (laporan.lokasi != null && laporan.lokasi!.isNotEmpty)
                    GestureDetector(
                      onTap:
                          () => _showMapDialog(
                            laporan.lokasi,
                            'Lokasi laporan ${laporan.laporanId}',
                            isReportLocation: true,
                          ),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.blue[600],
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                laporan.lokasi!,
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.open_in_new,
                              color: Colors.blue[600],
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (laporan.kendala != null &&
                      laporan.kendala != 'Tidak ada kendala signifikan') ...[
                    if (laporan.lokasi != null && laporan.lokasi!.isNotEmpty)
                      SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.orange[600],
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              laporan.kendala!,
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 12),

                  // Footer
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Spacer(),
                      if (laporan.foto != null)
                        Icon(
                          Icons.photo_camera,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text(
            searchQuery.isNotEmpty
                ? 'Tidak ada laporan ditemukan'
                : 'Belum ada laporan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
