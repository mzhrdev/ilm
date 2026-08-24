// Pre-warm Stream Video SDK when an authenticated user is detected
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/auth/data/model/user_model.dart';
import 'package:lms/features/auth/data/providers/current_user_provider.dart';
import 'package:lms/features/calls/data/services/stream_video_service.dart';

final streamPrewarmProvider = Provider<void>((ref) {
  ref.listen<UserModel?>(currentUserProvider, (previous, user) async {
    if (user != null) {
      try {
        await StreamVideoService.instance.initStreamVideo(
          uid: user.id,
          name: user.name,
          avatarUrl: user.profileImageUrl,
        );
        debugPrint('⚡ Stream Video SDK Pre-warmed for ${user.name}');
      } catch (e) {
        debugPrint('❌ Stream SDK Pre-warm Error: $e');
      }
    }
  });
});
