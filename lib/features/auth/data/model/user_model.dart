class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final List<String>? skills;
  final String? about;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
     this.role='student',
    this.profileImageUrl,
    this.skills,
    this.about,
  });

  /// CopyWith Method
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    List<String>? skills,
    String? about,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      skills: skills ?? this.skills,
      about: about ?? this.about,
      role: role ?? this.role,
    );
  }

  /// Convert to JSON (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'skills': skills,
      'about': about,
      'role': role,
    };
  }

  /// Create from JSON (from Firestore)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      about: json['about'],
      role:json['role'] ?? 'student',
    );
  }
}
