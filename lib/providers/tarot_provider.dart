import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/storage_service.dart';
import '../services/tarot_service.dart';
import '../services/ai_tarot_service.dart';
import '../services/tracking_service.dart';
import '../models/tarot_card.dart';

class TarotProvider extends ChangeNotifier {
  final TarotService _service = TarotService();
  final AiTarotService _aiService = AiTarotService();

  bool _isLoading = true;
  List<TarotCard> _drawnCards = [];
  String? _selectedTopic;
  String? _currentQuestion;
  String? _userId;

  // AI State
  bool _isAiLoading = false;
  Map<String, dynamic>? _aiInterpretation;

  // Rate limits
  int _dailyAiCount = 0;
  static const int maxAiPerDay = 2; // Can be 2 according to requirement

  bool get isLoading => _isLoading;
  List<TarotCard> get drawnCards => _drawnCards;
  String? get selectedTopic => _selectedTopic;
  String? get currentQuestion => _currentQuestion;
  String? get userId => _userId;
  bool get isAiLoading => _isAiLoading;
  Map<String, dynamic>? get aiInterpretation => _aiInterpretation;

  int get dailyAiCount => _dailyAiCount;
  bool get canUseAi => _dailyAiCount < maxAiPerDay;

  TarotProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Parallel loading for speed
      await Future.wait([_service.loadCards(), _loadAiUsage()]);
      // initUserIdAndTrack should probably be separate to avoid blocking
      await _initUserIdAndTrack();
    } catch (e) {
      debugPrint("Initialization error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _initUserIdAndTrack() async {
    _userId = await StorageService.getUserId();
    if (_userId == null) {
      _userId = const Uuid().v4();
      await StorageService.setUserId(_userId!);
    }
    // Log visit - DO NOT AWAIT in init to prevent blocking the app
    TrackingService.logVisit(_userId!);
  }

  Future<void> _loadAiUsage() async {
    final lastDateStr = await StorageService.getLastAiDate();
    final todayStr = DateTime.now().toIso8601String().split('T').first;

    if (lastDateStr != todayStr) {
      // New day, reset count
      _dailyAiCount = 0;
      await StorageService.setLastAiDate(todayStr);
      await StorageService.setAiCount(0);
    } else {
      _dailyAiCount = await StorageService.getAiCount();
    }
  }

  Future<void> _incrementAiUsage() async {
    _dailyAiCount++;
    await StorageService.setAiCount(_dailyAiCount);
    notifyListeners();
  }

  void drawCards(int count, {bool useAi = false}) {
    _drawnCards = _service.drawCards(count);
    _aiInterpretation = null; // Reset previous reading
    notifyListeners();

    // Only manually trigger AI if requested AND within limits
    if (useAi && _drawnCards.isNotEmpty && canUseAi) {
      _generateAiReading();
    } else {
      // Log non-AI readings too
      logReading();
    }
  }

  Future<void> _generateAiReading() async {
    _isAiLoading = true;
    notifyListeners();

    try {
      _aiInterpretation = await _aiService.generateReading(
        topic: _selectedTopic,
        question: _currentQuestion,
        cardCount: _drawnCards.length,
        drawnCards: _drawnCards,
      );

      if (_aiInterpretation != null) {
        await _incrementAiUsage();
      }
      // Log AI readings - fire and forget
      logReading();
    } catch (e) {
      // On any failure (network, parsing, missing key), we silently fail.
      // The UI will see aiInterpretation is still null and fallback to the static view.
      _aiInterpretation = null;
      debugPrint("AI Reading Failed: \$e");
    } finally {
      _isAiLoading = false;
      notifyListeners();
    }
  }

  void setTopicAndQuestion(String? topic, String? question) {
    _selectedTopic = topic;
    _currentQuestion = question;
    notifyListeners();
  }

  void clearDrawnCards() {
    _drawnCards = [];
    _aiInterpretation = null;
    _isAiLoading = false;
    notifyListeners();
  }

  Future<void> logReading() async {
    if (_userId == null || _drawnCards.isEmpty) return;

    // Use Vietnamese names for logging to match user expectations
    final cardsStr = _drawnCards
        .map((c) => c.nameVn.isNotEmpty ? c.nameVn : c.name)
        .join(', ');

    String resultStr;
    if (_aiInterpretation != null) {
      resultStr = jsonEncode(_aiInterpretation);
    } else {
      // Build a clear vertical list for default interpretations
      final List<String> lines = [];
      for (int i = 0; i < _drawnCards.length; i++) {
        final card = _drawnCards[i];
        final position = _getSpreadLabel(_drawnCards.length, i);
        final name = card.nameVn.isNotEmpty ? card.nameVn : card.name;
        // Basic meaning joined together
        final meaning = card.fortuneTelling.join(' ');
        lines.add('[$position] $name: $meaning');
      }
      resultStr = lines.join('\n');
    }

    // DEBUG: Print to terminal to verify what is being sent
    debugPrint('--- TRACKING DEBUG ---');
    debugPrint('Type: spread');
    debugPrint('Topic: $_selectedTopic');
    debugPrint('Question: $_currentQuestion');
    debugPrint('Cards: $cardsStr');
    debugPrint('Result Length: ${resultStr.length}');
    debugPrint('----------------------');

    await TrackingService.logSpreadResult(
      userId: _userId!,
      topic: _selectedTopic,
      question: _currentQuestion,
      spreadType: _getSpreadName(_drawnCards.length),
      drawnCards: cardsStr,
      readingType: _aiInterpretation != null ? 'AI' : 'Default',
      interpretationResult: resultStr,
    );
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

  String _getSpreadName(int count) {
    switch (count) {
      case 1:
        return 'Single Card';
      case 3:
        return '3-Card Draw';
      case 5:
        return '5-Card Draw';
      case 10:
        return 'Celtic Cross';
      default:
        return 'Custom';
    }
  }

  void resetSession() {
    clearDrawnCards();
    _selectedTopic = null;
    _currentQuestion = null;
    notifyListeners();
  }
}
