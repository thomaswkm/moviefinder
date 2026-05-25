class AuthenticatedUser {
  const AuthenticatedUser({
    required this.id,
    required this.email,
    required this.username,
    required this.token,
  });

  final int id;
  final String email;
  final String username;
  final String token;
}
