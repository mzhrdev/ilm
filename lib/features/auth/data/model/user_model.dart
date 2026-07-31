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

  /// CopyWith Method
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    List<String>? skills,
    String? about,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      skills: skills ?? this.skills,
      about: about ?? this.about,
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
    );
  }
}
