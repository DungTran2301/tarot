import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tarot_provider.dart';
import 'draw_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _bgImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuByz_AGdNELzhxqGOcrDfrZvTTqCpjF2RdfDCnvCDjMnPHO4qZMm4y67ngH2yULGukRRP9K40GPXouOUwVq2HlSwGPO3N7wnZNw37Tek1YuN-iGiRTM_i20Vgkl-gA2ZDT8ImAhYhFjW2-4s9Wr_G_S9r2UyZJz9PBglv8h_2xpazcOpwcWdYwVzbbjsls1uXBgIpLEibM1aZhBcLlqd-Zc7PhmaiW8qqZuk9HhSm0uhZXEbk34NqtjKJ4lWasLhlX1TLhEZE4qTwW9';

  // -- Colors --
  static const _gold = Color(0xFFFFCC00);
  static const _purple = Color(0xFF8B00FF);
  static const _deepBg = Color(0xFF0F0C29);
  static const _midBg = Color(0xFF1A1540);
  static const _cardBg = Color(0xFF1E1848);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TarotProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_deepBg, Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: _gold))
            : SafeArea(
                child: isDesktop
                    ? _buildDesktopLayout(context)
                    : _buildMobileLayout(context),
              ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── App Bar ───
          _buildAppBar(),
          const SizedBox(height: 16),

          // ─── Hero Banner ───
          _buildHeroBanner(),
          const SizedBox(height: 28),

          // ─── Section Title ───
          const Center(
            child: Text(
              'Chọn Trải Bài',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Spread Options ───
          _buildSpreadOptions(context),

          const SizedBox(height: 24),

          // ─── Feeling Lost CTA ───
          _buildFeelingLostSection(context),
          const SizedBox(height: 20),

          // ─── Daily Quote ───
          _buildDailyQuoteWidget(),
          const SizedBox(height: 16),

          // ─── Disclaimer ───
          _buildDisclaimer(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: Column(
        children: [
          _buildAppBar(),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroBanner(),
                        const SizedBox(height: 32),
                        _buildFeelingLostSection(context),
                        const SizedBox(height: 20),
                        _buildDailyQuoteWidget(),
                        const SizedBox(height: 20),
                        _buildDisclaimer(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 48),
                // Right Column
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Chọn Trải Bài',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSpreadOptions(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpreadOptions(BuildContext context) {
    return Column(
      children: [
        _buildSpreadCard(
          context,
          category: 'THÔNG ĐIỆP HẰNG NGÀY',
          title: 'Rút 1 Lá',
          subtitle: 'Lướt nhanh qua những năng lượng bao quanh bạn hôm nay.',
          icon: Icons.auto_awesome,
          cardCount: 1,
        ),
        const SizedBox(height: 12),
        _buildSpreadCard(
          context,
          category: 'QUÁ KHỨ / HIỆN TẠI / TƯƠNG LAI',
          title: 'Rút 3 Lá',
          subtitle: 'Hiểu sâu hơn về dòng thời gian hiện tại của cuộc đời bạn.',
          icon: Icons.view_column_rounded,
          cardCount: 3,
        ),
        const SizedBox(height: 12),
        _buildSpreadCard(
          context,
          category: 'TRẢI BÀI CHÉO',
          title: 'Rút 5 Lá',
          subtitle:
              'Khám phá những trở ngại và yếu tố ảnh hưởng trên con đường của bạn.',
          icon: Icons.grid_view_rounded,
          cardCount: 5,
        ),
        const SizedBox(height: 12),
        _buildSpreadCard(
          context,
          category: 'THẬP TỰ GIÁ CELTIC',
          title: 'Rút 10 Lá',
          subtitle: 'Hướng dẫn toàn diện nhất cho vận mệnh tâm linh của bạn.',
          icon: Icons.blur_circular,
          cardCount: 10,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // App Bar
  // ──────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: _gold, size: 22),
          const SizedBox(width: 8),
          const Text(
            'AETHER TAROT',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Disclaimer
  // ──────────────────────────────────────────────
  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.white54, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Aether Tarot được tạo ra với mục đích giải trí và chữa lành nhẹ nhàng. Vũ trụ chỉ gợi ý, quyền quyết định luôn thuộc về bạn! Không nên tin tưởng quá cứng nhắc nhé.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Hero Banner
  // ──────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            CachedNetworkImage(
              imageUrl: _bgImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2D1B69), Color(0xFF0F0C29)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2D1B69), Color(0xFF0F0C29)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Dark overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
            // Text content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Thông điệp từ vũ trụ',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Các vì sao đã sắp đặt cho hành trình của bạn.\nHãy chọn một con đường để hé lộ\nnhững sự thật ẩn giấu trong tâm hồn.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Spread Option Card
  // ──────────────────────────────────────────────
  Widget _buildSpreadCard(
    BuildContext context, {
    required String category,
    required String title,
    required String subtitle,
    required IconData icon,
    required int cardCount,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToDraw(context, cardCount),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _gold, size: 24),
              ),
              const SizedBox(width: 14),
              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: _gold.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Feeling Lost CTA
  // ──────────────────────────────────────────────
  Widget _buildFeelingLostSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: _midBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          const Text(
            'Cảm Thấy Lạc Lối?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy để Oracle chọn trải bài phù hợp nhất\ncho rung động hiện tại của bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.55),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          // Random Spread button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final counts = [1, 3, 5, 10];
                final randomCount = counts[Random().nextInt(counts.length)];
                _navigateToDraw(context, randomCount);
              },
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text(
                'Trải Bài Ngẫu Nhiên',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: const Color(0xFF1A1540),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Navigation helper
  // ──────────────────────────────────────────────
  void _navigateToDraw(BuildContext context, int cardCount) {
    _showPreDrawBottomSheet(context, cardCount);
  }

  void _showPreDrawBottomSheet(BuildContext context, int cardCount) {
    String? selectedTopic;
    final TextEditingController questionController = TextEditingController();

    final List<Map<String, dynamic>> topics = [
      {'label': 'Tình yêu', 'icon': Icons.favorite, 'value': 'Love'},
      {'label': 'Sự nghiệp', 'icon': Icons.work, 'value': 'Career'},
      {'label': 'Tài chính', 'icon': Icons.payments, 'value': 'Finance'},
      {
        'label': 'Phát triển bản thân',
        'icon': Icons.eco,
        'value': 'Self development',
      },
      {
        'label': 'Tổng quan',
        'icon': Icons.auto_awesome_motion,
        'value': 'General',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      const Text(
                        'Chuẩn bị giải bài',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _gold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tập trung năng lượng vào vấn đề bạn quan tâm.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'CHỌN CHỦ ĐỀ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 12,
                        children: topics.map((topic) {
                          final isSelected = selectedTopic == topic['label'];
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  topic['icon'] as IconData,
                                  size: 16,
                                  color: isSelected ? Colors.white : _gold,
                                ),
                                const SizedBox(width: 8),
                                Text(topic['label'] as String),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                selectedTopic = selected
                                    ? topic['label']
                                    : null;
                              });
                            },
                            backgroundColor: _midBg,
                            selectedColor: _purple.withOpacity(0.4),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? _gold : Colors.white12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'CÂU HỎI CỦA BẠN (TÙY CHỌN)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: questionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: _getHintTextForTopic(selectedTopic),
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          filled: true,
                          fillColor: _midBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _purple.withOpacity(0.5),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ─── AI Limit Banner ───
                      Consumer<TarotProvider>(
                        builder: (context, provider, child) {
                          if (!provider.canUseAi) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.redAccent.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lock_clock,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Bạn đã dùng hết ${TarotProvider.maxAiPerDay} lượt luận giải nâng cao hôm nay.\nBài rút vẫn sẽ hiển thị luận giải cơ bản.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // ─── Action Button ───
                      Consumer<TarotProvider>(
                        builder: (context, provider, child) {
                          final canUseAi = provider.canUseAi;

                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canUseAi
                                  ? _gold
                                  : Colors.white24,
                              foregroundColor: canUseAi
                                  ? _deepBg
                                  : Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              // Format question (capitalize first letter, add question mark if missing)
                              String rawQ = questionController.text.trim();
                              if (rawQ.isNotEmpty) {
                                rawQ =
                                    rawQ[0].toUpperCase() + rawQ.substring(1);
                                if (!rawQ.endsWith('?')) {
                                  rawQ += '?';
                                }
                              }
                              ctx.read<TarotProvider>().setTopicAndQuestion(
                                canUseAi ? selectedTopic : null,
                                canUseAi ? (rawQ.isEmpty ? null : rawQ) : null,
                              );

                              // Close modal and navigate
                              Navigator.pop(ctx);
                              ctx.read<TarotProvider>().clearDrawnCards();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DrawScreen(cardCount: cardCount),
                                ),
                              );
                            },
                            child: Text(
                              canUseAi
                                  ? 'BẮT ĐẦU TRẢI BÀI'
                                  : 'RÚT BÀI (CƠ BẢN)',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getHintTextForTopic(String? topic) {
    switch (topic) {
      case 'Tình yêu':
        return 'VD: Người ấy đang nghĩ gì về mình?';
      case 'Sự nghiệp':
        return 'VD: Sắp tới mình có cơ hội thăng tiến không?';
      case 'Tài chính':
        return 'VD: Nên đầu tư vào đâu cuối năm nay?';
      case 'Phát triển bản thân':
        return 'VD: Bài học mình cần nắm bắt ngay lúc này?';
      default:
        return 'VD: Vũ trụ muốn nói gì với mình hôm nay?';
    }
  }

  // ──────────────────────────────────────────────
  // Daily Quote Widget
  // ──────────────────────────────────────────────
  Widget _buildDailyQuoteWidget() {
    const quotes = [
      'Tương lai không phải là điều để dự đoán, mà là thứ để kiến tạo thông qua sự hiểu biết về hiện tại.',
      'Mỗi lá bài là một tấm gương phản chiếu tâm hồn bạn.',
      'Vũ trụ luôn gửi đến bạn những tín hiệu, chỉ cần bạn biết lắng nghe.',
      'Con đường phía trước sẽ sáng tỏ khi bạn hiểu được chính mình.',
      'Hãy tin vào trực giác, đó là tiếng nói của linh hồn bạn.',
      'Mọi kết thúc đều là khởi đầu của một hành trình mới.',
      'Ánh sáng bên trong bạn mạnh hơn bóng tối bao quanh.',
      'Không có sự trùng hợp nào trong vũ trụ, chỉ có sự sắp đặt.',
      'Hãy để trái tim dẫn lối khi lý trí không tìm ra câu trả lời.',
      'Sự thay đổi là quy luật vĩnh cửu, hãy đón nhận với tâm thế bình an.',
    ];

    // Pick a quote based on the day of the year so it changes daily
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year))
        .inDays;
    final quoteIndex = dayOfYear % quotes.length;
    final quote = quotes[quoteIndex];
    final quoteNumber = (dayOfYear % 100) + 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _purple.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number
          Text(
            '$quoteNumber',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: _gold.withOpacity(0.7),
              height: 1,
            ),
          ),
          const SizedBox(width: 16),
          // Quote text
          Expanded(
            child: Text(
              '"$quote"',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.75),
                height: 1.55,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
