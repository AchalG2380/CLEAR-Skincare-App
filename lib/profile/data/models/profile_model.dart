class ProfileModel {
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;

  ProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }

  ProfileModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
