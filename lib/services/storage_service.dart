import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;
import 'package:supbase_flutter_coures/core/errors/app_exception.dart';

/// Handles all Supabase Storage operations for the notes bucket.
class StorageService {
  static const _bucket = 'notes';
  static final _storage = Supabase.instance.client.storage;

  /// Returns the public CDN URL for [path] stored in the notes bucket.
  String getPublicUrl(String path) {
    return _storage.from(_bucket).getPublicUrl(path);
  }

  /// Uploads [image] to the notes bucket and returns its storage path.
  /// Throws [StorageException] on failure.
  Future<String> uploadImage(XFile image) async {
    try {
      final fileName = '${DateTime.now().toIso8601String()}_${image.name}';
      final filePath = 'public/$fileName';
      await _storage.from(_bucket).upload(filePath, File(image.path));
      return filePath;
    } catch (e) {
      throw StorageException('Image upload failed.', originalError: e);
    }
  }

  /// Deletes the image at [path] from the notes bucket.
  /// Silently ignores errors (best-effort cleanup).
  Future<void> deleteImage(String path) async {
    if (path.isEmpty) return;
    try {
      await _storage.from(_bucket).remove([path]);
    } catch (e) {
      // Best-effort — log but don't rethrow
      debugPrint('StorageService.deleteImage: $e');
    }
  }
}
