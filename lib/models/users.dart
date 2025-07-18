import 'dart:ffi';

class Users {
  final int? userId;
  final String nama;
  final String email;
  final String password;
  final int? roleId;
  final String alamat;
  final String noHp;
  final String? foto;
  final bool isActive;

  Users({
    this.userId,
    required this.nama,
    required this.email,
    required this.password,
    this.roleId,
    required this.alamat,
    required this.noHp,
    this.foto,
    required this.isActive,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: json['userId'],
      nama: json['nama'],
      email: json['email'],
      password: json['password'],
      roleId: json['roleId'],
      alamat: json['alamat'],
      noHp: json['no_hp'],
      foto: json['foto'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nama': nama,
      'email': email,
      'password': password,
      'roleId': roleId,
      'alamat': alamat,
      'no_hp': noHp,
      'foto': foto,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'nama': nama,
      'email': email,
      'password': password,
      'alamat': alamat,
      'no_hp': noHp,
      'foto': foto,
    };
  }
}
