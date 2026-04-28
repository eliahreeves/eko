import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/interfaces/user.dart';
import 'package:eko_app/types/auth.dart';
import 'package:eko_app/utilities/constants.dart';
// Necessary for code-generation to work
part '../generated/providers/auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthModel build() {
    _init();
    return AuthModel.loading();
  }

  void _init() {
    // TODO This should also handle presence
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        state = AuthModel.signedOut();
      } else {
        state = state.copyWith(
          uid: user.uid,
          isLoading: false,
          email: user.email,
          emailVerified: user.emailVerified,
          creationTime: user.metadata.creationTime,
        );
      }
    });
  }

  Future<String> signUp({
    required String email,
    required String password,
    required String username,
    required String name,
    required String birthday,
  }) async {
    try {
      final UserCredential user =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (user.user?.uid == null) return 'unknown';

      final userData = _buildNewUserDoc(
        uid: user.user!.uid,
        email: email.trim(),
        username: username,
        name: name,
        birthday: birthday,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user?.uid)
          .set(userData);

      await addFCM(user.user!.uid);

      await user.user!.sendEmailVerification();

      return ('success');
    } on FirebaseAuthException catch (e) {
      return (e.code);
    }
  }

  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      if (user.user != null) await addFCM(user.user!.uid);
      return ('success');
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      return (e.code);
    }
  }

  Future<void> deleteAccount() async {
    await FirebaseAuth.instance.currentUser?.delete();
  }

  Future<void> sendEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }

  Future<void> reloadAuthUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      state = state.copyWith(
        email: user.email,
        emailVerified: user.emailVerified,
      );
    }
  }

  Future<String> updatePassword(String newPassword) async {
    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<String> updateEmailBeforeVerify(String newEmail) async {
    try {
      await FirebaseAuth.instance.currentUser
          ?.verifyBeforeUpdateEmail(newEmail.trim());
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<void> signInWithGoogle() async {
    // google sign in
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // firebase sign in
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user!;

    // Check if user document exists
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await userRef.get();

    if (!docSnapshot.exists) {
      final email = user.email ?? '';
      String emailPrefix = email
          .split('@')[0]
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_]'), '_');
      if (emailPrefix.length > 18) {
        emailPrefix = emailPrefix.substring(0, 18);
      }
      while (emailPrefix.length < 3) {
        emailPrefix += '_';
      }
      String username = emailPrefix;
      if (!(await isUsernameAvailable(emailPrefix))) {
        final suffix =
            (DateTime.now().millisecondsSinceEpoch % 900000) + 100000;
        username = '${emailPrefix}_$suffix';
      }
      if (!isUsernameValid(username)) {
        username = 'user_${DateTime.now().millisecondsSinceEpoch % 1000000}';
      }

      final userData = _buildNewUserDoc(
        uid: user.uid,
        email: email,
        username: username,
        name: googleUser.displayName ?? email.split('@')[0],
        birthday: null,
        photoUrl: googleUser.photoUrl,
      );

      await userRef.set(userData);
    }

    await addFCM(user.uid);
  }

  Map<String, dynamic> _buildNewUserDoc({
    required String uid,
    required String email,
    required String username,
    required String name,
    required String? birthday,
    String? photoUrl,
  }) {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'name': name,
      'fcmTokens': [],
      'blockedUsers': [],
      'isVerified': false,
      'share_online_status': true,
      'profileData': {
        'birthday': birthday,
        'likedPosts': [],
        'dislikedPosts': [],
        'pollVotes': {},
        'bio': '',
        'followers': [],
        'following': [],
        'likes': 0,
        'dislikes': 0,
        'profilePicture': photoUrl ?? defaultProfilePictureUrl,
      },
    };
  }
}
