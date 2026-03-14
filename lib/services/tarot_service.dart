import 'dart:convert';
import 'dart:math' as dart_math;
import 'package:flutter/services.dart';
import '../models/tarot_card.dart';

class TarotService {
  List<TarotCard> _cards = [];

  List<TarotCard> get cards => _cards;

  Future<void> loadCards() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/tarot-images-vn.json',
      );
      final data = await json.decode(response);

      if (data['cards'] != null) {
        _cards = (data['cards'] as List)
            .map((json) => TarotCard.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error loading tarot cards: $e');
      // Fallback to English if VN file fails or doesn't exist
      try {
        final String responseEn = await rootBundle.loadString(
          'assets/data/tarot-images.json',
        );
        final dataEn = await json.decode(responseEn);
        if (dataEn['cards'] != null) {
          _cards = (dataEn['cards'] as List)
              .map((json) => TarotCard.fromJson(json))
              .toList();
        }
      } catch (e2) {
        print('Error loading english fallback: $e2');
      }
    }
  }

  List<TarotCard> drawCards(int count) {
    if (_cards.isEmpty) return [];

    var shuffled = List<TarotCard>.from(_cards);
    shuffled.shuffle(); // Shuffle in place

    final drawn = shuffled.take(count).toList();

    // Randomize orientation for each drawn card
    final random = dart_math.Random();
    for (var card in drawn) {
      card.isReversed = random.nextBool();
    }

    return drawn;
  }
}
