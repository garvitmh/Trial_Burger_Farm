class UserEntity {
  final String id;
  final String phone;
  final String? token;

  UserEntity({
    required this.id,
    required this.phone,
    this.token,
  });
}
