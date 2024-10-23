import 'package:assets_inventory_app_ghum/common/models/user.dart';
import 'package:assets_inventory_app_ghum/common/utils.dart';
import 'package:assets_inventory_app_ghum/features/auth/provider/user_provider.dart';
import 'package:assets_inventory_app_ghum/services/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref.watch(authRepositoryProvider), ref);
});

final authStateChangeProvider = StreamProvider<User?>((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

class AuthController extends StateNotifier<bool> {
  AuthController(AuthRepository authRepository, Ref ref)
      : _authRepository = authRepository,
        _ref = ref,
        super(false);
  final AuthRepository _authRepository;
  final Ref _ref;

  Future<void> signUpWithEmailAndPassword(
      String name, String email, String password, BuildContext context) async {
    state = true;
    final user = await _authRepository.signUpWithEmail(
        email: email, name: name, password: password);
    state = false;
    user.fold((l) => showSnackbar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => r);
      showSnackbar(context, "Account created successfully");
      Navigator.pop(context);
    });
  }

  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    state = true;
    final ref = await _authRepository.signInWithEmailAndPassword(
        email: email, password: password);
    state = false;
    ref.fold((l) => showSnackbar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => r);
      showSnackbar(context, "Sign in successful");
      Navigator.pop(context);
    });
  }

  void logOut() {
    _authRepository.logOut();
    _ref.read(userProvider.notifier).update((state) => null);
  }

  User? getSignedInUser() => _authRepository.getSignedInUser();
  Stream<User?> get authStateChange => _authRepository.authStateChange;

  Future<IUser?> getUserData(String uid, BuildContext context) async {
    IUser? user;
    final ref = await _authRepository.getUserData(uid);
    ref.fold((l) => showSnackbar(context, l.message), (r) => user = r);
    return user;
  }
}
