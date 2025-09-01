import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:topprix/features/home/user_home/services/store_service.dart';
import 'package:topprix/core/provider/dio_provider.dart';

// Location Model
class UserLocation {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;

  UserLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
  });

  factory UserLocation.fromPosition(
    Position position, {
    String? address,
    String? city,
    String? country,
  }) {
    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
      city: city,
      country: country,
    );
  }
}

// Nearby Deal Model
class NearbyDeal {
  final String id;
  final String title;
  final String storeId;
  final String storeName;
  final String? storeLogoUrl;
  final String? imageUrl;
  final String discount;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final double distance; // in km
  final double? latitude;
  final double? longitude;
  final String dealType; // flyer, coupon

  NearbyDeal({
    required this.id,
    required this.title,
    required this.storeId,
    required this.storeName,
    this.storeLogoUrl,
    this.imageUrl,
    required this.discount,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.distance,
    this.latitude,
    this.longitude,
    required this.dealType,
  });

  factory NearbyDeal.fromJson(Map<String, dynamic> json) {
    return NearbyDeal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      storeId: json['storeId'] ?? '',
      storeName: json['storeName'] ?? '',
      storeLogoUrl: json['storeLogoUrl'],
      imageUrl: json['imageUrl'],
      discount: json['discount'] ?? '',
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      distance: (json['distance'] ?? 0.0).toDouble(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      dealType: json['dealType'] ?? 'flyer',
    );
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  String get distanceText {
    if (distance < 1) {
      return '${(distance * 1000).round()}m away';
    }
    return '${distance.toStringAsFixed(1)}km away';
  }
}

// Location Service
class LocationService {
  final Dio _dio;

  LocationService(this._dio);

  // Check and request location permissions
  Future<bool> checkLocationPermission() async {
    try {
      final permission = await Permission.location.status;

      if (permission.isDenied) {
        final result = await Permission.location.request();
        return result.isGranted;
      }

      return permission.isGranted;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  // Get current user location
  Future<UserLocation?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          return UserLocation.fromPosition(
            position,
            address: '${place.street}, ${place.locality}',
            city: place.locality,
            country: place.country,
          );
        }
      } catch (e) {
        print('Error getting address: $e');
      }

      return UserLocation.fromPosition(position);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Get nearby stores from backend
  Future<List<Store>> getNearbyStores({
    required double latitude,
    required double longitude,
    int radius = 10, // km
  }) async {
    try {
      final response = await _dio.get(
        '/location/nearby-stores',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> storesJson = response.data is List
            ? response.data
            : response.data['stores'] ?? [];
        return storesJson.map((json) => Store.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching nearby stores: $e');
      return [];
    }
  }

  // Get nearby deals from backend
  Future<List<NearbyDeal>> getNearbyDeals({
    required double latitude,
    required double longitude,
    int radius = 10, // km
  }) async {
    try {
      final response = await _dio.get(
        '/location/nearby-deals',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> dealsJson = response.data is List
            ? response.data
            : response.data['deals'] ?? [];
        return dealsJson.map((json) => NearbyDeal.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching nearby deals: $e');
      return [];
    }
  }

  // Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert to kilometers
  }

  // Open location in maps app
  Future<void> openInMaps(double latitude, double longitude) async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      print('Error opening maps: $e');
    }
  }
}

// Providers
final locationServiceProvider = Provider<LocationService>((ref) {
  final dio = ref.read(dioProvider);
  return LocationService(dio);
});

final currentLocationProvider = FutureProvider<UserLocation?>((ref) async {
  final service = ref.read(locationServiceProvider);
  return service.getCurrentLocation();
});

final nearbyStoresLocationProvider =
    FutureProvider.family<List<Store>, UserLocation>((ref, location) async {
  final service = ref.read(locationServiceProvider);
  return service.getNearbyStores(
    latitude: location.latitude,
    longitude: location.longitude,
  );
});

final nearbyDealsProvider =
    FutureProvider.family<List<NearbyDeal>, UserLocation>(
        (ref, location) async {
  final service = ref.read(locationServiceProvider);
  return service.getNearbyDeals(
    latitude: location.latitude,
    longitude: location.longitude,
  );
});

final locationPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(locationServiceProvider);
  return service.checkLocationPermission();
});
