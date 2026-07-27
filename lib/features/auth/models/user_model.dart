class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? gender;
  final DateTime? dob;
  final bool? isAdmin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.gender,
    this.dob,
    this.isAdmin,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"]?.toString(),
      name: json["name"]?.toString(),
      email: json["email"]?.toString(),
      phone: json["phone"]?.toString(),
      avatar: json["avatar"]?.toString(),
      gender: json["gender"]?.toString(),
      dob: json["dob"] != null
          ? DateTime.parse(json["dob"])
          : null,
      isAdmin: json["isAdmin"] as bool?,
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : null,
    );
  }
}