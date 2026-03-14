import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tarot_provider.dart';
import 'result_screen.dart';

class DrawScreen extends StatefulWidget {
  final int cardCount;

  const DrawScreen({super.key, required this.cardCount});

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCount = 0;
  final List<int> _selectedIndices = [];
  late AnimationController _fanController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Colors
  static const _gold = Color(0xFFFFCC00);
  static const _purple = Color(0xFF8B00FF);
  static const _deepBg = Color(0xFF0F0C29);
  static const _cardBg = Color(0xFF1E1848);

  // Slot labels for different spread types
  List<_SlotInfo> get _slotInfos {
    switch (widget.cardCount) {
      case 1:
        return [const _SlotInfo('THÔNG ĐIỆP', Icons.auto_awesome)];
      case 3:
        return [
          const _SlotInfo('QUÁ KHỨ', Icons.edit_note_rounded),
          const _SlotInfo('HIỆN TẠI', Icons.auto_awesome),
          const _SlotInfo('TƯƠNG LAI', Icons.visibility_outlined),
        ];
      case 5:
        return [
          const _SlotInfo('VẤN ĐỀ', Icons.help_outline),
          const _SlotInfo('ẢNH HƯỞNG', Icons.sync_alt),
          const _SlotInfo('NỀN TẢNG', Icons.foundation),
          const _SlotInfo('QUÁ KHỨ', Icons.history),
          const _SlotInfo('TƯƠNG LAI', Icons.visibility_outlined),
        ];
      case 10:
        return [
          const _SlotInfo('HIỆN TẠI', Icons.auto_awesome),
          const _SlotInfo('THỬ THÁCH', Icons.block),
          const _SlotInfo('NỀN TẢNG', Icons.foundation),
          const _SlotInfo('QUÁ KHỨ', Icons.history),
          const _SlotInfo('MỤC TIÊU', Icons.flag_outlined),
          const _SlotInfo('TƯƠNG LAI', Icons.visibility_outlined),
          const _SlotInfo('BẢN THÂN', Icons.person_outline),
          const _SlotInfo('MÔI TRƯỜNG', Icons.public),
          const _SlotInfo('HY VỌNG', Icons.favorite_border),
          const _SlotInfo('KẾT QUẢ', Icons.stars_outlined),
        ];
      default:
        return List.generate(
          widget.cardCount,
          (i) => _SlotInfo('LÁ ${i + 1}', Icons.auto_awesome),
        );
    }
  }

  // Heading per spread type
  String get _spreadHeading {
    switch (widget.cardCount) {
      case 1:
        return 'Thông điệp trong ngày';
      case 3:
        return 'Hành trình linh hồn';
      case 5:
        return 'Trải bài chữ thập';
      case 10:
        return 'Thập tự giá Celtic';
      default:
        return 'Trải bài Tarot';
    }
  }

  // Mystical status messages
  static const _statusMessages = [
    'Duyên nợ: Đang kết nối...',
    'Năng lượng: Đang hội tụ...',
    'Vũ trụ: Đang lắng nghe...',
    'Tâm linh: Đang cộng hưởng...',
    'Trực giác: Đang thức tỉnh...',
  ];

  late String _statusMessage;

  @override
  void initState() {
    super.initState();
    _fanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _statusMessage = _statusMessages[Random().nextInt(_statusMessages.length)];
  }

