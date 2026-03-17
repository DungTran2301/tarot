import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/tarot_card.dart';
import '../utils/constants.dart';

class TarotCardWidget extends StatefulWidget {
  final TarotCard card;
  final bool animateFlip;
  final bool isMini;
  final VoidCallback? onCardFlipped;

  const TarotCardWidget({
    super.key,
    required this.card,
    this.animateFlip = true,
    this.isMini = false,
    this.onCardFlipped,
  });

  @override
  State<TarotCardWidget> createState() => TarotCardWidgetState();
}

class TarotCardWidgetState extends State<TarotCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween(
      begin: 0.0,
      end: pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Automatically flip if set
    if (widget.animateFlip) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _audioPlayer.play(AssetSource('audio/flip.wav'));
          _controller.forward().then((_) {
            if (widget.onCardFlipped != null) widget.onCardFlipped!();
          });
          _controller.forward().then((_) {
            if (widget.onCardFlipped != null) widget.onCardFlipped!();
          });
        }
      });
    } else {
      _controller.value = pi;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void flipCard() {
    _audioPlayer.play(AssetSource('audio/flip.wav'));
    if (_controller.value == 0) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value;
        final isUnder = angle > pi / 2;

        return Transform(
          transform: Matrix4.rotationY(angle)..setEntry(3, 2, 0.001),
          alignment: Alignment.center,
          child: isUnder ? _buildFront() : _buildBack(),
        );
      },
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.isMini ? 6 : 12),
        image: const DecorationImage(
          image: CachedNetworkImageProvider(
            '${AppConstants.cardImageBaseUrl}/card_back.jpg',
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(4, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildFront() {
    // Need to flip horizontal because the card surface rotates 180 degrees
    return Transform(
      transform: Matrix4.rotationY(pi),
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isMini ? 6 : 12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFCC00).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(
            widget.isMini ? 3.0 : 12.0,
          ), // Shrinks padding dynamically
          child: CachedNetworkImage(
            imageUrl: '${AppConstants.cardImageBaseUrl}/${widget.card.img}',
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFF4A0E4E),
              child: const Center(
                child: Icon(Icons.style, color: Colors.white54, size: 40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
