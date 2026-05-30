import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import '../providers/app_provider.dart';

class BuddyWidget extends StatefulWidget {
  final double size;
  const BuddyWidget({super.key, this.size = 80});

  @override
  State<BuddyWidget> createState() => _BuddyWidgetState();
}

class _BuddyWidgetState extends State<BuddyWidget>
    with TickerProviderStateMixin {
  // -- idle: gentle float
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;
  // -- wave: rotate back/forth (arm wave via rotate)
  late AnimationController _waveCtrl;
  late Animation<double> _waveAnim;
  // -- jump: bounce up on lesson complete
  late AnimationController _jumpCtrl;
  late Animation<double> _jumpAnim;
  // -- excited: fast scale pulse on streak
  late AnimationController _excitedCtrl;
  late Animation<double> _excitedAnim;
  // -- sad: droop (translate down + scale)
  late AnimationController _sadCtrl;
  late Animation<double> _sadAnim;
  // -- sleeping: slow fade/scale breathe
  late AnimationController _sleepCtrl;
  late Animation<double> _sleepAnim;

  String _lastMood = 'idle';

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _waveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _waveAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 0.35), weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.35, end: -0.25), weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: -0.25, end: 0.35), weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.35, end: -0.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -0.2, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _waveCtrl, curve: Curves.easeInOut));

    _jumpCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _jumpAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -30), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -30, end: 4), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _jumpCtrl, curve: Curves.easeOut));

    _excitedCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180))
      ..repeat(reverse: true);
    _excitedAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _excitedCtrl, curve: Curves.easeInOut),
    );

    _sadCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _sadAnim = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _sadCtrl, curve: Curves.easeOut),
    );

    _sleepCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _sleepAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _sleepCtrl, curve: Curves.easeInOut),
    );
  }

  void _applyMood(String mood) {
    if (mood == _lastMood) return;
    _lastMood = mood;

    // Stop all
    _waveCtrl.stop();
    _waveCtrl.reset();
    _jumpCtrl.stop();
    _jumpCtrl.reset();
    _sadCtrl.stop();
    _sadCtrl.reset();
    if (_excitedCtrl.isAnimating) _excitedCtrl.stop();
    if (_sleepCtrl.isAnimating) _sleepCtrl.stop();
    _floatCtrl.stop();

    switch (mood) {
      case 'wave':
        _waveCtrl.duration = const Duration(milliseconds: 1800);
        _waveCtrl.repeat(reverse: false);
        break;
      case 'happy':
      case 'celebrating':
        _jumpCtrl.forward();
        _floatCtrl.repeat(reverse: true);
        break;
      case 'excited':
        _excitedCtrl.repeat(reverse: true);
        break;
      case 'sad':
        _sadCtrl.forward();
        _floatCtrl.repeat(reverse: true);
        break;
      case 'sleeping':
        _sleepCtrl.repeat(reverse: true);
        break;
      default: // idle / talking
        _floatCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _waveCtrl.dispose();
    _jumpCtrl.dispose();
    _excitedCtrl.dispose();
    _sadCtrl.dispose();
    _sleepCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final mood = provider.characterMood;
    final assetPath = provider.selectedBuddy;
    _applyMood(mood);

    return GestureDetector(
      onTap: provider.onCharacterTap,
      child: SizedBox(
        width: widget.size + 40,
        height: widget.size + 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sleeping Zzz
            if (mood == 'sleeping')
              Positioned(
                top: 2,
                right: 8,
                child: AnimatedBuilder(
                  animation: _sleepCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _sleepAnim.value,
                    child: const Text('💤', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            // Excited stars
            if (mood == 'excited') ...[
              Positioned(
                  top: 4,
                  left: 10,
                  child: _SparkDot(ctrl: _excitedCtrl, delay: 0)),
              Positioned(
                  top: 4,
                  right: 10,
                  child: _SparkDot(ctrl: _excitedCtrl, delay: 0.3)),
            ],
            // Main buddy
            AnimatedBuilder(
              animation: Listenable.merge([
                _floatCtrl,
                _waveCtrl,
                _jumpCtrl,
                _excitedCtrl,
                _sadCtrl,
                _sleepCtrl,
              ]),
              builder: (_, __) {
                double dy = 0;
                double scale = 1.0;
                double rotate = 0;

                switch (mood) {
                  case 'idle':
                  case 'talking':
                    dy = _floatAnim.value;
                    break;
                  case 'wave':
                    dy = _floatAnim.isAnimating ? _floatAnim.value : 0;
                    rotate = _waveAnim.value;
                    break;
                  case 'happy':
                  case 'celebrating':
                    dy = _jumpAnim.value +
                        (_floatAnim.isAnimating ? _floatAnim.value * 0.3 : 0);
                    scale = 1.1;
                    break;
                  case 'excited':
                    scale = _excitedAnim.value;
                    break;
                  case 'sad':
                    dy = _sadAnim.value;
                    scale = 0.9;
                    break;
                  case 'sleeping':
                    scale = _sleepAnim.value;
                    break;
                }

                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: rotate,
                      child: SizedBox(
                        width: widget.size * 1.5,
                        height: widget.size * 1.5,
                        child: DotLottieView(
                          sourceType: 'url',
                          source: assetPath,
                          autoplay: true,
                          loop: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Mood badge
            Positioned(
              bottom: 4,
              right: 4,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _moodBadge(mood),
                  key: ValueKey(mood),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _bubbleColor(String mood) {
    switch (mood) {
      case 'celebrating':
      case 'happy':
        return const Color(0xFFD7FFB8);
      case 'excited':
        return const Color(0xFFFFF3C4);
      case 'sad':
        return const Color(0xFFFFE0E0);
      case 'sleeping':
        return const Color(0xFFE0EAFF);
      case 'wave':
        return const Color(0xFFE0F7FF);
      default:
        return const Color(0xFFF0F9FF);
    }
  }

  String _moodBadge(String mood) {
    switch (mood) {
      case 'celebrating':
      case 'happy':
        return '🎉';
      case 'excited':
        return '⭐';
      case 'sad':
        return '😢';
      case 'sleeping':
        return '😴';
      case 'wave':
        return '👋';
      case 'talking':
        return '💬';
      default:
        return '';
    }
  }
}

class _SparkDot extends StatelessWidget {
  final AnimationController ctrl;
  final double delay;
  const _SparkDot({required this.ctrl, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final v = ((ctrl.value + delay) % 1.0);
        return Opacity(
          opacity: v < 0.5 ? v * 2 : (1 - v) * 2,
          child: const Text('✨', style: TextStyle(fontSize: 14)),
        );
      },
    );
  }
}
