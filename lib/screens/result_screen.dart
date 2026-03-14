import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/tarot_provider.dart';
import '../models/tarot_card.dart';
import '../widgets/tarot_card_widget.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _currentIndex = 0;
  bool _isSpreadView = true;
  bool _cardsDealt = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _cardsDealt = true);
    });
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

  Future<void> _exportReading() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final provider = context.read<TarotProvider>();
      final exportWidget = _buildExportWidget(context, provider);

      // Use flutter_long_screenshot to capture the widget
      // We still use captureFromWidget but we can also use specific flutter_long_screenshot methods if needed
      // Actually, captureFromWidget from screenshot package is usually sufficient but user asked for flutter_long_screenshot
      // If flutter_long_screenshot has a different API, I'll adjust.
      // For now, I'll stick to the plan of using a dedicated export widget.

      final image = await _screenshotController.captureFromWidget(
        exportWidget,
        delay: const Duration(milliseconds: 500),
        context: context,
      );

      if (image.isEmpty) return;

      final xFile = XFile.fromData(
        image,
        mimeType: 'image/png',
        name: 'tarot_reading.png',
      );

      await Share.shareXFiles(
        [xFile],
        text: 'Xem trải bài Tarot của mình trên Aether Tarot nhé!',
        subject: 'Aether Tarot',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi chia sẻ: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawnCards = context.watch<TarotProvider>().drawnCards;

    if (drawnCards.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Không có lá bài nào được chọn.")),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportReading,
        backgroundColor: const Color(0xFFFFCC00),
        icon: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Icon(Icons.share, color: Colors.black),
        label: const Text(
          'Chia sẻ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ─── Custom Top Bar ───
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Luận Giải',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          if (drawnCards.length > 1)
                            IconButton(
                              icon: Icon(
                                _isSpreadView
                                    ? Icons.view_carousel
                                    : Icons.grid_view,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() => _isSpreadView = !_isSpreadView);
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.home, color: Colors.white),
                            onPressed: () {
                              context.read<TarotProvider>().clearDrawnCards();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomeScreen(),
                                ),
                                (r) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _isSpreadView && drawnCards.length > 1
                      ? Column(
                          children: [
                            _buildTopicAndQuestion(context),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app_outlined,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Nhấn vào lá bài để xem chi tiết',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: _buildSpreadAnimation(
                                drawnCards,
                                isMobile,
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: Column(
                            children: [
                              _buildTopicAndQuestion(context),
                              _buildCardTabs(drawnCards),
                              isMobile
                                  ? _buildMobileView(drawnCards[_currentIndex])
                                  : _buildDesktopView(
                                      drawnCards[_currentIndex],
                                    ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // ─── Export Footer Logo/QR (Only visible when exporting) ───
                if (_isExporting)
                  Container(
                    color: const Color(0xFF0F0C29),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: Color(0xFFFFCC00),
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'AETHER TAROT',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Quét mã để trải bài ngay hôm nay!',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: QrImageView(
                            data:
                                'https://aethertarot.com', // Replace with link
                            version: QrVersions.auto,
                            size: 50.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpreadAnimation(List<TarotCard> drawnCards, bool isMobile) {
    final size = MediaQuery.of(context).size;
    final double safeAreaHeight =
        size.height - 150; // Reserving space for appbar and chips
    final double safeAreaWidth = size.width - 40; // 20px padding sides

    // Dynamically calculate optimal card size depending on spread type
    double cardWidth = 0;
    double cardHeight = 0;

    if (drawnCards.length == 3) {
      // 3 cards side by side: Width constraint = (safeAreaWidth - 2*spacing) / 3
      cardWidth = (safeAreaWidth - 30) / 3;
      if (cardWidth > 120) cardWidth = 120; // Max cap
      cardHeight = cardWidth * 1.7; // 350x600 ratio
    } else if (drawnCards.length == 5) {
      // 5 cards cross: Needs 3 cards wide, 3 cards tall
      cardWidth = (safeAreaWidth - 30) / 3;
      if (cardWidth > 100) cardWidth = 100; // stricter cap to fit vertically
      cardHeight = cardWidth * 1.7;
      if (cardHeight * 3 + 30 > safeAreaHeight) {
        // Scale down if too tall
        cardHeight = (safeAreaHeight - 30) / 3;
        cardWidth = cardHeight / 1.7;
      }
    } else {
      // 10 cards Celtic Cross: Needs roughly 4 cards wide, 4.5 cards tall
      cardWidth = (safeAreaWidth - 60) / 4;
      if (cardWidth > 80) cardWidth = 80;
      cardHeight = cardWidth * 1.7;
      if (cardHeight * 4.5 + 45 > safeAreaHeight) {
        cardHeight = (safeAreaHeight - 45) / 4.5;
        cardWidth = cardHeight / 1.7;
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const SizedBox.expand(),
        ...List.generate(drawnCards.length, (idx) {
          final card = drawnCards[idx];
          final offset = _getSpreadOffset(
            drawnCards.length,
            idx,
            cardWidth,
            cardHeight,
          );

          // Center the entire spread horizontally and slightly offset vertically
          double centerX = size.width / 2 - cardWidth / 2;
          double centerY = safeAreaHeight / 2 - cardHeight / 2;

          // For Celtic Cross we need to offset the center leftwards
          // because the right staff is heavier
          if (drawnCards.length == 10) {
            centerX -= cardWidth;
          }

          final leftPos = centerX + offset.dx;
          final topPos = centerY + offset.dy;

          return AnimatedPositioned(
            duration: Duration(milliseconds: 600 + (idx * 200)),
            curve: Curves.easeOutBack,
            left: _cardsDealt ? leftPos : size.width / 2 - cardWidth / 2,
            top: _cardsDealt ? topPos : size.height + 200,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = idx;
                  _isSpreadView = false;
                });
              },
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: AbsorbPointer(
                  child: TarotCardWidget(
                    key: ValueKey('spread_${card.name}'),
                    card: card,
                    isMini: true,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Offset _getSpreadOffset(int totalCards, int idx, double w, double h) {
    double spacing = w * 0.15; // Proportional spacing

    if (totalCards == 3) {
      if (idx == 0) return Offset(-w - spacing, 0);
      if (idx == 1) return const Offset(0, 0);
      return Offset(w + spacing, 0);
    } else if (totalCards == 5) {
      if (idx == 0) return Offset(-w - spacing, 0);
      if (idx == 1) return const Offset(0, 0);
      if (idx == 2) return Offset(w + spacing, 0);
      if (idx == 3) return Offset(0, -h - spacing);
      if (idx == 4) return Offset(0, h + spacing);
    } else if (totalCards == 10) {
      if (idx == 0) return const Offset(0, 0);
      if (idx == 1) return const Offset(15, 15);
      if (idx == 2) return Offset(0, h + spacing);
      if (idx == 3) return Offset(-w - spacing, 0);
      if (idx == 4) return Offset(0, -h - spacing);
      if (idx == 5) return Offset(w + spacing, 0);

      double rightX = (w * 2) + spacing * 2;
      double startY = h * 1.5 + spacing;
      if (idx == 6) return Offset(rightX, startY);
      if (idx == 7) return Offset(rightX, startY - h - spacing);
      if (idx == 8) return Offset(rightX, startY - (h + spacing) * 2);
      if (idx == 9) return Offset(rightX, startY - (h + spacing) * 3);
    }
    return const Offset(0, 0);
  }

  Widget _buildTopicAndQuestion(BuildContext context) {
    if (context.read<TarotProvider>().selectedTopic == null &&
        context.read<TarotProvider>().currentQuestion == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8B00FF).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (context.read<TarotProvider>().selectedTopic != null)
              Row(
                children: [
                  const Icon(
                    Icons.bookmark_border,
                    color: Color(0xFFFFCC00),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Chủ đề: ${context.read<TarotProvider>().selectedTopic}',
                    style: const TextStyle(
                      color: Color(0xFFFFCC00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            if (context.read<TarotProvider>().selectedTopic != null &&
                context.read<TarotProvider>().currentQuestion != null)
              const SizedBox(height: 8),
            if (context.read<TarotProvider>().currentQuestion != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.question_answer_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '"${context.read<TarotProvider>().currentQuestion}"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTabs(List<TarotCard> drawnCards) {
    if (drawnCards.length <= 1 || _isSpreadView) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(drawnCards.length, (idx) {
            String position = _getSpreadLabel(drawnCards.length, idx);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(position),
                selected: _currentIndex == idx,
                onSelected: (val) {
                  if (val) setState(() => _currentIndex = idx);
                },
                selectedColor: const Color(0xFF8B00FF),
                backgroundColor: Colors.white12,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMobileView(TarotCard card) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Card Flip Animation Area
          SizedBox(
            height: 350,
            width: 200,
            // Use UniqueKey to force rebuilding/re-animating when switching tabs
            child: TarotCardWidget(key: ValueKey(card.name), card: card),
          ),
          const SizedBox(height: 24),
          _buildInterpretation(card),
        ],
      ),
    );
  }

  Widget _buildDesktopView(TarotCard card) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Center(
            child: SizedBox(
              height: 500,
              width: 300,
              child: TarotCardWidget(key: ValueKey(card.name), card: card),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _buildInterpretation(card),
          ),
        ),
      ],
    );
  }

  Widget _buildInterpretation(TarotCard card) {
    return Consumer<TarotProvider>(
      builder: (context, provider, child) {
        if (provider.isAiLoading) {
          return _buildLoadingState();
        }

        if (provider.aiInterpretation != null) {
          return _buildAiInterpretation(provider.aiInterpretation!);
        }

        return _buildStaticInterpretation(card);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B00FF).withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Mystical loading spinner
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: const Color(0xFFFFCC00),
              strokeWidth: 2,
              backgroundColor: const Color(0xFF8B00FF).withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Vũ trụ đang gửi thông điệp...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFCC00),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Xin hãy chờ trong giây lát để nhận lời giải đáp\ncho năng lượng của bạn lúc này.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAiInterpretation(Map<String, dynamic> aiData) {
    final String summary = aiData['summary'] ?? '';
    final String advice = aiData['advice'] ?? '';
    final String energy = aiData['energy'] ?? '';
    final String outcome = aiData['possible_outcome'] ?? '';
    final List cardsInterp = aiData['cards_interpretation'] ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B00FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFFFFCC00)),
              SizedBox(width: 8),
              Text(
                'LỜI GIẢI TỪ VŨ TRỤ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFCC00),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Summary
          if (summary.isNotEmpty) ...[
            _buildSectionTitle('Tóm tắt thông điệp', Icons.lightbulb_outline),
            _buildParagraph(summary),
            const SizedBox(height: 24),
          ],

          // Card by Card
          if (cardsInterp.isNotEmpty) ...[
            _buildSectionTitle(
              'Phân tích chi tiết',
              Icons.view_carousel_outlined,
            ),
            ...cardsInterp.map((cardData) {
              final name = cardData['card_name'] ?? '';
              final position = cardData['position'] ?? '';
              final interp = cardData['interpretation'] ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[$position]\n$name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B00FF),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        interp,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
          ],

          // Advice
          if (advice.isNotEmpty) ...[
            _buildSectionTitle('Lời khuyên hành động', Icons.explore_outlined),
            _buildParagraph(advice),
            const SizedBox(height: 24),
          ],

          // Energy & Outcome
          if (energy.isNotEmpty) ...[
            _buildSectionTitle('Năng lượng hiện tại', Icons.bolt),
            _buildParagraph(energy),
            const SizedBox(height: 24),
          ],

          if (outcome.isNotEmpty) ...[
            _buildSectionTitle('Kết quả tiềm năng', Icons.stars_outlined),
            _buildParagraph(outcome),
          ],
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.6),
    );
  }

  Widget _buildStaticInterpretation(TarotCard card) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.nameVn.isNotEmpty ? card.nameVn : card.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFCC00),
            ),
          ),
          if (card.nameVn.isNotEmpty)
            Text(
              card.name,
              style: const TextStyle(
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 16),

          _buildStaticSectionTitle('Từ khóa'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: card.keywords.map((kw) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B00FF).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  kw,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          _buildStaticSectionTitle('Tiên đoán nhanh'),
          ...card.fortuneTelling
              .map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),

          const SizedBox(height: 24),
          _buildStaticSectionTitle('Ý Nghĩa Sáng (Tích cực)'),
          if (card.meaningsLight.isNotEmpty &&
              card.meaningsLight.containsKey('light'))
            ...card.meaningsLight['light']!.map((m) => _buildBulletText(m)),

          const SizedBox(height: 24),
          _buildStaticSectionTitle('Ý Nghĩa Tối (Cảnh báo)'),
          if (card.meaningsShadow.isNotEmpty &&
              card.meaningsShadow.containsKey('shadow'))
            ...card.meaningsShadow['shadow']!.map((m) => _buildBulletText(m)),

          const SizedBox(height: 24),
          _buildStaticSectionTitle('Câu hỏi tự vấn'),
          ...card.questionsToAsk
              .map(
                (q) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '❓ $q',
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8B00FF), size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFF8B00FF),
        ),
      ),
    );
  }

  Widget _buildBulletText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              color: Color(0xFFFFCC00),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── FULL SCREEN EXPORT WIDGET ─────────
  Widget _buildExportWidget(BuildContext context, TarotProvider provider) {
    final drawnCards = provider.drawnCards;

    // Wrap in MaterialApp and Material to provide Localizations and correct text styling
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        fontFamily: 'Be Vietnam Pro', // Use consistent font
      ),
      home: Material(
        child: Container(
          width: 800,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'AETHER TAROT - LUẬN GIẢI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color(0xFFFFCC00),
                    ),
                  ),
                ),
              ),

              // Topic and Question
              if (provider.selectedTopic != null ||
                  provider.currentQuestion != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF8B00FF).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (provider.selectedTopic != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bookmark_border,
                                color: Color(0xFFFFCC00),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Chủ đề: ${provider.selectedTopic}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFFFFCC00),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (provider.selectedTopic != null &&
                            provider.currentQuestion != null)
                          const SizedBox(height: 16),
                        if (provider.currentQuestion != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.question_answer_outlined,
                                color: Colors.white70,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '"${provider.currentQuestion}"',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Cards Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 24,
                  runSpacing: 24,
                  children: drawnCards.map((card) {
                    return SizedBox(
                      width: 140,
                      height: 140 * 1.7,
                      child: TarotCardWidget(
                        card: card,
                        isMini: true,
                        animateFlip: false,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 48),

              // Interpretations
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: provider.aiInterpretation != null
                    ? _buildAiInterpretation(provider.aiInterpretation!)
                    : Column(
                        children: drawnCards
                            .map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: _buildStaticInterpretation(c),
                              ),
                            )
                            .toList(),
                      ),
              ),

              const SizedBox(height: 64),

              // Footer
              Container(
                color: const Color(0xFF0F0C29),
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 48,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Color(0xFFFFCC00),
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'AETHER TAROT',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Quét mã để trải bài nay!',
                          style: TextStyle(fontSize: 16, color: Colors.white54),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: QrImageView(
                        data: 'https://aethertarot.com',
                        version: QrVersions.auto,
                        size: 80.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
