import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../core/logger.dart';

/// Detection service: tries a remote API, falls back to a local placeholder.
class DetectionService {
  /// Detects disease from [image]. If `API_BASE_URL` is configured and
  /// reachable, this will POST a multipart/form-data request to
  /// `{API_BASE_URL}/detect` with the image file under field `image`.
  ///
  /// Expected response JSON: { label: string, confidence: number, notes: string }
  static Future<Map<String, dynamic>> detect(File image) async {
    final base = AppConfig.instance.apiBaseUrl;

    // If the base URL is the default local placeholder, skip remote call.
    if (base.contains('acades.local')) {
      AppLogger.info(
          'DetectionService: no remote API configured, using local placeholder');
      return _localPlaceholder();
    }

    final uri = Uri.parse('$base/detect');
    try {
      final req = http.MultipartRequest('POST', uri);
      final filename = image.uri.pathSegments.isNotEmpty
          ? image.uri.pathSegments.last
          : 'image.jpg';
      req.files.add(await http.MultipartFile.fromPath('image', image.path,
          filename: filename));

      AppLogger.info('DetectionService: sending image to $uri');

      final streamed = await req
          .send()
          .timeout(Duration(milliseconds: AppConfig.instance.apiTimeoutMs));
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode != 200) {
        AppLogger.warning(
            'Detection API returned ${resp.statusCode}: ${resp.body}');
        throw Exception('Detection API error ${resp.statusCode}');
      }

      final jsonBody = json.decode(resp.body) as Map<String, dynamic>;
      return {
        'label': jsonBody['label'] ?? jsonBody['disease'] ?? 'Unknown',
        'confidence': (jsonBody['confidence'] is num)
            ? (jsonBody['confidence'] as num).toDouble()
            : null,
        'notes': jsonBody['notes'] ?? jsonBody['advice'] ?? '',
      };
    } catch (e, st) {
      AppLogger.error(
          'DetectionService: remote detection failed, falling back', e, st);
      // Fallback to local placeholder so the feature remains usable offline.
      return _localPlaceholder();
    }
  }

  static Map<String, dynamic> _localPlaceholder() {
    return {
      'label': 'Leaf Blight',
      'confidence': 0.87,
      'notes': 'Early signs observed — consider fungicide and crop hygiene.'
    };
  }
}
