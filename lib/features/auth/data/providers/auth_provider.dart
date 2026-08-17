import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lms/core/data/services/firebase_firestore_services.dart';
import 'package:lms/features/auth/data/model/user_model.dart';

// Single shared instance of FirebaseFirestoreServices.
final firestoreServicesProvider = Provider<FirebaseFirestoreServices>((ref) {
  return FirebaseFirestoreServices();
});

// Auth Provider — now properly injects FirebaseFirestoreServices.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final firestoreServices = ref.watch(firestoreServicesProvider);
  return AuthNotifier(firestoreServices);
});

/// Convenience provider for widgets that only need the profile data
/// and shouldn't rebuild on unrelated loading/error state changes.
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

class AuthState {
  AuthState({
    // form keys
    required this.signinFormKey,
    required this.signUpFormKey,
    // text editing controllers
    required this.authEmailController,
    required this.authPasswordController,
    required this.userNameController,
    required this.confirmPassController,
    required this.resetPassEmailController,
    // loading & error
    this.isLoading = false,
    this.errorMessage,
    // current user profile (Firestore) — separate from FirebaseAuth's User
    this.user,
  });

  // Form Keys
  final GlobalKey<FormState> signinFormKey;
  final GlobalKey<FormState> signUpFormKey;

  // Controllers
  final TextEditingController authEmailController;
  final TextEditingController authPasswordController;
  final TextEditingController userNameController;
  final TextEditingController confirmPassController;
  final TextEditingController resetPassEmailController;

  // State
  final bool isLoading;
  final String? errorMessage;

  /// The Firestore user profile. This is intentionally `UserModel?`, NEVER
  /// FirebaseAuth's `User` — those two represent different concerns
  /// (authentication identity vs. app profile data).
  final UserModel? user;

  /// Sentinel used so `copyWith` can distinguish "don't touch `user`"
  /// from "explicitly set `user` to null" (needed for sign-out/clearUser).
  static const Object _unset = Object();

