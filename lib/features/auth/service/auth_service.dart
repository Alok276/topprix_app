import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/features/auth/service/backend_user_service.dart';
// Import your backend service
// import 'backend_user_service.dart';

// User Role Enum
enum UserRole { user, retailer }

// TopPrix User Model (for Firestore backup)
class TopPrixUser {
  final String id;
  final String email;
  final String? phone;
  final String? name;
  final String role; // USER, RETAILER
  final String? location;
  final String? profilePicture;
  final String? stripeCustomerId;
  final bool hasActiveSubscription;
  final String? subscriptionStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  TopPrixUser({
    required this.id,
    required this.email,
    this.phone,
    this.name,
    required this.role,
    this.location,
    this.profilePicture,
    this.stripeCustomerId,
    this.hasActiveSubscription = false,
    this.subscriptionStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TopPrixUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TopPrixUser(
      id: doc.id,
      email: data['email'] ?? '',
      phone: data['phone'],
      name: data['name'],
      role: data['role'] ?? 'USER',
      location: data['location'],
      profilePicture: data['profilePicture'],
      stripeCustomerId: data['stripeCustomerId'],
      hasActiveSubscription: data['hasActiveSubscription'] ?? false,
      subscriptionStatus: data['subscriptionStatus'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phone': phone,
      'name': name,
      'role': role,
      'location': location,
      'profilePicture': profilePicture,
      'stripeCustomerId': stripeCustomerId,
      'hasActiveSubscription': hasActiveSubscription,
      'subscriptionStatus': subscriptionStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Auth State
class AuthState {
  final User? firebaseUser;
  final TopPrixUser? topPrixUser;
  final BackendUser? backendUser;
  final bool isLoading;
  final String? error;

  AuthState({
    this.firebaseUser,
    this.topPrixUser,
    this.backendUser,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? firebaseUser,
    TopPrixUser? topPrixUser,
    BackendUser? backendUser,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      topPrixUser: topPrixUser ?? this.topPrixUser,
      backendUser: backendUser ?? this.backendUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => firebaseUser != null && backendUser != null;
  bool get isRetailer => backendUser?.role == 'RETAILER';
  bool get isCustomer => backendUser?.role == 'USER';
}

// TopPrix Auth Service
class TopPrixAuthService extends StateNotifier<AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final BackendUserService _backendService = BackendUserService();

  TopPrixAuthService() : super(AuthState()) {
    // Listen to auth state changes
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Auth state change listener
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      try {
        state = state.copyWith(isLoading: true);

        // Get user data from backend
        final backendResponse =
            await _backendService.getUser(email: firebaseUser.email!);

        if (backendResponse.success && backendResponse.data != null) {
          // Also get Firestore data as backup
          final topPrixUser = await _getTopPrixUser(firebaseUser.uid);

          state = state.copyWith(
            firebaseUser: firebaseUser,
            backendUser: backendResponse.data,
            topPrixUser: topPrixUser,
            isLoading: false,
            error: null,
          );
        } else {
          // User not found in backend, might be a Google sign-in user
          state = state.copyWith(
            firebaseUser: firebaseUser,
            backendUser: null,
            isLoading: false,
            error: 'User not found in backend',
          );
        }
      } catch (e) {
        state = state.copyWith(
          firebaseUser: firebaseUser,
          backendUser: null,
          isLoading: false,
          error: e.toString(),
        );
      }
    } else {
      state = AuthState();
    }
  }

  // Get TopPrix user data from Firestore (backup storage)
  Future<TopPrixUser?> _getTopPrixUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return TopPrixUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching Firestore user: $e');
      return null;
    }
  }

  // Sign up with email and password - COMPLETE BACKEND INTEGRATION
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    String? location,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      print('🚀 Starting signup process for: $email');

      // STEP 1: Create Firebase user first
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create Firebase user account');
      }

      print('✅ Firebase user created: ${userCredential.user!.uid}');

      // STEP 2: Update Firebase display name
      await userCredential.user!.updateDisplayName(name);

      // STEP 3: Register user in backend API
      print('📡 Registering user in backend...');
      final backendResponse = await _backendService.registerUser(
        email: email,
        name: name,
        phone: phone,
        role: role == UserRole.user ? 'USER' : 'RETAILER',
        location: location,
      );

      if (!backendResponse.success) {
        // If backend registration fails, delete Firebase user to maintain consistency
        print('❌ Backend registration failed, cleaning up Firebase user...');
        await userCredential.user!.delete();
        throw Exception(backendResponse.message);
      }

      print('✅ Backend user created successfully');

      // STEP 4: Create TopPrix user document in Firestore as backup
      final topPrixUser = TopPrixUser(
        id: userCredential.user!.uid,
        email: email,
        phone: phone,
        name: name,
        role: role == UserRole.user ? 'USER' : 'RETAILER',
        location: location,
        profilePicture: _getDefaultProfilePicture(),
        hasActiveSubscription: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(topPrixUser.toFirestore());

      print('✅ Firestore backup created');

      // STEP 5: Update state with all user data
      state = state.copyWith(
        firebaseUser: userCredential.user,
        backendUser: backendResponse.data,
        topPrixUser: topPrixUser,
        isLoading: false,
      );

      print(
          '🎉 Signup completed successfully for ${role == UserRole.user ? 'Customer' : 'Retailer'}');
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code}');
      state = state.copyWith(isLoading: false, error: _getAuthErrorMessage(e));
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      print('❌ Signup error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      throw Exception(e.toString());
    }
  }

  // Sign in with email and password - BACKEND ROLE CHECKING
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      print('🔐 Starting login process for: $email');

      // STEP 1: Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Firebase');
      }

      print('✅ Firebase authentication successful');

