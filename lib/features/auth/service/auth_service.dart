import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topprix/features/auth/service/backend_user_service.dart';

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

  TopPrixUser copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    String? role,
    String? location,
    String? profilePicture,
    String? stripeCustomerId,
    bool? hasActiveSubscription,
    String? subscriptionStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TopPrixUser(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      role: role ?? this.role,
      location: location ?? this.location,
      profilePicture: profilePicture ?? this.profilePicture,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      hasActiveSubscription:
          hasActiveSubscription ?? this.hasActiveSubscription,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Auth State
class AuthState {
  final User? firebaseUser;
  final TopPrixUser? topPrixUser;
  final BackendUser? backendUser;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  AuthState({
    this.firebaseUser,
    this.topPrixUser,
    this.backendUser,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  AuthState copyWith({
    User? firebaseUser,
    TopPrixUser? topPrixUser,
    BackendUser? backendUser,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      topPrixUser: topPrixUser ?? this.topPrixUser,
      backendUser: backendUser ?? this.backendUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  bool get isAuthenticated =>
      isInitialized && firebaseUser != null && backendUser != null;
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

  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _isLoggedInKey = 'is_logged_in';

  TopPrixAuthService() : super(AuthState(isLoading: true)) {
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      print('Initializing authentication...');

      // Check if Firebase Auth has a current user
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser != null) {
        print('Found Firebase user: ${currentUser.email}');

        // Validate session more strictly
        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
        final storedEmail = prefs.getString(_userEmailKey);

        // Check if session is valid AND user actually completed login
        if (isLoggedIn &&
            storedEmail == currentUser.email &&
            await _isValidBackendSession(currentUser.email!)) {
          print('User session is valid, loading user data...');
          await _loadUserData(currentUser);
        } else {
          print('Invalid session detected, clearing...');
          await _forceSignOut();
        }
      } else {
        print('No Firebase user found');
        await _clearUserSession();
        state = state.copyWith(isLoading: false, isInitialized: true);
      }

      // Set up auth state listener for future changes
      _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
    } catch (e) {
      print('Auth initialization error: $e');
      await _forceSignOut();
    }
  }

  // Validate backend session exists
  Future<bool> _isValidBackendSession(String email) async {
    try {
      final backendResponse = await _backendService.getUser(email: email);
      return backendResponse.success && backendResponse.data != null;
    } catch (e) {
      print('Backend session validation failed: $e');
      return false;
    }
  }

  // Load user data from backend and Firestore
  Future<void> _loadUserData(User firebaseUser) async {
    try {
      print('Loading user data for: ${firebaseUser.email}');

      // Get user data from backend with timeout
      final backendResponse = await _backendService
          .getUser(email: firebaseUser.email!)
          .timeout(const Duration(seconds: 10));

      if (backendResponse.success && backendResponse.data != null) {
        // Get Firestore data as backup
        final topPrixUser = await _getTopPrixUser(firebaseUser.uid);

        // Save user session
        await _saveUserSession(
          email: firebaseUser.email!,
          role: backendResponse.data!.role,
        );

        state = state.copyWith(
          firebaseUser: firebaseUser,
          backendUser: backendResponse.data,
          topPrixUser: topPrixUser,
          isLoading: false,
          isInitialized: true,
          error: null,
        );

        print('User data loaded successfully');
      } else {
        print('Backend user not found, signing out');
        await _forceSignOut();
      }
    } catch (e) {
      print('Error loading user data: $e');
      await _forceSignOut();
    }
  }

  // Auth state change listener (for real-time updates)
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    // Skip if this is the initial load (handled by _initializeAuth)
    if (!state.isInitialized) return;

    print('Auth state changed: ${firebaseUser?.email ?? 'null'}');

    if (firebaseUser != null) {
      // Only load data if this is a new user or different user
      if (state.firebaseUser?.uid != firebaseUser.uid) {
        // Validate this is a legitimate sign-in, not just Firebase restoration
        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

        if (isLoggedIn) {
          await _loadUserData(firebaseUser);
        } else {
          print('Firebase user detected but no valid session');
          await _forceSignOut();
        }
      }
    } else if (state.firebaseUser != null) {
      // User signed out
      await _clearUserSession();
      state = AuthState(isInitialized: true);
    }
  }

  // Save user session to SharedPreferences
  Future<void> _saveUserSession({
    required String email,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userRoleKey, role);
    print('User session saved');
  }

  // Clear user session from SharedPreferences
  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
    print('User session cleared');
  }

  // Get TopPrix user data from Firestore
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

  // Sign up with email and password
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

      print('Starting signup process for: $email');

      // Create Firebase user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create Firebase user account');
      }

      print('Firebase user created: ${userCredential.user!.uid}');

      // Update Firebase display name
      await userCredential.user!.updateDisplayName(name);

      // Register user in backend
      print('Registering user in backend...');
      final backendResponse = await _backendService.registerUser(
        email: email,
        name: name,
        phone: phone,
        role: role == UserRole.user ? 'USER' : 'RETAILER',
        location: location,
      );

      if (!backendResponse.success) {
        await userCredential.user!.delete();
        throw Exception(backendResponse.message);
      }

      print('Backend user created successfully');

      // Create Firestore backup
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

      // Save user session
      await _saveUserSession(
        email: email,
        role: backendResponse.data!.role,
      );

      state = state.copyWith(
        firebaseUser: userCredential.user,
        backendUser: backendResponse.data,
        topPrixUser: topPrixUser,
        isLoading: false,
        isInitialized: true,
      );

      print('Signup completed successfully');
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _getAuthErrorMessage(e));
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      throw Exception(e.toString());
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      print('Starting login process for: $email');

      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Firebase');
      }

      print('Firebase authentication successful');

      // Load user data (this will save session if successful)
      await _loadUserData(userCredential.user!);

      if (state.backendUser == null) {
        await _firebaseAuth.signOut();
        throw Exception('User account not found. Please contact support.');
      }

      print('Login completed successfully');
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _getAuthErrorMessage(e));
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      throw Exception(e.toString());
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print('Starting Google Sign-In...');

      // Step 1: Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Handle cancellation properly
      if (googleUser == null) {
        print('Google Sign-In was cancelled by user');
        state = state.copyWith(isLoading: false, error: null);
        return; // Exit cleanly without throwing exception
      }

      print('Google account selected: ${googleUser.email}');

      // Step 2: Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      // Step 3: Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in to Firebase with Google credential...');

      // Step 4: Sign in to Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Failed to authenticate with Firebase');
      }

      print('Google Sign-In successful: ${userCredential.user!.email}');

      // Step 5: Sync with backend (Google users are always USER role)
      final backendResponse = await _backendService.syncFirebaseUser(
        email: userCredential.user!.email!,
        name: userCredential.user!.displayName ?? 'Google User',
        role: 'USER',
      );

      if (!backendResponse.success) {
        throw Exception(backendResponse.message);
      }

      // Step 6: Create/update Firestore backup
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

      // Step 7: Save valid session
      await _saveUserSession(
        email: userCredential.user!.email!,
        role: 'USER',
      );

      // Step 8: Update state
      state = state.copyWith(
        firebaseUser: userCredential.user,
        backendUser: backendResponse.data,
        topPrixUser: topPrixUser,
        isLoading: false,
        isInitialized: true,
        error: null,
      );

      print('Google Sign-In completed successfully');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error: ${e.code} - ${e.message}');
      await _handleSignInError();
      state = state.copyWith(isLoading: false, error: _getAuthErrorMessage(e));
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      print('Google Sign-In error: $e');
      await _handleSignInError();

      // Don't throw exception for cancellation
      if (e.toString().contains('cancelled')) {
        state = state.copyWith(isLoading: false, error: null);
        return;
      }

      state = state.copyWith(isLoading: false, error: e.toString());
      throw Exception(e.toString());
    }
  }

  // Handle sign-in errors by cleaning up state
  Future<void> _handleSignInError() async {
    try {
      // Don't sign out if user deliberately cancelled
      await _googleSignIn.signOut();
      print('Cleaned up Google sign-in state');
    } catch (e) {
      print('Error cleaning up sign-in state: $e');
    }
  }

  // Force sign out and clear everything
  Future<void> _forceSignOut() async {
    try {
      print('Force signing out...');

      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);

      await _clearUserSession();

      state = AuthState(isInitialized: true);
      print('Force sign out completed');
    } catch (e) {
      print('Error during force sign out: $e');
      state = AuthState(isInitialized: true);
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

  // Get current user email
  Future<String> getCurrentUserEmail() async {
    final user = _firebaseAuth.currentUser;
    if (user?.email != null) {
      return user!.email!;
    }
    throw Exception('No authenticated user found');
  }

  // Sign out
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);

      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);

      await _clearUserSession();

      state = AuthState(isInitialized: true);
      print('User signed out successfully');
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
      await _loadUserData(_firebaseAuth.currentUser!);
    }
  }

  // Force refresh user data
  Future<void> refreshUserData() async {
    final user = state.firebaseUser;
    if (user != null) {
      await _loadUserData(user);
    }
  }

  // Check session validity
  Future<bool> isSessionValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final storedEmail = prefs.getString(_userEmailKey);
      final currentUser = _firebaseAuth.currentUser;

      return isLoggedIn &&
          storedEmail != null &&
          currentUser != null &&
          storedEmail == currentUser.email;
    } catch (e) {
      return false;
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

final authInitializedProvider = Provider<bool>((ref) {
  return ref.watch(topPrixAuthProvider).isInitialized;
});
