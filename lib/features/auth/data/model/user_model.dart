class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final List<String>? skills;
  final String? about;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.skills,
    this.about,
  });
}