      // STEP 2: Get user data from backend (this contains the role!)
      print('📡 Fetching user data from backend...');
      final backendResponse = await _backendService.getUser(email: email);

      if (!backendResponse.success || backendResponse.data == null) {
        // User exists in Firebase but not in backend - data inconsistency
        await _firebaseAuth.signOut();
        throw Exception('User account not found. Please contact support.');
      }

      print('✅ Backend user data retrieved');
      print('👤 User role: ${backendResponse.data!.role}');

      // STEP 3: Get Firestore backup data (optional)
      final topPrixUser = await _getTopPrixUser(userCredential.user!.uid);

      // STEP 4: Update state - navigation will be handled by UI based on role
      state = state.copyWith(
        firebaseUser: userCredential.user,
        backendUser: backendResponse.data,
        topPrixUser: topPrixUser,
        isLoading: false,
      );

      print(
          '🎉 Login completed successfully for ${backendResponse.data!.role}');
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code}');
      state = state.copyWith(isLoading: false, error: _getAuthErrorMessage(e));
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      print('❌ Login error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      throw Exception(e.toString());
    }
  }

  // Sign in with Google (Customer only) - BACKEND SYNC
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      print('🔐 Starting Google Sign-In...');

      // Begin Google sign in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return; // User cancelled the sign-in
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Google');
      }

      print('✅ Google Sign-In successful');

      // Sync with backend (create if doesn't exist, get if exists)
      print('📡 Syncing with backend...');
      final backendResponse = await _backendService.syncFirebaseUser(
        email: userCredential.user!.email!,
        name: userCredential.user!.displayName ?? 'Google User',
        role: 'USER', // Google sign-in defaults to customer
      );

      if (!backendResponse.success) {
        throw Exception(backendResponse.message);
      }

      print('✅ Backend sync completed');

      // Update/Create Firestore backup
      final topPrixUser = TopPrixUser(
        id: userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: userCredential.user!.displayName,
        role: 'USER',
        profilePicture:
            userCredential.user!.photoURL ?? _getDefaultProfilePicture(),
        hasActiveSubscription: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(topPrixUser.toFirestore(), SetOptions(merge: true));

      state = state.copyWith(
        firebaseUser: userCredential.user,
        backendUser: backendResponse.data,
        topPrixUser: topPrixUser,
        isLoading: false,
      );

      print('🎉 Google Sign-In completed successfully');
    } on FirebaseAuthException catch (e) {
      print('❌ Google Sign-In Firebase error: ${e.code}');
      state = state.copyWith(isLoading: false, error: _getAuthErrorMessage(e));
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      throw Exception(e.toString());
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _firebaseAuth.sendPasswordResetEmail(email: email);

      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _getAuthErrorMessage(e));
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      throw Exception(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);

      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);

      state = AuthState();
      print('👋 User signed out successfully');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      throw Exception(e.toString());
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? location,
    File? profileImage,
  }) async {
    try {
      final user = state.firebaseUser;
      if (user == null) throw Exception('No user logged in');

      state = state.copyWith(isLoading: true);

      // Update backend first
      final backendResponse = await _backendService.updateUser(
        email: user.email!,
        name: name?.trim(),
        phone: phone?.trim(),
        location: location?.trim(),
      );

      if (!backendResponse.success) {
        throw Exception(backendResponse.message);
      }

      // Update Firebase profile
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (name != null) {
        updates['name'] = name;
        await user.updateDisplayName(name);
      }
      if (phone != null) updates['phone'] = phone;
      if (location != null) updates['location'] = location;

      // Upload profile image if provided
      if (profileImage != null) {
        final imageUrl = await _uploadProfileImage(user.uid, profileImage);
        updates['profilePicture'] = imageUrl;
        await user.updatePhotoURL(imageUrl);
      }

      // Update Firestore backup
      await _firestore.collection('users').doc(user.uid).update(updates);

      // Update state with backend data
      state = state.copyWith(
        backendUser: backendResponse.data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      throw Exception(e.toString());
    }
  }

  // Upload profile image
  Future<String> _uploadProfileImage(String uid, File imageFile) async {
    final ref = _firebaseStorage.ref().child('profile_pictures/$uid.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Get default profile picture URL
  String _getDefaultProfilePicture() {
    return 'https://firebasestorage.googleapis.com/v0/b/your-project.firebasestorage.app/o/defaults%2Fdefault_avatar.png?alt=media';
  }

  // Get user-friendly error messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Reload current user
  Future<void> reloadUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
      await _onAuthStateChanged(_firebaseAuth.currentUser);
    }
  }

  // Dispose backend service
  @override
  void dispose() {
    super.dispose();
    _backendService.dispose();
  }
}

// Riverpod Provider
final topPrixAuthProvider =
    StateNotifierProvider<TopPrixAuthService, AuthState>((ref) {
  final service = TopPrixAuthService();

  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

// Convenience providers
final currentBackendUserProvider = Provider<BackendUser?>((ref) {
  return ref.watch(topPrixAuthProvider).backendUser;
});

final currentFirebaseUserProvider = Provider<User?>((ref) {
  return ref.watch(topPrixAuthProvider).firebaseUser;
});

final currentTopPrixUserProvider = Provider<TopPrixUser?>((ref) {
  return ref.watch(topPrixAuthProvider).topPrixUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(topPrixAuthProvider).isAuthenticated;
});

final isRetailerProvider = Provider<bool>((ref) {
  return ref.watch(topPrixAuthProvider).isRetailer;
});

final isCustomerProvider = Provider<bool>((ref) {
  return ref.watch(topPrixAuthProvider).isCustomer;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(topPrixAuthProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(topPrixAuthProvider).error;
});