  AuthState copyWith({
    GlobalKey<FormState>? signinFormKey,
    GlobalKey<FormState>? signUpFormKey,
    TextEditingController? authEmailController,
    TextEditingController? authPasswordController,
    TextEditingController? userNameController,
    TextEditingController? confirmPassController,
    TextEditingController? resetPassEmailController,
    bool? isLoading,
    String? errorMessage,
    Object? user = _unset,
  }) {
    return AuthState(
      signinFormKey: signinFormKey ?? this.signinFormKey,
      signUpFormKey: signUpFormKey ?? this.signUpFormKey,
      authEmailController: authEmailController ?? this.authEmailController,
      authPasswordController: authPasswordController ?? this.authPasswordController,
      userNameController: userNameController ?? this.userNameController,
      confirmPassController: confirmPassController ?? this.confirmPassController,
      resetPassEmailController: resetPassEmailController ?? this.resetPassEmailController,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: identical(user, _unset) ? this.user : user as UserModel?,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._firestoreServices)
    : super(
        AuthState(
          signinFormKey: GlobalKey<FormState>(),
          signUpFormKey: GlobalKey<FormState>(),
          authEmailController: TextEditingController(),
          authPasswordController: TextEditingController(),
          userNameController: TextEditingController(),
          confirmPassController: TextEditingController(),
          resetPassEmailController: TextEditingController(),
          // No more `UserModel()` — user profile starts unknown until
          // Firestore confirms it (or the user signs out).
          user: null,
        ),
      ) {
    _initAuthListener();
  }

  final FirebaseFirestoreServices _firestoreServices;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Listens to FirebaseAuth state changes (login/logout from ANY source —
  /// email, Google, token refresh, sign-out elsewhere, etc.) and keeps the
  /// Firestore-backed `UserModel` in sync accordingly.
  void _initAuthListener() {
    _auth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        // Logged in → pull the profile from Firestore.
        loadUser();
      } else {
        // Logged out → clear local profile state.
        clearUser();
      }
    });
  }

  // ---------------------------------------------------------------------
  // Firestore profile methods
  // ---------------------------------------------------------------------

  /// Used after EMAIL/PASSWORD signup.
  /// Creates the user doc if missing, or merges/updates it if it exists.
  Future<void> createOrUpdateUser(UserModel user) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _firestoreServices.saveUser(user, onlyIfNew: false);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Used after GOOGLE SIGN-IN.
  /// Creates the user doc ONLY if it doesn't already exist, preventing
  /// accidental overwrites of an existing profile (e.g. skills, about).
  Future<void> createUserIfNew(UserModel user) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _firestoreServices.saveUser(user, onlyIfNew: true);
      // Reload from Firestore to reflect the actual persisted document
      // (in case it already existed with different, user-edited data).
      await loadUser();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Loads the current user's profile from Firestore into state.
  /// Called automatically by the auth listener, and after sign-in flows.
  Future<void> loadUser() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final fetchedUser = await _firestoreServices.getUser();
      state = state.copyWith(user: fetchedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Clears local user profile state (e.g. on sign-out).
  /// Deliberately does NOT recreate AuthState — that would destroy the
  /// controllers/form keys that live for the lifetime of the app.
  void clearUser() {
    state = state.copyWith(user: null, errorMessage: null, isLoading: false);
  }

  // ---------------------------------------------------------------------
  // FirebaseAuth methods
  // ---------------------------------------------------------------------

  // SIGN UP (email/password)
  Future<bool> signUp() async {
    if (!state.signUpFormKey.currentState!.validate()) return false;

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final result = await _auth.createUserWithEmailAndPassword(
        email: state.authEmailController.text.trim(),
        password: state.authPasswordController.text.trim(),
      );

      final firebaseUser = result.user;
      if (firebaseUser == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'Sign up succeeded but no user was returned.');
        return false;
      }

      // Build the Firestore profile from FirebaseAuth's uid/email + the
      // name entered in the form — NOT from the FirebaseAuth User object.
      final newUser = UserModel(
        id: firebaseUser.uid,
        name: state.userNameController.text.trim(),
        email: firebaseUser.email ?? state.authEmailController.text.trim(),
      );

      await createOrUpdateUser(newUser);
      return state.errorMessage == null;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // SIGN IN (email/password)
  Future<bool> signIn() async {
    if (!state.signinFormKey.currentState!.validate()) return false;

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _auth.signInWithEmailAndPassword(
        email: state.authEmailController.text.trim(),
        password: state.authPasswordController.text.trim(),
      );

      // Don't assign FirebaseAuth's User to state.user — load the actual
      // Firestore profile instead.
      await loadUser();
      return state.errorMessage == null;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // GOOGLE SIGN IN
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Reference the initialized singleton instance
      final googleSignIn = GoogleSignIn.instance;

      // 2. Authentication (Identity Flow)
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // 3. Authorization (Permissions Flow)
      final List<String> scopes = ['email', 'profile'];
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(scopes);

      // 4. Retrieve Identity Details
      final authDetails = googleUser.authentication;

      // 5. Create the Firebase Credential
      final credential = GoogleAuthProvider.credential(
        idToken: authDetails.idToken,
        accessToken: clientAuth.accessToken,
      );

      // 6. Sign in to Firebase Auth
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Google sign-in succeeded but no user was returned.',
        );
        return false;
      }

      // Build the Firestore profile from FirebaseAuth/Google data, with a
      // safe fallback if displayName/email come back null.
      final googleUserModel = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? googleUser.displayName ?? 'User',
        email: firebaseUser.email ?? googleUser.email,
        profileImageUrl: firebaseUser.photoURL,
      );

      // Never overwrite an existing profile on repeat Google logins.
      await createUserIfNew(googleUserModel);
      return state.errorMessage == null;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      // Catch generic/platform exceptions thrown by the Google SDK
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // RESET PASSWORD (Standard Email Link Flow)
  Future<bool> resetPassword() async {
    if (state.resetPassEmailController.text.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email address.');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _auth.sendPasswordResetEmail(email: state.resetPassEmailController.text.trim());

      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
    // The authStateChanges() listener will also fire and call clearUser(),
    // but we clear immediately for a snappier UI response.
    clearUser();
  }

  // CHECK LOGIN
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Clear Sign Up/Sign In Controllers
  void clearAuth() {
    state.userNameController.clear();
    state.authEmailController.clear();
    state.authPasswordController.clear();
  }

  // Clear Reset Email Controller
  void clearReset() {
    state.resetPassEmailController.clear();
  }

  @override
  void dispose() {
    state.authEmailController.dispose();
    state.authPasswordController.dispose();
    state.userNameController.dispose();
    state.confirmPassController.dispose();
    state.resetPassEmailController.dispose();
    super.dispose();
  }
}
