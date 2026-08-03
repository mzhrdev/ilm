import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  AuthState({
    required this.signinFormKey,
    required this.signUpFormKey,

    required this.authEmailController,
    required this.authPasswordController,
    required this.userNameController,
    required this.confirmPassController,

    required this.resetPassEmailController,
    required this.resetPassController,

    required this.userTypeController,

    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  // 🔹 Form Keys
  final GlobalKey<FormState> signinFormKey;
  final GlobalKey<FormState> signUpFormKey;

  // 🔹 Controllers
  final TextEditingController authEmailController;
  final TextEditingController authPasswordController;
  final TextEditingController userNameController;
  final TextEditingController confirmPassController;
  final TextEditingController resetPassEmailController;
  final TextEditingController resetPassController;
  final TextEditingController userTypeController;

  // 🔹 Firebase State
  final bool isLoading;
  final String? errorMessage;
  final User? user;

  AuthState copyWith({
    GlobalKey<FormState>? signinFormKey,
    GlobalKey<FormState>? signUpFormKey,
    TextEditingController? authEmailController,
    TextEditingController? authPasswordController,
    TextEditingController? userNameController,
    TextEditingController? confirmPassController,
    TextEditingController? resetPassEmailController,
    TextEditingController? resetPassController,
    TextEditingController? userTypeController,
    bool? isLoading,
    String? errorMessage,
    User? user,
  }) {
    return AuthState(
      signinFormKey: signinFormKey ?? this.signinFormKey,
      signUpFormKey: signUpFormKey ?? this.signUpFormKey,
      authEmailController: authEmailController ?? this.authEmailController,
      authPasswordController: authPasswordController ?? this.authPasswordController,
      userNameController: userNameController ?? this.userNameController,
      confirmPassController: confirmPassController ?? this.confirmPassController,
      resetPassEmailController: resetPassEmailController ?? this.resetPassEmailController,
      resetPassController: resetPassController ?? this.resetPassController,
      userTypeController: userTypeController ?? this.userTypeController,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
    : super(
        AuthState(
          signinFormKey: GlobalKey<FormState>(),
          signUpFormKey: GlobalKey<FormState>(),
          authEmailController: TextEditingController(),
          authPasswordController: TextEditingController(),
          userNameController: TextEditingController(),
          confirmPassController: TextEditingController(),
          resetPassEmailController: TextEditingController(),
          resetPassController: TextEditingController(),
          userTypeController: TextEditingController(),
        ),
      ) {
    _initAuthListener();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Listen to auth state changes
  void _initAuthListener() {
    _auth.authStateChanges().listen((user) {
      state = state.copyWith(user: user);
    });
  }

  // SIGN UP
  Future<bool> signUp() async {
    if (!state.signUpFormKey.currentState!.validate()) return false;

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final result = await _auth.createUserWithEmailAndPassword(
        email: state.authEmailController.text.trim(),
        password: state.authPasswordController.text.trim(),
      );

      state = state.copyWith(isLoading: false, user: result.user);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
    return false;
  }

  // SIGN IN
  Future<bool> signIn() async {
    if (!state.signinFormKey.currentState!.validate()) return false;

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final result = await _auth.signInWithEmailAndPassword(
        email: state.authEmailController.text.trim(),
        password: state.authPasswordController.text.trim(),
      );

      state = state.copyWith(isLoading: false, user: result.user);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
    return false;
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Reference the initialized singleton instance
      final googleSignIn = GoogleSignIn.instance;

      // 2. Authentication (Identity Flow)
      // This triggers the modern Credential Manager sheet / Account Picker
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // 3. Authorization (Permissions Flow)
      // Explicitly request scopes to safely extract the modern Access Token
      final List<String> scopes = ['email', 'profile'];
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(scopes);

      // 4. Retrieve Identity Details
      final authDetails = googleUser.authentication;

      // 5. Create the Firebase Credential using tokens from both steps
      final credential = GoogleAuthProvider.credential(
        idToken: authDetails.idToken, // From the identity authentication layer
        accessToken: clientAuth.accessToken, // From the explicit authorization layer
      );

      // 6. Sign in to Firebase Auth
      await _auth.signInWithCredential(credential);

      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      // Catch generic/platform exceptions thrown by the Google SDK
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // RESET PASSWORD
  Future<void> resetPassword() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _auth.sendPasswordResetEmail(email: state.resetPassEmailController.text.trim());

      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
    state = state.copyWith(user: null);
  }

  // CHECK LOGIN
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Dispose controllers (VERY IMPORTANT)
  @override
  void dispose() {
    state.authEmailController.dispose();
    state.authPasswordController.dispose();
    state.userNameController.dispose();
    state.confirmPassController.dispose();
    state.resetPassEmailController.dispose();
    state.resetPassController.dispose();
    state.userTypeController.dispose();
    super.dispose();
  }
}
