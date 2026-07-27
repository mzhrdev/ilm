import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  AuthState({
    //-----
    required this.signinFormKey,
    required this.signUpFormKey,

    //-----
    required this.authEmailController,
    required this.authPasswordController,
    required this.userNameController,
    required this.confirmPassController,
    //-----
    required this.resetPassEmailController,
    required this.resetPassController,
    //-----
    required this.userTypeController,
  });
  // Form Keys
  final GlobalKey<FormState> signinFormKey;
  final GlobalKey<FormState> signUpFormKey;

  // TextEditingController
  final TextEditingController authEmailController;
  final TextEditingController authPasswordController;
  final TextEditingController resetPassEmailController;
  final TextEditingController userTypeController;
  final TextEditingController userNameController;
  final TextEditingController confirmPassController;
  final TextEditingController resetPassController;

  AuthState copyWith({
    // Form Keys CopyWith
    GlobalKey<FormState>? signinFormKey,
    GlobalKey<FormState>? signUpFormKey,
    TextEditingController? resetPassController,
    TextEditingController? authEmailController,
    TextEditingController? authPasswordController,
    TextEditingController? resetPassEmailController,
    TextEditingController? userTypeController,
    TextEditingController? userNameController,
    TextEditingController? confirmPassController,
  }) {
    return AuthState(
      confirmPassController: confirmPassController ?? this.confirmPassController,
      userNameController: userNameController ?? this.userNameController,
      authEmailController: authEmailController ?? this.authEmailController,
      authPasswordController: authPasswordController ?? this.authPasswordController,
      resetPassController: resetPassController ?? this.resetPassController,
      resetPassEmailController: resetPassEmailController ?? this.resetPassEmailController,
      signUpFormKey: signUpFormKey ?? this.signUpFormKey,
      signinFormKey: signinFormKey ?? this.signinFormKey,
      userTypeController: userTypeController ?? this.userTypeController,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
    : super(
        AuthState(
          confirmPassController: TextEditingController(),
          userNameController: TextEditingController(),
          signinFormKey: GlobalKey<FormState>(),
          signUpFormKey: GlobalKey<FormState>(),
          resetPassController: TextEditingController(),
          authEmailController: TextEditingController(),
          authPasswordController: TextEditingController(),
          resetPassEmailController: TextEditingController(),
          userTypeController: TextEditingController(),
        ),
      );
}
