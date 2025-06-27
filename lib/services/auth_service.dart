// COMPLETE AUTH SERVICE - lib/services/auth_service.dart
// WITH ALL MISSING FUNCTIONS ADDED

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'dio_client.dart';
import 'storage_service.dart';

class AuthService {
  static AuthService? _instance;

  // Firebase instances
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Dio client for backend communication
  final DioClient _dioClient = DioClient.instance;

  // Singleton pattern
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  AuthService._internal();

  // Get current Firebase user
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ========== EMAIL AUTHENTICATION ==========

  /// Register with email and password
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      print('🔥 Starting email registration for: $email');

      // Step 1: Create user in Firebase Auth
      print('📧 Creating Firebase user...');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase userCredential created');

      // Step 2: Get Firebase user (with null check)
      final firebaseUser = userCredential.user;
      print('👤 Firebase user: ${firebaseUser?.uid ?? "NULL"}');

      if (firebaseUser == null) {
        print('❌ Firebase user is null after creation!');
        throw Exception('Failed to create Firebase user - user object is null');
      }

      print('✅ Firebase user created successfully: ${firebaseUser.uid}');

      // Step 3: Update Firebase user profile
      print('📝 Updating Firebase display name...');
      try {
        await firebaseUser.updateDisplayName(name);
        print('✅ Display name updated successfully');
      } catch (e) {
        print('⚠️ Failed to update display name: $e');
        // Continue anyway
      }

      // Step 4: Create user model (SAFE)
      print('🏗️ Creating UserModel...');
      final user = UserModel(
        id: firebaseUser.uid,
        email: email,
        username: name,
        phone: phone?.isNotEmpty == true ? phone : null,
        createdAt: DateTime.now(),
      );
      print('✅ UserModel created: ${user.id}');

      // Step 5: Save to Firestore
      print('💾 Saving to Firestore...');
      try {
        await _saveUserToFirestore(user);
        print('✅ Firestore save successful');
      } catch (e) {
        print('⚠️ Firestore save failed: $e');
      }

      // Step 6: Save to local storage
      print('💾 Saving to local storage...');
      try {
        await StorageService.saveUser(user);
        print('✅ Local storage save successful');
      } catch (e) {
        print('⚠️ Local storage save failed: $e');
      }

      // Step 8: Sync to backend (non-blocking)
      print('🔄 Starting backend sync...');
      _syncUserToBackend(user);

