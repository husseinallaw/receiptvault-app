import 'dart:typed_data';

import 'package:image/image.dart' as img;
import '../../core/errors/exceptions.dart';

/// Service for processing receipt images before OCR
///
/// Provides image enhancement and optimization for better OCR results.
class ImageProcessor {
  /// Maximum image dimension (width or height)
  static const int maxDimension = 2048;

  /// JPEG quality for compression
  static const int jpegQuality = 85;

  /// Minimum image dimension
  static const int minDimension = 480;

  /// Process image for OCR
  ///
  /// Applies the following transformations:
  /// - Resize to optimal dimensions
  /// - Convert to grayscale (optional)
  /// - Adjust contrast and brightness
  /// - Compress to JPEG
  Future<Uint8List> processForOcr(
    Uint8List imageBytes, {
    bool grayscale = false,
    bool enhanceContrast = true,
    int? targetWidth,
    int? targetHeight,
  }) async {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const StorageException('Failed to decode image');
      }

      var processed = image;

      // Resize if needed
      processed = _resizeIfNeeded(
        processed,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );

      // Convert to grayscale if requested
      if (grayscale) {
        processed = img.grayscale(processed);
      }

      // Enhance contrast if requested
      if (enhanceContrast) {
        processed = _enhanceContrast(processed);
      }

      // Encode to JPEG
      final output = img.encodeJpg(processed, quality: jpegQuality);
      return Uint8List.fromList(output);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Image processing failed: $e');
    }
  }

  /// Resize image to fit within max dimensions
  img.Image _resizeIfNeeded(
    img.Image image, {
    int? targetWidth,
    int? targetHeight,
  }) {
    final width = image.width;
    final height = image.height;

    // Calculate target dimensions
    int newWidth = targetWidth ?? width;
    int newHeight = targetHeight ?? height;

    // If target dimensions not specified, use max dimension
    if (targetWidth == null && targetHeight == null) {
      if (width > maxDimension || height > maxDimension) {
        if (width > height) {
          newWidth = maxDimension;
          newHeight = (height * maxDimension / width).round();
        } else {
          newHeight = maxDimension;
          newWidth = (width * maxDimension / height).round();
        }
      } else if (width < minDimension && height < minDimension) {
        // Image too small, scale up
        final scale = minDimension / (width < height ? width : height);
        newWidth = (width * scale).round();
        newHeight = (height * scale).round();
      } else {
        // No resize needed
        return image;
      }
    }

    return img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );
  }

  /// Enhance image contrast for better OCR
  img.Image _enhanceContrast(img.Image image) {
    // Apply contrast adjustment
    return img.adjustColor(
      image,
      contrast: 1.2,
      brightness: 1.05,
    );
  }

  /// Crop image to receipt bounds
  Future<Uint8List> cropToReceipt(
    Uint8List imageBytes,
    Rect bounds,
  ) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const StorageException('Failed to decode image');
      }

      final cropped = img.copyCrop(
        image,
        x: bounds.left.round(),
        y: bounds.top.round(),
        width: bounds.width.round(),
        height: bounds.height.round(),
      );

      final output = img.encodeJpg(cropped, quality: jpegQuality);
      return Uint8List.fromList(output);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Image cropping failed: $e');
    }
  }

  /// Rotate image by given angle (in degrees)
  Future<Uint8List> rotate(Uint8List imageBytes, int degrees) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const StorageException('Failed to decode image');
      }

      final rotated = img.copyRotate(image, angle: degrees.toDouble());
      final output = img.encodeJpg(rotated, quality: jpegQuality);
      return Uint8List.fromList(output);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Image rotation failed: $e');
    }
  }

  /// Compress image to reduce size
  Future<Uint8List> compress(
    Uint8List imageBytes, {
    int quality = 80,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      var image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const StorageException('Failed to decode image');
      }

      // Resize if max dimensions specified
      if (maxWidth != null || maxHeight != null) {
        image = _resizeIfNeeded(
          image,
          targetWidth: maxWidth,
          targetHeight: maxHeight,
        );
      }

      final output = img.encodeJpg(image, quality: quality);
      return Uint8List.fromList(output);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Image compression failed: $e');
    }
  }

  /// Get image dimensions
  Future<ImageDimensions> getDimensions(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const StorageException('Failed to decode image');
      }

      return ImageDimensions(
        width: image.width,
        height: image.height,
      );
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to get image dimensions: $e');
    }
  }

  /// Check if image needs rotation based on EXIF data
  Future<int> getExifRotation(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return 0;

      // The image package handles EXIF orientation automatically
      // when decoding, so we don't need to return rotation
      return 0;
    } catch (_) {
      return 0;
    }
  }
}

/// Rectangle bounds
class Rect {
  final double left;
  final double top;
  final double width;
  final double height;

  const Rect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  double get right => left + width;
  double get bottom => top + height;
}

/// Image dimensions
class ImageDimensions {
  final int width;
  final int height;

  const ImageDimensions({
    required this.width,
    required this.height,
  });

  double get aspectRatio => width / height;
  bool get isLandscape => width > height;
  bool get isPortrait => height > width;
}
