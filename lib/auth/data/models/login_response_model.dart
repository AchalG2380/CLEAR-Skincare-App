class LoginResponseModel {
  final String token;
  final String userId;
  final String name;
  final String email;

  LoginResponseModel({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] ?? '',
      userId: json['userId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