  @override
  void dispose() {
    _fanController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onCardTap(int index) {
    if (_selectedIndices.contains(index)) return;
    if (_selectedCount >= widget.cardCount) return;

    _audioPlayer.play(AssetSource('audio/draw.wav'));

    setState(() {
      _selectedIndices.add(index);
      _selectedCount++;
    });
  }

  void _onRevealPressed({bool useAi = false}) {
    if (_selectedCount < widget.cardCount) return;
    final provider = context.read<TarotProvider>();
    provider.drawCards(widget.cardCount, useAi: useAi);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ResultScreen()),
    );
  }

  Widget _buildActionButtons(TarotProvider provider) {
    final bool allSelected = _selectedCount == widget.cardCount;
    final bool canUseAi = provider.canUseAi;
    final int remainingAi = TarotProvider.maxAiPerDay - provider.dailyAiCount;

    return AnimatedOpacity(
      opacity: allSelected ? 1.0 : 0.35,
      duration: const Duration(milliseconds: 400),
      child: Column(
        children: [
          // AI Reading Button (Primary)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (allSelected && canUseAi)
                  ? () => _onRevealPressed(useAi: true)
                  : null,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(
                canUseAi
                    ? 'Luận giải chuyên sâu (Còn $remainingAi lượt)'
                    : 'HẾT LƯỢT CHIÊM NGHIỆM SÂU HÔM NAY',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _purple.withOpacity(0.3),
                disabledForegroundColor: Colors.white38,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: canUseAi ? 6 : 0,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Standard Reading Button (Secondary)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: allSelected
                  ? () => _onRevealPressed(useAi: false)
                  : null,
              child: const Text(
                'XEM LỜI GIẢI CƠ BẢN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white38,
                side: BorderSide(
                  color: allSelected ? Colors.white54 : Colors.white12,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Trải Bài Tarot',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white70,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.white70,
                size: 16,
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_deepBg, Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ─── Heading ───
              Text(
                _spreadHeading,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // ─── Topic / Question Display ───
              Consumer<TarotProvider>(
                builder: (context, provider, child) {
                  final topic = provider.selectedTopic;
                  final q = provider.currentQuestion;
                  if (topic == null && (q == null || q.isEmpty))
                    return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          if (topic != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.category_outlined,
                                  size: 16,
                                  color: Color(0xFFFFCC00),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    topic,
                                    style: const TextStyle(
                                      color: Color(0xFFFFCC00),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          if (topic != null && q != null && q.isNotEmpty)
                            const SizedBox(height: 4),
                          if (q != null && q.isNotEmpty)
                            Text(
                              '"$q"',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
              Text(
                'Hãy tập trung tâm trí và chọn ${widget.cardCount} lá bài',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 20),

              // ─── Card Slots ───
              _buildCardSlots(),
              const SizedBox(height: 16),

              // ─── Status Row ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BỘ BÀI 78 LÁ (ẨN SỐ)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _purple.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // ─── Fan Spread (existing animation) ───
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    const SizedBox.expand(),
                    ...List.generate(22, (index) {
                      double cardWidth = isMobile ? 70 : 120;
                      double cardHeight = isMobile ? 120 : 205;

                      double totalAngle = 3.14;
                      double angleStep = totalAngle / 21;
                      double angle = -totalAngle / 2 + (index * angleStep);

                      bool isSelected = _selectedIndices.contains(index);

                      // Radius of the fan arc
                      double fanRadius = isMobile ? 110 : 250;

                      return AnimatedBuilder(
                        animation: _fanController,
                        builder: (context, child) {
                          double curve = Curves.easeOutBack.transform(
                            _fanController.value,
                          );
                          double dx = fanRadius * curve * sin(angle);
                          double dy = fanRadius * curve * (1 - cos(angle));

                          if (isSelected) {
                            dy -= 25;
                          }

                          return Transform.translate(
                            offset: Offset(dx, dy - fanRadius * 0.5),
                            child: Transform.rotate(
                              angle: angle * curve,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _onCardTap(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: cardWidth,
                                  height: cardHeight,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected
                                        ? Border.all(color: _gold, width: 2)
                                        : null,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: _gold.withOpacity(0.6),
                                              blurRadius: 15,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black54,
                                              blurRadius: 4,
                                              offset: const Offset(2, 2),
                                            ),
                                          ],
                                    image: const DecorationImage(
                                      image: AssetImage(
                                        'assets/images/cards/card_back.jpg',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),

              // ─── CTA Buttons ───
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Consumer<TarotProvider>(
                  builder: (context, provider, child) {
                    return _buildActionButtons(provider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Card Position Slots
  // ──────────────────────────────────────────────
  Widget _buildCardSlots() {
    final slots = _slotInfos;
    final isManyCards = widget.cardCount > 5;

    if (isManyCards) {
      // For 10-card: use a grid layout
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(slots.length, (i) {
            final filled = i < _selectedCount;
            return _buildSingleSlot(slots[i], filled, compact: true);
          }),
        ),
      );
    }

    // For 1, 3, 5 cards: horizontal row
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(slots.length, (i) {
          final filled = i < _selectedCount;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.cardCount <= 3 ? 8 : 4,
            ),
            child: _buildSingleSlot(slots[i], filled),
          );
        }),
      ),
    );
  }

  Widget _buildSingleSlot(_SlotInfo info, bool filled, {bool compact = false}) {
    // Card ratio is 350:600 = 7:12
    final slotHeight = compact ? 84.0 : (widget.cardCount <= 3 ? 120.0 : 84.0);
    final slotWidth = slotHeight * 7 / 12;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          width: slotWidth,
          height: slotHeight,
          decoration: BoxDecoration(
            color: filled ? _purple.withOpacity(0.3) : _cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filled ? _gold.withOpacity(0.7) : _purple.withOpacity(0.3),
              width: filled ? 2 : 1,
            ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: _gold.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: filled
                ? ClipRRect(
                    key: const ValueKey('filled'),
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/cards/card_back.jpg',
                      width: slotWidth,
                      height: slotHeight,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    info.icon,
                    color: _purple.withOpacity(0.5),
                    size: compact ? 20 : 26,
                    key: const ValueKey('empty'),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          info.label,
          style: TextStyle(
            fontSize: compact ? 8 : 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: filled ? _gold.withOpacity(0.9) : _purple.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

// Helper class for slot info
class _SlotInfo {
  final String label;
  final IconData icon;
  const _SlotInfo(this.label, this.icon);
}
