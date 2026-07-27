import 'package:lms/features/auth/data/model/user_model.dart';
import 'package:riverpod/riverpod.dart';

// Simulated User - Replace with actual Auth State
final userProvider = Provider<UserModel>((ref) {
  return UserModel(
    id: 'user_1',
    name: 'Syed',
    email: 'fawais@university.edu',
    skills: ["UI/UX", "Flutter", "Docker"],
    about:
        "I am flutter app developer with a skill set provided below. I am passionate about learning the Quran and it's insights ",
  );
});
