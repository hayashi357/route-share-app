import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_model.dart';
import '../utils/app_exceptions.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();

      final newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        emailVerified: false,
      );

      await _database
          .ref('users/${userCredential.user!.uid}')
          .set(newUser.toMap());

      await userCredential.user?.sendEmailVerification();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseAuthError(e), code: e.code);
    }
  }

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseAuthError(e), code: e.code);
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw AuthException('キャンセルされました');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      final snapshot = await _database
          .ref('users/${userCredential.user!.uid}')
          .get();

      if (!snapshot.exists) {
        final newUser = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName ?? 'ユーザー',
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          emailVerified: true,
        );

        await _database
            .ref('users/${userCredential.user!.uid}')
            .set(newUser.toMap());
      }

      return userCredential;
    } catch (e) {
      throw AuthException('Googleでのログインに失敗しました: $e');
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    try {
      final result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final credential = FacebookAuthProvider.credential(accessToken.token);

        final userCredential = await _firebaseAuth.signInWithCredential(credential);

        final snapshot = await _database
            .ref('users/${userCredential.user!.uid}')
            .get();

        if (!snapshot.exists) {
          final newUser = UserModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            displayName: userCredential.user!.displayName ?? 'ユーザー',
            photoUrl: userCredential.user!.photoURL,
            createdAt: DateTime.now(),
            emailVerified: true,
          );

          await _database
              .ref('users/${userCredential.user!.uid}')
              .set(newUser.toMap());
        }

        return userCredential;
      } else {
        throw AuthException('Facebookでのログインに失敗しました');
      }
    } catch (e) {
      throw AuthException('Facebookでのログインに失敗しました: $e');
    }
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: appleCredential.state,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);

      final snapshot = await _database
          .ref('users/${userCredential.user!.uid}')
          .get();

      if (!snapshot.exists) {
        final fullName = appleCredential.familyName ?? appleCredential.givenName ?? 'ユーザー';
        final newUser = UserModel(
          uid: userCredential.user!.uid,
          email: appleCredential.email ?? '',
          displayName: fullName,
          createdAt: DateTime.now(),
          emailVerified: true,
        );

        await _database
            .ref('users/${userCredential.user!.uid}')
            .set(newUser.toMap());
      }

      return userCredential;
    } catch (e) {
      throw AuthException('Appleでのログインに失敗しました: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseAuthError(e), code: e.code);
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      await _facebookAuth.logOut();
    } catch (e) {
      throw AuthException('ログアウトに失敗しました: $e');
    }
  }

  String _getFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'パスワードが弱すぎます';
      case 'email-already-in-use':
        return 'このメールアドレスは既に登録されています';
      case 'invalid-email':
        return '無効なメールアドレスです';
      case 'user-not-found':
        return 'このメールアドレスは登録されていません';
      case 'wrong-password':
        return 'パスワードが間違っています';
      case 'user-disabled':
        return 'このアカウントは無効化されています';
      case 'too-many-requests':
        return 'リクエストが多すぎます。後でお試しください';
      case 'operation-not-allowed':
        return 'この操作は許可されていません';
      default:
        return 'エラーが発生しました: ${e.message}';
    }
  }
}
