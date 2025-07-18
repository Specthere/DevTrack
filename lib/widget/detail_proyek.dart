import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracedev/controller/project_controller.dart';
import 'package:tracedev/controller/riwayat_controller.dart';
import 'package:tracedev/controller/mandor_project_project_controller.dart';
import 'package:tracedev/view/edit_proyek.dart';
import 'package:tracedev/view/tugaskan_mandor.dart';

class DetailProyek extends StatefulWidget {
  final int id;
  final String title;
  final String lokasi;
  final String status;
  final String deadline;
  final String imageUrl;

  const DetailProyek({
    super.key,
    required this.id,
    required this.title,
    required this.lokasi,
    required this.status,
    required this.deadline,
    required this.imageUrl,
  });

  @override
  State<DetailProyek> createState() => _DetailProyekState();
}

class _DetailProyekState extends State<DetailProyek> {
  @override
  void initState() {
    super.initState();
    // Load data mandor untuk proyek ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MandorProjectProjectController>(
        context,
        listen: false,
      ).getAllMandorProjectProject();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageHeader(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusBadge(),
                    SizedBox(height: 20),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Deadline',
                      value: widget.deadline,
                    ),
                    SizedBox(height: 16),
                    _buildMandorList(),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        image: DecorationImage(
          image: NetworkImage(widget.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white70, size: 16),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      widget.lokasi,
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor =
        widget.status == 'Sedang Berjalan'
            ? Colors.green
            : widget.status == 'Selesai'
            ? Colors.blue
            : widget.status == 'Belum Mulai'
            ? Colors.grey
            : Colors.red;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            widget.status,
            style: TextStyle(
              color: badgeColor.withAlpha(700),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.blue[700]),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildMandorList() {
    return Consumer<MandorProjectProjectController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: Colors.blue[600],
                    strokeWidth: 2,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Memuat data mandor...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Filter mandor berdasarkan project ID
        final mandorList =
            controller.allMandor
                .where((mpp) => mpp.projectId == widget.id)
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildMandorHeader(mandorList.length),
            SizedBox(height: 16),

            // Content Section
            if (mandorList.isEmpty)
              _buildEmptyMandorState()
            else
              _buildMandorListContent(mandorList),
          ],
        );
      },
    );
  }

  Widget _buildMandorHeader(int mandorCount) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.person_4_rounded,
            size: 22,
            color: Colors.blue[700],
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mandor Proyek',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '$mandorCount ${mandorCount == 1 ? 'orang' : 'orang'}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        if (mandorCount > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Text(
              'Aktif',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyMandorState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'Belum ada mandor yang ditugaskan',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[500],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildMandorListContent(List<dynamic> mandorList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          mandorList.asMap().entries.map((entry) {
            final index = entry.key;
            final mpp = entry.value;
            final mandor = mpp.mandorProject;
            final user = mandor?.users;
            final mandorName =
                user?.nama ??
                'Mandor #${mandor?.mandorProyekId ?? (index + 1)}';

            return Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      mandorName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          // Baris pertama - Tombol utama
          Row(
            children: [
              // Tombol Edit
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      widget.status == 'Selesai'
                          ? null
                          : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => EditProyek(idProject: widget.id),
                            ),
                          ),
                  icon: Icon(Icons.edit, size: 18, color: Colors.white),
                  label: Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    backgroundColor: Color.fromRGBO(249, 175, 1, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Tombol Mandor
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      widget.status == 'Selesai'
                          ? null
                          : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => TugaskanMandor(
                                    idProject: widget.id,
                                    projectName: widget.title,
                                  ),
                            ),
                          ),
                  icon: Icon(
                    Icons.person_4_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Mandor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    backgroundColor: Color.fromRGBO(36, 158, 192, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Baris kedua - Tombol Selesaikan Proyek
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      widget.status == 'Sedang Berjalan'
                          ? () => _showCompleteProjectDialog(context)
                          : null,
                  icon: Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color:
                        widget.status == 'Sedang Berjalan'
                            ? Colors.white
                            : Colors.grey[400],
                  ),
                  label: Text(
                    'Selesaikan Proyek',
                    style: TextStyle(
                      color:
                          widget.status == 'Sedang Berjalan'
                              ? Colors.white
                              : Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    backgroundColor:
                        widget.status == 'Sedang Berjalan'
                            ? Colors.green[600]
                            : Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Baris ketiga - Tombol Tutup
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, size: 18),
                  label: Text(
                    'Tutup',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCompleteProjectDialog(BuildContext context) {
    final riwayatController = Provider.of<RiwayatController>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<RiwayatController>(
          builder: (context, controller, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.green[600], size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Selesaikan Proyek',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambahkan catatan penyelesaian untuk proyek:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Catatan Penyelesaian *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: controller.catatanController,
                    maxLines: 4,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText:
                          'Masukkan catatan penyelesaian proyek...\nContoh: Proyek selesai tepat waktu, semua target tercapai.',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.green[600]!,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(12),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      controller.isLoading
                          ? null
                          : () {
                            controller.clear();
                            Navigator.of(context).pop();
                          },
                  child: Text('Batal', style: TextStyle(fontSize: 14)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      controller.isLoading
                          ? null
                          : () async {
                            // Validasi input
                            if (controller.catatanController.text
                                .trim()
                                .isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Catatan penyelesaian harus diisi!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.orange[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                              return;
                            }

                            try {
                              // Tambahkan riwayat penyelesaian proyek
                              print("id proyek: ${widget.id}");
                              await controller.addRiwayat(widget.id);

                              if (controller.isSuccess) {
                                Navigator.of(
                                  context,
                                ).pop(); // Tutup dialog input catatan
                                Navigator.of(
                                  context,
                                ).pop(); // Tutup dialog detail proyek

                                await Provider.of<ProjectController>(
                                  context,
                                  listen: false,
                                ).getAllProjects();

                                controller.clear();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Proyek berhasil diselesaikan dan riwayat telah disimpan!',
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.green[600],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              } else if (controller.errorMessage != null) {
                                // Tampilkan error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(controller.errorMessage!),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.red[600],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Terjadi kesalahan: ${e.toString()}',
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.red[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            }
                          },
                  icon:
                      controller.isLoading
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Icon(Icons.save, size: 18),
                  label: Text(
                    controller.isLoading ? 'Menyimpan...' : 'Simpan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
