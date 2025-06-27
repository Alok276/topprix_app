// lib/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? phone;
  final String? photoURL;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final List<String> preferredStoreIds;
  final List<String> preferredCategoryIds;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.phone,
    this.photoURL,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.emailVerified = false,
    required this.createdAt,
    this.lastLogin,
    this.preferredStoreIds = const [],
    this.preferredCategoryIds = const [],
  });

  // Create UserModel from Firebase User
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified ?? false,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  // Create UserModel from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      username: data['name'],
      phone: data['phone'],
      photoURL: data['photoURL'],
      address: data['address'],
      city: data['city'],
      state: data['state'],
      country: data['country'] ?? 'India',
      postalCode: data['postalCode'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      emailVerified: data['emailVerified'] ?? false,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      lastLogin: data['lastLogin']?.toDate(),
      preferredStoreIds: List<String>.from(data['preferredStoreIds'] ?? []),
      preferredCategoryIds:
          List<String>.from(data['preferredCategoryIds'] ?? []),
    );
  }

  // Create UserModel from JSON (for local storage)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      phone: json['phone'],
      photoURL: json['photoURL'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      emailVerified: json['emailVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      preferredStoreIds: List<String>.from(json['preferredStoreIds'] ?? []),
      preferredCategoryIds:
          List<String>.from(json['preferredCategoryIds'] ?? []),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'phone': phone,
      'createdAt': createdAt,
      'lastLogin': createdAt,
      'updatedAt': DateTime.now(),
    };
  }

  // Convert to JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone': phone,
      'photoURL': photoURL,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'preferredStoreIds': preferredStoreIds,
      'preferredCategoryIds': preferredCategoryIds,
    };
  }

  // Convert to backend API format
  Map<String, dynamic> toBackendJson() {
    return {
      'username': username,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'role': 'USER', // Default role for TopPrix users
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? phone,
    String? photoURL,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastLogin,
    List<String>? preferredStoreIds,
    List<String>? preferredCategoryIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      photoURL: photoURL ?? this.photoURL,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      preferredStoreIds: preferredStoreIds ?? this.preferredStoreIds,
      preferredCategoryIds: preferredCategoryIds ?? this.preferredCategoryIds,
    );
  }

  // Get user's full name or email
  String get displayName {
    if (username?.isNotEmpty == true) {
      return username!;
    }
    return email.split('@').first;
  }

  // Get user's initials for avatar
  String get initials {
    if (username?.isNotEmpty == true) {
      final nameParts = username!.split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
      }
      return username![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  // Check if user has complete profile
  bool get hasCompleteProfile {
    return username?.isNotEmpty == true &&
        phone?.isNotEmpty == true &&
        address?.isNotEmpty == true &&
        city?.isNotEmpty == true;
  }

  // Get formatted address
  String get formattedAddress {
    final parts = <String>[];

    if (address?.isNotEmpty == true) parts.add(address!);
    if (city?.isNotEmpty == true) parts.add(city!);
    if (state?.isNotEmpty == true) parts.add(state!);
    if (country?.isNotEmpty == true) parts.add(country!);
    if (postalCode?.isNotEmpty == true) parts.add(postalCode!);

    return parts.join(', ');
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username, emailVerified: $emailVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.id == id && other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode;
  }
}
