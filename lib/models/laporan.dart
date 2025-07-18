  class Laporan {
    final int? laporanId;
    final DateTime? tanggal;
    final String deskripsi;
    final String material;
    final String lokasi;
    final int jumlahPekerja;
    final String? kendala;
    final String? foto;
    final int? projectId;
    final int? mandorProyekId;
    final DateTime? updatedAt;

    Laporan({
      this.laporanId,
      this.tanggal,
      required this.deskripsi,
      required this.material,
      required this.lokasi,
      required this.jumlahPekerja,
      this.kendala,
      this.foto,
      this.projectId,
      this.mandorProyekId,
      this.updatedAt,
    });

    factory Laporan.fromJson(Map<String, dynamic> json) {
      return Laporan(
        laporanId: json['laporanId'],
        tanggal: DateTime.parse(json['tanggal']).toLocal(),
        deskripsi: json['deskripsi'],
        material: json['material'],
        lokasi: json['lokasi'],
        jumlahPekerja: json['jumlahPekerja'],
        kendala: json['kendala'],
        foto: json['foto'],
        projectId: json['projectId'],
        mandorProyekId: json['mandorProyekId'],
        updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      );
    }

    Map<String, dynamic> toCreateJson() {
      return {
        'deskripsi': deskripsi,
        'material': material,
        'lokasi': lokasi,
        'jumlahPekerja': jumlahPekerja,
        'kendala': kendala,
        'foto': foto,
        'projectId': projectId,
        'mandorProyekId': mandorProyekId,
        'tanggal': DateTime.now().toUtc().toIso8601String(),
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };
    }

    Map<String, dynamic> toUpdateJson() {
      return {
        'deskripsi': deskripsi,
        'material': material,
        'lokasi': lokasi,
        'jumlahPekerja': jumlahPekerja,
        'kendala': kendala,
        'foto': foto,
        'updatedAt': DateTime.now().toLocal().toUtc().toIso8601String(),
      };
    }
  }
