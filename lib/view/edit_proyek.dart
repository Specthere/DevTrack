import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tracedev/controller/project_controller.dart';
import 'package:tracedev/widget/show_snackbar.dart';

class EditProyek extends StatefulWidget {
  const EditProyek({super.key, required this.idProject});
  final int idProject;

  @override
  State<EditProyek> createState() => _EditProyekState();
}

class _EditProyekState extends State<EditProyek> {
  final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();
  File? _image;
  String? _imageUrl;
  LatLng? selectedLocation;
  bool _isInitialLoading = true;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showData();
    });
  }

  Future<void> _showData() async {
    final projectController = Provider.of<ProjectController>(
      context,
      listen: false,
    );

    setState(() {
      _isInitialLoading = true;
    });

    try {
      await projectController.getProjectById(widget.idProject);

      if (projectController.project != null) {
        projectController.namaProjectController.text =
            projectController.project!.namaProject;
        projectController.statusController.text =
            projectController.project!.status;
        projectController.lokasiController.text =
            projectController.project!.lokasi;
        projectController.setDeadline(projectController.project!.deadline);

        _imageUrl = projectController.project!.foto;

        try {
          final locationParts = projectController.project!.lokasi.split(',');
          if (locationParts.length == 2) {
            final lat = double.parse(locationParts[0].trim());
            final lng = double.parse(locationParts[1].trim());
            selectedLocation = LatLng(lat, lng);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _mapController.move(selectedLocation!, 15.0);
            });
          }
        } catch (e) {
          print('Error parsing location: $e');
        }
      }
    } catch (e) {
      ShowSnackbar.show(context, 'Gagal memuat data proyek: $e', false);
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final projectController = Provider.of<ProjectController>(
      context,
      listen: false,
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: projectController.selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color.fromRGBO(36, 158, 192, 1),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      projectController.setDeadline(picked);
    }
  }

  Future<void> _pickImage() async {
    try {
      final status = await Permission.storage.request();
      final status2 = await Permission.photos.request();

      if (status.isDenied && status2.isDenied) {
        ShowSnackbar.show(context, 'Izin penyimpanan ditolak.', false);
        return;
      }

      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ShowSnackbar.show(context, 'Gagal memilih gambar: $e', false);
    }
  }

  Future<void> _pickLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ShowSnackbar.show(context, 'Layanan lokasi tidak aktif.', false);
        return;
      }

      PermissionStatus permissionStatus = await Permission.location.status;
      if (permissionStatus.isDenied) {
        permissionStatus = await Permission.location.request();
        if (permissionStatus.isDenied) {
          ShowSnackbar.show(context, 'Izin lokasi ditolak.', false);
          return;
        }
      }

      if (permissionStatus.isPermanentlyDenied) {
        ShowSnackbar.show(
          context,
          'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan.',
          false,
        );
        await openAppSettings();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
      });

      final projectController = Provider.of<ProjectController>(
        context,
        listen: false,
      );
      projectController.lokasiController.text =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';

      // Move map to new location
      _mapController.move(selectedLocation!, 15.0);
    } catch (e) {
      ShowSnackbar.show(context, 'Gagal mendapatkan lokasi: $e', false);
    }
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final projectController = Provider.of<ProjectController>(
        context,
        listen: false,
      );

      if (selectedLocation == null) {
        ShowSnackbar.show(
          context,
          'Silakan pilih lokasi terlebih dahulu',
          false,
        );
        return;
      }

      try {
        bool result = await projectController.updateProject(
          widget.idProject,
          _image,
          _imageUrl ?? '',
        );

        if (result) {
          ShowSnackbar.show(context, 'Proyek berhasil diupdate!', true);
          Navigator.pop(context, true); // Return true to indicate success
        } 
      } catch (e) {
        ShowSnackbar.show(context, 'Gagal mengupdate proyek: $e', false);
      }
    }
  }

  double _getResponsiveValue(
    double screenWidth,
    double mobile,
    double tablet,
    double desktop,
  ) {
    if (screenWidth < mobileBreakpoint) return mobile;
    if (screenWidth < tabletBreakpoint) return tablet;
    return desktop;
  }

  EdgeInsets _getResponsivePadding(double screenWidth) {
    return EdgeInsets.all(_getResponsiveValue(screenWidth, 16.0, 24.0, 32.0));
  }

  double _getMapHeight(double screenWidth) {
    return _getResponsiveValue(screenWidth, 250.0, 300.0, 350.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= mobileBreakpoint;

    if (_isInitialLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(36, 158, 192, 1),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Proyek',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(36, 158, 192, 1),
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<ProjectController>(
          builder: (context, controller, child) {
            return SingleChildScrollView(
              padding: _getResponsivePadding(screenWidth),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 800 : double.infinity,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProjectTitleField(controller),
                        SizedBox(
                          height: _getResponsiveValue(
                            screenWidth,
                            16.0,
                            20.0,
                            24.0,
                          ),
                        ),
                        _buildDeadlineField(context, controller),
                        SizedBox(
                          height: _getResponsiveValue(
                            screenWidth,
                            16.0,
                            20.0,
                            24.0,
                          ),
                        ),
                        _buildStatusDropdown(controller),
                        SizedBox(
                          height: _getResponsiveValue(
                            screenWidth,
                            16.0,
                            20.0,
                            24.0,
                          ),
                        ),
                        _buildLocationSection(screenWidth, controller),
                        SizedBox(
                          height: _getResponsiveValue(
                            screenWidth,
                            16.0,
                            20.0,
                            24.0,
                          ),
                        ),
                        _buildImageSection(screenWidth),
                        SizedBox(
                          height: _getResponsiveValue(
                            screenWidth,
                            24.0,
                            32.0,
                            40.0,
                          ),
                        ),
                        // Error Message Display
                        if (controller.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.errorMessage ?? '',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: controller.isLoading ? null : _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(
                                36,
                                158,
                                192,
                                1,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: const Color.fromRGBO(
                                36,
                                158,
                                192,
                                0.3,
                              ),
                            ),
                            child:
                                controller.isLoading
                                    ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Menyimpan...'),
                                      ],
                                    )
                                    : const Text(
                                      'Update Proyek',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProjectTitleField(ProjectController controller) {
    return TextFormField(
      controller: controller.namaProjectController,
      decoration: InputDecoration(
        labelText: 'Judul Proyek',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(36, 158, 192, 1)),
        ),
        prefixIcon: const Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Judul tidak boleh kosong';
        }
        if (value.trim().length < 3) {
          return 'Judul minimal 3 karakter';
        }
        return null;
      },
    );
  }

  Widget _buildDeadlineField(
    BuildContext context,
    ProjectController controller,
  ) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Deadline',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromRGBO(36, 158, 192, 1),
              ),
            ),
            suffixIcon: const Icon(Icons.calendar_today),
            prefixIcon: const Icon(Icons.schedule),
          ),
          controller: TextEditingController(
            text:
                controller.selectedDeadline == null
                    ? ''
                    : '${controller.selectedDeadline!.day.toString().padLeft(2, '0')}/${controller.selectedDeadline!.month.toString().padLeft(2, '0')}/${controller.selectedDeadline!.year}',
          ),
          validator: (value) {
            if (controller.selectedDeadline == null) {
              return 'Deadline tidak boleh kosong';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(ProjectController controller) {
    return DropdownButtonFormField<String>(
      value:
          controller.statusController.text.isNotEmpty
              ? controller.statusController.text
              : null,
      items:
          ['Belum Mulai', 'Sedang Berjalan']
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) {
          controller.statusController.text = value;
        }
      },
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(36, 158, 192, 1)),
        ),
        prefixIcon: const Icon(Icons.flag),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Status tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildLocationSection(
    double screenWidth,
    ProjectController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on,
              color: Color.fromRGBO(36, 158, 192, 1),
            ),
            const SizedBox(width: 8),
            Text(
              'Pilih Lokasi di Peta:',
              style: TextStyle(
                fontSize: _getResponsiveValue(screenWidth, 16.0, 18.0, 20.0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: _getMapHeight(screenWidth),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        selectedLocation ?? const LatLng(-7.2575, 112.7521),
                    initialZoom: 15,
                    onTap: (tapPosition, point) {
                      setState(() {
                        selectedLocation = point;
                        controller.lokasiController.text =
                            '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.app',
                    ),
                    if (selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedLocation!,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: FloatingActionButton.small(
                    onPressed: _pickLocation,
                    backgroundColor: const Color.fromRGBO(36, 158, 192, 1),
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.lokasiController,
          decoration: InputDecoration(
            labelText: 'Koordinat Lokasi',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromRGBO(36, 158, 192, 1),
              ),
            ),
            suffixIcon: const Icon(Icons.map),
            prefixIcon: const Icon(Icons.gps_fixed),
          ),
          readOnly: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Lokasi tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImageSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.image, color: Color.fromRGBO(36, 158, 192, 1)),
            const SizedBox(width: 8),
            Text(
              'Thumbnail Proyek',
              style: TextStyle(
                fontSize: _getResponsiveValue(screenWidth, 16.0, 18.0, 20.0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: _getResponsiveValue(screenWidth, 150.0, 180.0, 200.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    _image != null ||
                            (_imageUrl != null && _imageUrl!.isNotEmpty)
                        ? const Color.fromRGBO(36, 158, 192, 1)
                        : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  _image != null
                      ? _buildImagePreview(Image.file(_image!).image)
                      : (_imageUrl != null && _imageUrl!.isNotEmpty)
                      ? _buildImagePreview(NetworkImage(_imageUrl!))
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            color: Colors.grey.shade400,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pilih Gambar',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(ImageProvider imageProvider) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _image = null;
                  _imageUrl = null;
                });
              },
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
