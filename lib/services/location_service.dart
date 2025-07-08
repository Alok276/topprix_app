// lib/services/location_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/store_model.dart';
import '../models/api_response.dart';
import 'dio_client.dart';
import 'storage_service.dart';

final locationServiceProvider = Provider((ref) => LocationService());

class LocationService {
  final DioClient _dioClient;
  Position? _lastKnownPosition;
  DateTime? _lastLocationUpdate;
  static const Duration _locationCacheExpiry = Duration(minutes: 5);

  LocationService() : _dioClient = DioClient();

  // ========== PERMISSION MANAGEMENT ==========

  /// Check if location permissions are granted
  Future<ApiResponse<bool>> checkLocationPermissions() async {
    try {
      final permission = await Permission.location.status;

      switch (permission) {
        case PermissionStatus.granted:
        case PermissionStatus.limited:
          return ApiResponse.success(true);
        case PermissionStatus.denied:
        case PermissionStatus.restricted:
        case PermissionStatus.permanentlyDenied:
        case PermissionStatus.provisional:
          return ApiResponse.success(false);
      }
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Request location permissions
  Future<ApiResponse<bool>> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return ApiResponse.error(
            'Location services are disabled. Please enable them in settings.');
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return ApiResponse.error(
              'Location permissions are denied. Please grant permission to find nearby deals.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return ApiResponse.error(
            'Location permissions are permanently denied. Please enable them in app settings.');
      }

      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Open app settings for permission management
  Future<ApiResponse<bool>> openAppSettings() async {
    try {
      final opened = await openAppSettings();
      return ApiResponse.success(opened as bool);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== LOCATION DETECTION ==========

  /// Get current user location
  Future<ApiResponse<Position>> getCurrentLocation({
    bool forceRefresh = false,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      // Return cached location if available and not expired
      if (!forceRefresh &&
          _lastKnownPosition != null &&
          _lastLocationUpdate != null) {
        final timeSinceUpdate = DateTime.now().difference(_lastLocationUpdate!);
        if (timeSinceUpdate < _locationCacheExpiry) {
          return ApiResponse.success(_lastKnownPosition!);
        }
      }

      // Check permissions first
      final permissionResponse = await requestLocationPermission();
      if (!permissionResponse.success) {
        return ApiResponse.error(permissionResponse.error!);
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();

      // Cache the position
      _lastKnownPosition = position;
      _lastLocationUpdate = DateTime.now();

      // Store in local storage for offline use
      await StorageService.saveLastKnownLocation(
        position.latitude,
        position.longitude,
      );

      return ApiResponse.success(position);
    } catch (e) {
      // Try to return cached location if available
      if (_lastKnownPosition != null) {
        return ApiResponse.success(_lastKnownPosition!);
      }

      // Try to get from storage
      final storedLocation = await StorageService.getLastKnownLocation();
      if (storedLocation != null) {
        final position = Position(
          latitude: storedLocation['latitude'],
          longitude: storedLocation['longitude'],
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
        return ApiResponse.success(position);
      }

      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get location from coordinates
  Future<ApiResponse<LocationModel>> getLocationFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final location = LocationModel(
          latitude: latitude,
          longitude: longitude,
          address: _formatAddress(placemark),
          city: placemark.locality ?? '',
          state: placemark.administrativeArea ?? '',
          country: placemark.country ?? '',
          postalCode: placemark.postalCode ?? '',
          timestamp: DateTime.now(),
        );

        return ApiResponse.success(location);
      }

      return ApiResponse.error(
          'No location information found for these coordinates.');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get coordinates from address
  Future<ApiResponse<Position>> getCoordinatesFromAddress(
      String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;
        final position = Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        return ApiResponse.success(position);
      }

      return ApiResponse.error('No coordinates found for this address.');
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== NEARBY STORES ==========

  /// Get nearby stores
  Future<ApiResponse<List<StoreModel>>> getNearbyStores({
    double? latitude,
    double? longitude,
    double radius = 10.0, // in kilometers
    int limit = 20,
    String? category,
    bool openNow = false,
  }) async {
    try {
      Position? position;

      // Use provided coordinates or get current location
      if (latitude != null && longitude != null) {
        position = Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      } else {
        final locationResponse = await getCurrentLocation();
        if (!locationResponse.success) {
          return ApiResponse.error(locationResponse.error!);
        }
        position = locationResponse.data!;
      }

      final queryParams = <String, dynamic>{
        'latitude': position.latitude,
        'longitude': position.longitude,
        'radius': radius,
        'limit': limit,
      };

      if (category != null) queryParams['category'] = category;
      if (openNow) queryParams['openNow'] = openNow.toString();

      final response = await _dioClient.dio.get(
        '/location/nearby-stores',
        queryParameters: queryParams,
      );

      final stores = (response.data['stores'] as List)
          .map((store) => StoreModel.fromJson(store))
          .toList();

      // Sort by distance
      stores.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));

      return ApiResponse.success(stores);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get stores within specific area
  Future<ApiResponse<List<StoreModel>>> getStoresInArea({
    required double northLatitude,
    required double southLatitude,
    required double eastLongitude,
    required double westLongitude,
    int limit = 50,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'northLat': northLatitude,
        'southLat': southLatitude,
        'eastLng': eastLongitude,
        'westLng': westLongitude,
        'limit': limit,
      };

      if (category != null) queryParams['category'] = category;

      final response = await _dioClient.dio.get(
        '/location/stores-in-area',
        queryParameters: queryParams,
      );

      final stores = (response.data['stores'] as List)
          .map((store) => StoreModel.fromJson(store))
          .toList();

      return ApiResponse.success(stores);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== NEARBY DEALS ==========

  /// Get nearby deals (flyers and coupons)
  Future<ApiResponse<Map<String, dynamic>>> getNearbyDeals({
    double? latitude,
    double? longitude,
    double radius = 10.0,
    String? dealType, // 'all', 'flyers', 'coupons'
    String? categoryId,
    String sortBy = 'distance', // 'distance', 'expiry', 'discount', 'relevance'
    int limit = 20,
    bool includeExpired = false,
  }) async {
    try {
      Position? position;

      // Use provided coordinates or get current location
      if (latitude != null && longitude != null) {
        position = Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      } else {
        final locationResponse = await getCurrentLocation();
        if (!locationResponse.success) {
          return ApiResponse.error(locationResponse.error!);
        }
        position = locationResponse.data!;
      }

      final queryParams = <String, dynamic>{
        'latitude': position.latitude,
        'longitude': position.longitude,
        'radius': radius,
        'sortBy': sortBy,
        'limit': limit,
        'includeExpired': includeExpired.toString(),
      };

      if (dealType != null) queryParams['dealType'] = dealType;
      if (categoryId != null) queryParams['categoryId'] = categoryId;

      final response = await _dioClient.dio.get(
        '/location/nearby-deals',
        queryParameters: queryParams,
      );

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get deals by location radius
  Future<ApiResponse<Map<String, dynamic>>> getDealsInRadius({
    required double latitude,
    required double longitude,
    required double radius,
    String? categoryId,
    int limit = 50,
  }) async {
    try {
      final response = await getNearbyDeals(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        categoryId: categoryId,
        limit: limit,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== LOCATION-BASED SEARCH ==========

  /// Search stores by location and query
  Future<ApiResponse<List<StoreModel>>> searchStoresByLocation({
    required String query,
    double? latitude,
    double? longitude,
    double radius = 25.0,
    int limit = 20,
  }) async {
    try {
      Position? position;

      if (latitude != null && longitude != null) {
        position = Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      } else {
        final locationResponse = await getCurrentLocation();
        if (!locationResponse.success) {
          return ApiResponse.error(locationResponse.error!);
        }
        position = locationResponse.data!;
      }

      final queryParams = <String, dynamic>{
        'query': query,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'radius': radius,
        'limit': limit,
      };

      final response = await _dioClient.dio.get(
        '/location/search-stores',
        queryParameters: queryParams,
      );

      final stores = (response.data['stores'] as List)
          .map((store) => StoreModel.fromJson(store))
          .toList();

      return ApiResponse.success(stores);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Search deals by location and query
  Future<ApiResponse<Map<String, dynamic>>> searchDealsByLocation({
    required String query,
    double? latitude,
    double? longitude,
    double radius = 25.0,
    String? categoryId,
    String? dealType,
    int limit = 20,
  }) async {
    try {
      Position? position;

      if (latitude != null && longitude != null) {
        position = Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      } else {
        final locationResponse = await getCurrentLocation();
        if (!locationResponse.success) {
          return ApiResponse.error(locationResponse.error!);
        }
        position = locationResponse.data!;
      }

      final queryParams = <String, dynamic>{
        'query': query,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'radius': radius,
        'limit': limit,
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (dealType != null) queryParams['dealType'] = dealType;

      final response = await _dioClient.dio.get(
        '/location/search-deals',
        queryParameters: queryParams,
      );

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== DISTANCE CALCULATIONS ==========

  /// Calculate distance between two points
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert to kilometers
  }

  /// Calculate distance to store
  Future<ApiResponse<double>> calculateDistanceToStore({
    required String storeId,
    double? userLatitude,
    double? userLongitude,
  }) async {
    try {
      Position? userPosition;

      if (userLatitude != null && userLongitude != null) {
        userPosition = Position(
          latitude: userLatitude,
          longitude: userLongitude,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      } else {
        final locationResponse = await getCurrentLocation();
        if (!locationResponse.success) {
          return ApiResponse.error(locationResponse.error!);
        }
        userPosition = locationResponse.data!;
      }

      // Get store details
      final storeResponse = await _dioClient.dio.get('/stores/$storeId');
      final store = StoreModel.fromJson(storeResponse.data);

      if (store.latitude == null || store.longitude == null) {
        return ApiResponse.error('Store location not available.');
      }

      final distance = calculateDistance(
        startLatitude: userPosition.latitude,
        startLongitude: userPosition.longitude,
        endLatitude: store.latitude!,
        endLongitude: store.longitude!,
      );

      return ApiResponse.success(distance);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== LOCATION HISTORY ==========

  /// Save user's location for preferences
  Future<ApiResponse<bool>> saveUserLocation({
    required double latitude,
    required double longitude,
    String? address,
    String? label, // 'home', 'work', 'custom'
  }) async {
    try {
      await _dioClient.dio.post('/location/save-user-location', data: {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'label': label,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get user's saved locations
  Future<ApiResponse<List<LocationModel>>> getUserSavedLocations() async {
    try {
      final response = await _dioClient.dio.get('/location/user-locations');

      final locations = (response.data['locations'] as List)
          .map((location) => LocationModel.fromJson(location))
          .toList();

      return ApiResponse.success(locations);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Delete saved location
  Future<ApiResponse<bool>> deleteSavedLocation(String locationId) async {
    try {
      await _dioClient.dio.delete('/location/user-locations/$locationId');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== GEOFENCING ==========

  /// Check if user is within store geofence
  Future<ApiResponse<bool>> isWithinStoreGeofence({
    required String storeId,
    double? userLatitude,
    double? userLongitude,
    double fenceRadius = 0.1, // 100 meters
  }) async {
    try {
      final distanceResponse = await calculateDistanceToStore(
        storeId: storeId,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
      );

      if (!distanceResponse.success) {
        return ApiResponse.error(distanceResponse.error!);
      }

      final distanceKm = distanceResponse.data!;
      final isWithin = distanceKm <= fenceRadius;

      return ApiResponse.success(isWithin);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get stores within geofence
  Future<ApiResponse<List<StoreModel>>> getStoresInGeofence({
    double? latitude,
    double? longitude,
    double fenceRadius = 0.5, // 500 meters
  }) async {
    try {
      final storesResponse = await getNearbyStores(
        latitude: latitude,
        longitude: longitude,
        radius: fenceRadius,
        limit: 50,
      );

      if (!storesResponse.success) {
        return storesResponse;
      }

      final nearbyStores = storesResponse.data!
          .where((store) => (store.distance ?? 0) <= fenceRadius)
          .toList();

      return ApiResponse.success(nearbyStores);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== LOCATION ANALYTICS ==========

  /// Track user location for analytics
  Future<ApiResponse<bool>> trackLocationUsage({
    required String action, // 'SEARCH_NEARBY', 'VIEW_STORE', 'GET_DIRECTIONS'
    double? latitude,
    double? longitude,
    String? storeId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _dioClient.dio.post('/analytics/location-track', data: {
        'action': action,
        'latitude': latitude,
        'longitude': longitude,
        'storeId': storeId,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return ApiResponse.success(true);
    } catch (e) {
      // Silently fail analytics
      return ApiResponse.success(true);
    }
  }

  // ========== UTILITY METHODS ==========

  /// Format address from placemark
  String _formatAddress(Placemark placemark) {
    final parts = <String>[];

    if (placemark.street?.isNotEmpty == true) parts.add(placemark.street!);
    if (placemark.locality?.isNotEmpty == true) parts.add(placemark.locality!);
    if (placemark.administrativeArea?.isNotEmpty == true)
      parts.add(placemark.administrativeArea!);
    if (placemark.postalCode?.isNotEmpty == true)
      parts.add(placemark.postalCode!);
    if (placemark.country?.isNotEmpty == true) parts.add(placemark.country!);

    return parts.join(', ');
  }

  /// Format distance for display
  String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)}m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.toStringAsFixed(0)}km';
    }
  }

  /// Check if location is stale
  bool isLocationStale() {
    if (_lastLocationUpdate == null) return true;

    final timeSinceUpdate = DateTime.now().difference(_lastLocationUpdate!);
    return timeSinceUpdate > _locationCacheExpiry;
  }

  /// Clear cached location
  void clearLocationCache() {
    _lastKnownPosition = null;
    _lastLocationUpdate = null;
  }

  // ========== ERROR HANDLING ==========

  String _handleError(dynamic error) {
    if (error is LocationServiceDisabledException) {
      return 'Location services are disabled. Please enable them in your device settings.';
    } else if (error is PermissionDeniedException) {
      return 'Location permission denied. Please grant permission to find nearby deals.';
    } else if (error is PositionUpdateException) {
      return 'Failed to get location. Please check your GPS signal.';
    } else if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          switch (statusCode) {
            case 400:
              return data?['message'] ?? 'Invalid location data.';
            case 401:
              return 'Authentication failed. Please login again.';
            case 404:
              return 'Location service not available.';
            case 500:
              return 'Location service error. Please try again later.';
            default:
              return data?['message'] ?? 'Failed to get location data.';
          }
        default:
          return 'Network error. Please check your connection.';
      }
    }
    return 'Location error: ${error.toString()}';
  }
}

// ========== LOCATION MODEL ==========

class LocationModel {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String? label;
  final DateTime timestamp;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.label,
    required this.timestamp,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      label: json['label'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'label': label,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
