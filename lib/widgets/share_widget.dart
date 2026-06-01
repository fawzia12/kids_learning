import 'package:cached_network_image/cached_network_image.dart';
// lib/widgets/shared_widgets.dart

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

// ---- Duolingo-style pressable button ----
class DuoButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final VoidCallback? onTap;
  final double height;
  final double fontSize;
  final Widget? child;

  const DuoButton({
    super.key,
    this.label = '',
    required this.color,
    required this.shadowColor,
    this.textColor = Colors.white,
    this.onTap,
    this.height = 52,
    this.fontSize = 16,
    this.child,
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap!();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: disabled ? const Color(0xFFE5E5E5) : widget.color,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              bottom: BorderSide(
                color: disabled ? const Color(0xFFAFAFAF) : widget.shadowColor,
                width: _pressed ? 0 : 4,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: widget.child ??
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  color: disabled ? const Color(0xFFAFAFAF) : widget.textColor,
                  letterSpacing: 1.5,
                ),
              ),
        ),
      ),
    );
  }
}

// ---- Top App Bar ----
class KiddyTopBar extends StatelessWidget {
  final bool showStats;
  const KiddyTopBar({super.key, this.showStats = true});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: const Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            alignment: Alignment.center,
            child: const Text('🇺🇸', style: TextStyle(fontSize: 18)),
          ),
          const Spacer(),
          if (showStats) ...[
            _StatPill(
                emoji: '🔥',
                value: '${provider.streak}',
                color: const Color(0xFFFF9600)),
            const SizedBox(width: 8),
            _StatPill(
                emoji: '💎',
                value: '${provider.gems}',
                color: const Color(0xFF1CB0F6)),
            const SizedBox(width: 8),
            _StatPill(
                emoji: '❤️',
                value: '${provider.hearts}',
                color: const Color(0xFFFF4B4B)),
          ],
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String emoji;
  final String value;
  final Color color;

  const _StatPill({
    required this.emoji,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Bottom Nav Bar ----
class KiddyBottomNav extends StatelessWidget {
  const KiddyBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final items = [
      ('🏠', 'Home'),
      ('🔤', 'Letters'),
      ('🏆', 'Quests'),
      ('😎', 'Buddies'),
    ];

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = provider.bottomNavIndex == i;
          return GestureDetector(
            onTap: () => provider.setBottomNav(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFDCF6FC) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: selected
                    ? Border.all(color: const Color(0xFF1CB0F6))
                    : null,
              ),
              child: Text(
                items[i].$1,
                style: TextStyle(
                  fontSize: 26,
                  color: selected ? null : Colors.grey,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---- Network Image with placeholder ----
class KiddyImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const KiddyImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: url.startsWith('http')
          ? CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: fit,
              placeholder: (_, __) => Container(
                color: const Color(0xFFF1F5F9),
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFFF1F5F9),
                child: const Icon(Icons.image_not_supported_outlined,
                    color: Colors.grey),
              ),
            )
          : Image.asset(
              url,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF1F5F9),
                child: const Icon(Icons.image_not_supported_outlined,
                    color: Colors.grey),
              ),
            ),
    );
  }
}

class KiddyProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const KiddyProgressBar(
      {super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE5E5E5),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF58CC02)),
              minHeight: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$current/$total',
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
