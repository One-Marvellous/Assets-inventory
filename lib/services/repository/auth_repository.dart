import 'dart:developer';

import 'package:assets_inventory_app_ghum/common/models/user.dart';
import 'package:assets_inventory_app_ghum/common/utils/failure.dart';
import 'package:assets_inventory_app_ghum/common/utils/type_def.dart';
import 'package:assets_inventory_app_ghum/services/firebase/firebase_constants.dart';
import 'package:assets_inventory_app_ghum/services/firebase/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
      auth: ref.watch(fireBaseAuthProvider),
      firestore: ref.watch(firestoreProvider));
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  FutureEither<IUser?> signUpWithEmail(
      {required String email,
      required String name,
      required String password}) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        // IUser
        IUser newUser = IUser(
            email: email,
            name: name,
            role: "user", // This is later changed by the admin
            uid: user.uid);

        // Store the user document in Firestore with the UID
        await _users.doc(user.uid).set(newUser.toMap());
        return right(newUser);
      }
      return right(null);
    } on FirebaseAuthException catch (e) {
      log(e.message!);
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<IUser> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      IUser user = await getUserDataStream(userCredential.user!.uid).first;

      log(user.toString());

      return right(user);
    } on FirebaseAuthException catch (e) {
      log(e.message!);
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<IUser> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _users.doc(uid).get();
      log(userDoc.data().toString());
      return right(IUser.fromMap(userDoc.data()! as Map<String, dynamic>));
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<IUser> getUserDataStream(String uid) {
    return _users.doc(uid).snapshots().map(
          (event) => IUser.fromMap(
            event.data() as Map<String, dynamic>,
          ),
        );
  }

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.userCollection);

  void logOut() async {
    await _auth.signOut();
  }

  User? getSignedInUser() => _auth.currentUser;

  Stream<User?> get authStateChange => _auth.authStateChanges();
}
