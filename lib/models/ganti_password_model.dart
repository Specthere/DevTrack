class GantiPasswordModel {
  final String oldPassword;
  final String newPassword;

  GantiPasswordModel({
    required this.oldPassword,
    required this.newPassword,
  });

  factory GantiPasswordModel.fromJson(Map<String, dynamic> json) {
    return GantiPasswordModel(
      oldPassword: json['oldPassword'],
      newPassword: json['newPassword'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}
