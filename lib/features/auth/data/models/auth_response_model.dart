import '../../domain/entities/authenticated_user.dart';

class AuthResponseModel {
  const AuthResponseModel({
    required this.userId,
    required this.email,
    required this.username,
    required this.token,
  });

  final int userId;
  final String email;
  final String username;
  final String token;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      userId: json['userId'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'username': username,
      'token': token,
    };
  }

  AuthenticatedUser toEntity() {
    return AuthenticatedUser(
      id: userId,
      email: email,
      username: username,
      token: token,
    );
  }
}
