import 'package:tracedev/models/users.dart';

class MandorProject {
  final int? mandorProyekId;
  final int userId;
  final bool isWorking;
  final Users? users;

  MandorProject({
    this.mandorProyekId,
    required this.userId,
    required this.isWorking,
    this.users,
  });

  factory MandorProject.fromJson(Map<String, dynamic> json) {
    return MandorProject(
      mandorProyekId: json['mandorProyekId'],
      userId: json['userId'],
      isWorking: json['isWorking'],
      users: json['user'] != null ? Users.fromJson(json['user']) : null,
    );
  }
}