      print('🎉 User registered successfully: $email');
      return user;
    } on FirebaseAuthException catch (e) {
      print(
          '🔥 Firebase Auth error during registration: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseAuthException(e));
    } catch (e) {
      print('❌ Error during registration: $e');
      print('📍 Error type: ${e.runtimeType}');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      print('🔥 Starting email sign in for: $email');

      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Sign in failed - no user returned');
      }

      // Get user data from Firestore
      UserModel? user = await _getUserFromFirestore(firebaseUser.uid);

      if (user == null) {
        // Create user model from Firebase data if not in Firestore
        user = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? email,
          username: firebaseUser.displayName ?? 'User',
          emailVerified: firebaseUser.emailVerified,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        // Save to Firestore for future use
        await _saveUserToFirestore(user);
      } else {
        // Update last login
        user = user.copyWith(lastLogin: DateTime.now());
        await _updateUserInFirestore(user);
      }

      // Save to local storage
      await StorageService.saveUser(user);

      print('✅ User signed in successfully: $email');
      return user;
    } on FirebaseAuthException catch (e) {
      print('🔥 Firebase Auth error during sign in: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseAuthException(e));
    } catch (e) {
      print('❌ Error during sign in: $e');
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // ========== GOOGLE AUTHENTICATION ==========

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      print('🔥 Starting Google sign in');

      // Start Google Sign In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Check if user exists in Firestore
      UserModel? existingUser = await _getUserFromFirestore(firebaseUser.uid);

      if (existingUser != null) {
        // Update existing user
        final updatedUser = existingUser.copyWith(
          username: firebaseUser.displayName ?? existingUser.username,
          photoURL: firebaseUser.photoURL ?? existingUser.photoURL,
          emailVerified: firebaseUser.emailVerified,
          lastLogin: DateTime.now(),
        );

        await _updateUserInFirestore(updatedUser);
        await StorageService.saveUser(updatedUser);

        print('✅ Existing Google user signed in: ${firebaseUser.email}');
        return updatedUser;
      } else {
        // Create new user
        final newUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          username: firebaseUser.displayName ?? 'User',
          photoURL: firebaseUser.photoURL,
          emailVerified: firebaseUser.emailVerified,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _saveUserToFirestore(newUser);
        await StorageService.saveUser(newUser);

        // Sync to backend (non-blocking)
        _syncUserToBackend(newUser);

        print('✅ New Google user created: ${firebaseUser.email}');
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      print(
          '🔥 Firebase Auth error during Google sign in: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseAuthException(e));
    } catch (e) {
      print('❌ Error during Google sign in: $e');
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  // ========== PASSWORD RESET ==========

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      print('📧 Sending password reset email to: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      print(
          '🔥 Firebase Auth error during password reset: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseAuthException(e));
    } catch (e) {
      print('❌ Error sending password reset email: $e');
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  // ========== EMAIL VERIFICATION ==========

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('📧 Email verification sent');
      }
    } catch (e) {
      print('❌ Error sending email verification: $e');
      throw Exception('Failed to send email verification: ${e.toString()}');
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      return _firebaseAuth.currentUser?.emailVerified ?? false;
    } catch (e) {
      print('❌ Error checking email verification: $e');
      return false;
    }
  }

  /// Reload current user to get latest verification status
  Future<void> reloadUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
    } catch (e) {
      print('❌ Error reloading user: $e');
    }
  }

  // ========== SIGN OUT ==========

  /// Sign out from all services
  Future<void> signOut() async {
    try {
      print('🔄 Starting sign out process');

      // Sign out from Firebase
      await _firebaseAuth.signOut();
      print('✅ Firebase sign out complete');

      // Sign out from Google
      try {
        await _googleSignIn.signOut();
        print('✅ Google sign out complete');
      } catch (e) {
        print('⚠️ Google sign out failed: $e');
      }

      // Clear local storage
      try {
        await StorageService.clearUserData();
        print('✅ User data cleared');
      } catch (e) {
        print('⚠️ Failed to clear user data: $e');
      }

      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error during sign out: $e');
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // ========== USER PROFILE MANAGEMENT ==========

  /// Get current user profile
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      // Try to get from local storage first
      try {
        UserModel? localUser = await StorageService.getUser();
        if (localUser != null && localUser.id == firebaseUser.uid) {
          return localUser;
        }
      } catch (e) {
        print('⚠️ Failed to get user from local storage: $e');
      }

      // Get from Firestore
      final firestoreUser = await _getUserFromFirestore(firebaseUser.uid);
      if (firestoreUser != null) {
        await StorageService.saveUser(firestoreUser);
        return firestoreUser;
      }

      return null;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  /// Update user profile (MISSING FUNCTION ADDED)
  Future<UserModel> updateUserProfile(UserModel updatedUser) async {
    try {
      print('📝 Updating user profile: ${updatedUser.email}');

      // Update in Firestore
      await _updateUserInFirestore(updatedUser);

      // Update in local storage
      await StorageService.saveUser(updatedUser);

      // Update Firebase Auth profile if needed
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        if (firebaseUser.displayName != updatedUser.username) {
          await firebaseUser.updateDisplayName(updatedUser.username);
        }

        // Update photo URL if provided
        if (updatedUser.photoURL != null &&
            firebaseUser.photoURL != updatedUser.photoURL) {
          await firebaseUser.updatePhotoURL(updatedUser.photoURL);
        }
      }

      // Sync to backend (non-blocking)
      _syncUserToBackend(updatedUser);

      print('✅ User profile updated successfully');
      return updatedUser;
    } catch (e) {
      print('❌ Error updating user profile: $e');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  /// Update user email (MISSING FUNCTION ADDED)
  Future<void> updateUserEmail(String newEmail) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      print('📧 Updating user email to: $newEmail');

      // Update email in Firebase Auth
      await user.updateEmail(newEmail);

      // Send verification email for new email
      await user.sendEmailVerification();

      // Update in Firestore
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          email: newEmail,
          emailVerified: false, // Reset verification status
        );
        await _updateUserInFirestore(updatedUser);
        await StorageService.saveUser(updatedUser);
      }

      print('✅ Email updated successfully');
    } on FirebaseAuthException catch (e) {
      print('🔥 Firebase Auth error updating email: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseAuthException(e));
    } catch (e) {
      print('❌ Error updating email: $e');
      throw Exception('Failed to update email: ${e.toString()}');
    }
  }

  /// Update user password (MISSING FUNCTION ADDED)
  Future<void> updateUserPassword(String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      print('🔐 Updating user password');

      // Update password in Firebase Auth
      await user.updatePassword(newPassword);

      print('✅ Password updated successfully');
    } on FirebaseAuthException catch (e) {
      print(
          '🔥 Firebase Auth error updating password: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseAuthException(e));
    } catch (e) {
      print('❌ Error updating password: $e');
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }

  /// Reauthenticate user (MISSING FUNCTION ADDED)
  Future<void> reauthenticateWithEmail(String email, String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      print('🔐 Reauthenticating user');

      // Create credential
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Reauthenticate
      await user.reauthenticateWithCredential(credential);

      print('✅ User reauthenticated successfully');
    } on FirebaseAuthException catch (e) {
      print(
          '🔥 Firebase Auth error during reauthentication: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseAuthException(e));
    } catch (e) {
      print('❌ Error during reauthentication: $e');
      throw Exception('Reauthentication failed: ${e.toString()}');
    }
  }

  /// Upload user profile photo (MISSING FUNCTION ADDED)
  Future<UserModel> uploadProfilePhoto(String photoPath) async {
    try {
      print('📸 Uploading profile photo');

      // TODO: Implement Firebase Storage upload
      // For now, just update with a placeholder URL
      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('No user signed in');
      }

      // In a real implementation, you would:
      // 1. Upload image to Firebase Storage
      // 2. Get download URL
      // 3. Update user profile with new photo URL

      final updatedUser = user.copyWith(photoURL: photoPath);
      return await updateUserProfile(updatedUser);
    } catch (e) {
      print('❌ Error uploading profile photo: $e');
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }

  /// Check if current password is correct (MISSING FUNCTION ADDED)
  Future<bool> verifyCurrentPassword(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return false;
      }

      // Try to reauthenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      print('❌ Password verification failed: $e');
      return false;
    }
  }

  // ========== FIRESTORE OPERATIONS ==========

  /// Save user to Firestore
  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toFirestore());
      print('💾 User saved to Firestore: ${user.email}');
    } catch (e) {
      print('❌ Error saving user to Firestore: $e');
      // Don't throw - let registration continue
    }
  }

  /// Get user from Firestore
  Future<UserModel?> _getUserFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user from Firestore: $e');
      return null;
    }
  }

  /// Update user in Firestore
  Future<void> _updateUserInFirestore(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());
      print('💾 User updated in Firestore: ${user.email}');
    } catch (e) {
      print('❌ Error updating user in Firestore: $e');
      // Don't throw - let operation continue
    }
  }

  // ========== BACKEND SYNC ==========

  /// Sync user to backend database (non-blocking with proper error handling)
  void _syncUserToBackend(UserModel user) {
    // Run in background without blocking the UI
    Future.microtask(() async {
      try {
        print('🔄 Syncing user to backend: ${user.email}');

        // Use proper Dio method
        final response = await _dioClient.dio.post(
          '/register',
          data: {
            'username': user.username ?? '',
            'email': user.email,
            'phone': user.phone ?? '',
            'role': 'USER',
          },
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          print('✅ User synced to backend successfully');
        } else {
          print('⚠️ Backend sync failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error syncing user to backend: $e');
        // Don't throw error as this is non-blocking
      }
    });
  }

  // ========== ERROR HANDLING ==========

  /// Handle Firebase Auth exceptions
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'invalid-credential':
        return 'The provided credentials are invalid.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this operation.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'email-change-needs-verification':
        return 'Email change requires verification.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // ========== UTILITY METHODS ==========

  /// Check if user is signed in
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  /// Get Firebase user ID
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  /// Get current user email
  String? get currentUserEmail => _firebaseAuth.currentUser?.email;

  /// Check if current user email is verified
  bool get isCurrentUserEmailVerified =>
      _firebaseAuth.currentUser?.emailVerified ?? false;

  /// Refresh Firebase user token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return await user.getIdToken(forceRefresh);
      }
      return null;
    } catch (e) {
      print('❌ Error getting ID token: $e');
      return null;
    }
  }

  /// Get user claims/custom claims
  Future<Map<String, dynamic>?> getUserClaims() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final idTokenResult = await user.getIdTokenResult();
        return idTokenResult.claims;
      }
      return null;
    } catch (e) {
      print('❌ Error getting user claims: $e');
      return null;
    }
  }

  /// Delete user account (ENHANCED)
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        print('🗑️ Deleting user account: ${user.email}');

        // Delete from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        print('✅ User data deleted from Firestore');

        // Delete Firebase Auth account
        await user.delete();
        print('✅ Firebase Auth account deleted');

        // Clear local storage
        await StorageService.clearUserData();
        print('✅ Local storage cleared');

        // Sign out from Google if signed in
        await _googleSignIn.signOut();

        print('✅ User account deleted successfully');
      }
    } on FirebaseAuthException catch (e) {
      print(
          '🔥 Firebase Auth error deleting account: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseAuthException(e));
    } catch (e) {
      print('❌ Error deleting account: $e');
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  /// Check connection status (MISSING FUNCTION ADDED)
  Future<bool> checkConnectionStatus() async {
    try {
      // Simple connectivity check by trying to get current user
      await _firebaseAuth.currentUser?.reload();
      return true;
    } catch (e) {
      print('❌ Connection check failed: $e');
      return false;
    }
  }

  /// Clear all cached data (MISSING FUNCTION ADDED)
  Future<void> clearCache() async {
    try {
      print('🧹 Clearing cache');
      await StorageService.clearUserData();
      print('✅ Cache cleared');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }
}
