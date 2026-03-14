import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TrackingService {
  static final String? _webhookUrl = dotenv.env['TRACKING_WEBHOOK_URL'];
  static final String? _token = dotenv.env['TRACKING_TOKEN'];

  static Future<void> logVisit(String userId) async {
    if (_webhookUrl == null || _webhookUrl!.isEmpty) return;

    try {
      final body = jsonEncode({
        'token': _token ?? "",
        'type': 'visit',
        'userid': userId,
      });

      await http.post(
        Uri.parse(_webhookUrl!),
        // text/plain is a "simple" content type - NO CORS PREFLIGHT
        headers: {'Content-Type': 'text/plain'},
        body: body,
      );
    } catch (e) {
      print('Error logging visit: $e');
    }
  }

  static Future<void> logSpreadResult({
    required String userId,
    required String? topic,
    required String? question,
    required String spreadType,
    required String drawnCards,
    required String readingType,
    required String interpretationResult,
  }) async {
    if (_webhookUrl == null || _webhookUrl!.isEmpty) return;

    try {
      final body = jsonEncode({
        'token': _token ?? "",
        'type': 'spread',
        'userid': userId,
        'topic': topic ?? "N/A",
        'question': question ?? "N/A",
        'spreadtype': spreadType,
        'drawncards': drawnCards,
        'readingtype': readingType,
        'interpretationresult': interpretationResult,
      });

      await http.post(
        Uri.parse(_webhookUrl!),
        // text/plain is a "simple" content type - NO CORS PREFLIGHT
        headers: {'Content-Type': 'text/plain'},
        body: body,
      );
    } catch (e) {
      print('Error logging spread result: $e');
    }
  }
}
