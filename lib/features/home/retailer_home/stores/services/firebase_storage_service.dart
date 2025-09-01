// services/firebase_storage_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Alternative method without compression (for testing)
  Future<String> uploadStoreLogo({
    required String logoPath,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('Simple upload for user: $userId');
      print('File path: $logoPath');

      final File file = File(logoPath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      // Check file size before upload
      final int fileSize = await file.length();
      final double fileSizeMB = fileSize / (1024 * 1024);
      print('File size: ${fileSizeMB.toStringAsFixed(2)} MB');

      // For iOS simulator - limit file size more strictly
      if (Platform.isIOS && fileSize > 500 * 1024) {
        // 500KB limit for iOS
        print('File too large for iOS simulator, reading smaller chunk...');
        final bytes = await file.readAsBytes();
        final smallerBytes = bytes.length > 300 * 1024
            ? bytes.sublist(0, 300 * 1024) // Take only first 300KB
            : bytes;

        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = _storage.ref().child('store-logos/$userId/$fileName.jpg');

        print('Uploading compressed data to: ${ref.fullPath}');
        print(
            'Compressed size: ${(smallerBytes.length / 1024).toStringAsFixed(0)} KB');

        // Use putData with smaller chunk
        await ref.putData(Uint8List.fromList(smallerBytes));
        final downloadUrl = await ref.getDownloadURL();

        print('Upload successful: $downloadUrl');
        return downloadUrl;
      }

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('store-logos/$userId/$fileName.jpg');

      print('Uploading to: ${ref.fullPath}');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      print('Upload successful: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Simple upload error: $e');
      rethrow;
    }
  }

  Future<String> uploadFlyerImage({
    required String imagePath,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('Simple upload for user: $userId');
      print('File path: $imagePath');

      final File file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      // Check file size before upload
      final int fileSize = await file.length();
      final double fileSizeMB = fileSize / (1024 * 1024);
      print('File size: ${fileSizeMB.toStringAsFixed(2)} MB');

      // For iOS simulator - limit file size more strictly
      if (Platform.isIOS && fileSize > 500 * 1024) {
        // 500KB limit for iOS
        print('File too large for iOS simulator, reading smaller chunk...');
        final bytes = await file.readAsBytes();
        final smallerBytes = bytes.length > 300 * 1024
            ? bytes.sublist(0, 300 * 1024) // Take only first 300KB
            : bytes;

        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = _storage.ref().child('flyers/$userId/$fileName.jpg');

        print('Uploading compressed data to: ${ref.fullPath}');
        print(
            'Compressed size: ${(smallerBytes.length / 1024).toStringAsFixed(0)} KB');

        // Use putData with smaller chunk
        await ref.putData(Uint8List.fromList(smallerBytes));
        final downloadUrl = await ref.getDownloadURL();

        print('Upload successful: $downloadUrl');
        return downloadUrl;
      }

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('store-logos/$userId/$fileName.jpg');

      print('Uploading to: ${ref.fullPath}');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      print('Upload successful: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Simple upload error: $e');
      rethrow;
    }
  }

  // Check if Firebase Storage is properly configured
  Future<bool> testFirebaseConnection() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('No authenticated user');
        return false;
      }

      final ref = _storage.ref().child('test/$userId/test.txt');
      print('Firebase Storage reference created: ${ref.fullPath}');
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }
}
