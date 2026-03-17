import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '../models/tarot_card.dart';

class AiTarotService {
  static const String _defaultPrompt = '''
You are an experienced tarot reader.

Your task is to interpret a tarot reading based on:
- the user's topic
- the user's question
- the spread structure
- the tarot cards drawn

Reading guidelines:
- Interpret the meaning of each card according to its position in the spread.
- Consider the user’s topic and question when interpreting.
- Provide thoughtful guidance rather than deterministic predictions.
- The tone should be reflective, insightful, and supportive.

Language requirement:
- ALL explanations MUST be written in Vietnamese.
- Use natural Vietnamese as if a tarot reader is speaking to the user.

IMPORTANT RULES:
- Return ONLY a valid JSON object.
- Do NOT include any text outside the JSON.
- If information is unclear, still produce a reasonable interpretation.
- All text fields in the JSON must be written in Vietnamese.

INPUT

Topic: {{topic}}

User Question:
{{question}}

Spread Type:
{{spread}}

Cards Drawn:
{{cards}}

RESPONSE FORMAT (JSON)

{
  "topic": "",
  "question": "",
  "summary": "",
  "cards_interpretation": [
    {
      "card_name": "",
      "position": "",
      "orientation": "",
      "interpretation": ""
    }
  ],
  "advice": "",
  "energy": "",
  "possible_outcome": ""
}
''';

  final GenerativeModel? _model;
  final String _apiKey;

  AiTarotService({String? apiKey})
    : _apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '',
      _model = kIsWeb
          ? null
          : GenerativeModel(
            model: 'gemini-2.5-flash',
            apiKey: apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '',
          );

  Future<Map<String, dynamic>> generateReading({
    required String? topic,
    required String? question,
    required int cardCount,
    required List<TarotCard> drawnCards,
  }) async {
    try {
      String prompt = _defaultPrompt
          .replaceAll('{{topic}}', topic ?? 'Tổng quan')
          .replaceAll(
            '{{question}}',
            question ?? 'Không có câu hỏi cụ thể, xin đọc trải bài ngẫu nhiên.',
          )
          .replaceAll('{{spread}}', _getSpreadType(cardCount))
          .replaceAll('{{cards}}', _formatCards(drawnCards, cardCount));

      String responseText;

      if (kIsWeb) {
        // Call the secure Vercel Proxy on Web
        final proxyUrl = Uri.parse('/api/interpret');
        final proxyResponse = await http.post(
          proxyUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'prompt': prompt}),
        );

        if (proxyResponse.statusCode != 200) {
          throw Exception(
            'Proxy Error (${proxyResponse.statusCode}): ${proxyResponse.body}',
          );
        }

        final proxyData = jsonDecode(proxyResponse.body);
        responseText = proxyData['text'] ?? '';
      } else {
        // Direct call on Mobile/Desktop
        if (_apiKey.isEmpty) {
          throw Exception('Generative AI API Key is missing.');
        }
        if (_model == null) {
          throw Exception('Generative Model not initialized.');
        }
        final response = await _model.generateContent([Content.text(prompt)]);
        responseText = response.text ?? '';
      }

      if (responseText.isEmpty) {
        throw Exception('Empty response from AI.');
      }

      // Very robust JSON extraction because LLMs sometimes wrap JSON in markdown block ticks
      String cleanJson = responseText;
      if (cleanJson.contains('```json')) {
        cleanJson = cleanJson.split('```json')[1].split('```')[0].trim();
      } else if (cleanJson.contains('```')) {
        cleanJson = cleanJson.split('```')[1].split('```')[0].trim();
      }

      // Fallback manual brace extraction if still malformed
      final int firstBrace = cleanJson.indexOf('{');
      final int lastBrace = cleanJson.lastIndexOf('}');
      if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
        cleanJson = cleanJson.substring(firstBrace, lastBrace + 1);
      }

      return jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to generate AI reading: $e');
    }
  }

  String _getSpreadType(int count) {
    if (count == 1) return 'Rút 1 lá (Daily Insight)';
    if (count == 3) return 'Rút 3 lá (Past/Present/Future)';
    if (count == 5) return 'Rút 5 lá (Cross Spread)';
    if (count == 10) return 'Rút 10 lá (Celtic Cross)';
    return 'Rút $count lá ngẫu nhiên';
  }

  String _formatCards(List<TarotCard> cards, int totalCards) {
    List<String> formatted = [];
    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      final name = card.nameVn.isNotEmpty
          ? "${card.nameVn} (${card.name})"
          : card.name;
      final position = _getSpreadLabel(totalCards, i);
      final orientation = card.isReversed
          ? 'Ngược (Reversed)'
          : 'Xuôi (Upright)';

      formatted.add(
        '- Vị trí: $position\n  Lá bài: $name\n  Chiều: $orientation',
      );
    }
    return formatted.join('\n\n');
  }

  String _getSpreadLabel(int totalCards, int idx) {
    if (totalCards == 3) {
      return idx == 0
          ? "Quá khứ"
          : idx == 1
          ? "Hiện tại"
          : "Tương lai";
    } else if (totalCards == 5) {
      const labels = ["Quá khứ", "Hiện tại", "Tương lai", "Lý do", "Kết quả"];
      return labels[idx];
    } else if (totalCards == 10) {
      const labels = [
        "Hiện tại",
        "Thử thách",
        "Nền tảng",
        "Quá khứ gần",
        "Mục tiêu",
        "Tương lai gần",
        "Bản thân",
        "Môi trường",
        "Hy vọng/Nỗi sợ",
        "Kết quả",
      ];
      return labels[idx];
    }
    return "Lá ${idx + 1}";
  }
}
