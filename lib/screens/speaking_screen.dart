// lib/screens/speaking_screen.dart

import 'package:flutter/material.dart';
import 'package:kiddylingo/widgets/share_widget.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/app_provider.dart';
import '../widgets/buddy_widget.dart';


class SpeakingScreen extends StatelessWidget {
  const SpeakingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final step = provider.currentStep;
    if (step?.item == null) return const SizedBox.shrink();

    final item = step!.item!;
    final total = provider.lessonQueue.length;
    final current = provider.currentStepIndex + 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    onPressed: () => provider.goHome(),
                  ),
                  Expanded(child: KiddyProgressBar(current: current, total: total)),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🎙️ Say it out loud!',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: KiddyImage(url: item.image),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '/${item.phonetic}/',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 18,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Listen button
                    GestureDetector(
                      onTap: () => provider.speak(item.name, high: true),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1CB0F6),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x441CB0F6),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tap to hear it',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: DuoButton(
                label: 'NEXT',
                color: const Color(0xFF58CC02),
                shadowColor: const Color(0xFF46A302),
                onTap: provider.advanceStep,
              ),
            ),
              ],
              ),
            ),
            const Positioned(
              bottom: 80,
              left: -20,
              child: BuddyWidget(size: 80),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Mini Reward Screen ----
class MiniRewardScreen extends StatefulWidget {
  const MiniRewardScreen({super.key});

  @override
  State<MiniRewardScreen> createState() => _MiniRewardScreenState();
}

class _MiniRewardScreenState extends State<MiniRewardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFFE),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: const Text('🎁', style: TextStyle(fontSize: 100)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Prize Time!',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF58CC02),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Great job! Keep going! 🌟',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 20,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Gift Screen ----
class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isBig = provider.isBigUnitReward;

    // Duolingo Premium celebration gradient vs Lesson complete sky blue
    final backgroundDecoration = isBig
        ? const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3B82F6), // Vibrant Indigo-Blue
                Color(0xFF8B5CF6), // Royal Purple
                Color(0xFFEC4899), // Pink splash
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          )
        : const BoxDecoration(
            color: Color(0xFF1CB0F6), // Standard sky blue
          );

    return Scaffold(
      body: Container(
        decoration: backgroundDecoration,
        child: SafeArea(
          child: Stack(
            children: [
              // Confetti Overlay for Unit Completion
              if (isBig && provider.giftOpened)
                const Positioned.fill(
                  child: ConfettiWidget(),
                ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Text
                      Text(
                        isBig ? '🏆 Unit Complete!' : '🌟 Lesson Complete!',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isBig
                            ? 'Amazing work! You earned a special unit gift!'
                            : 'Fantastic job! Keep up the great work!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Interactive Gift Box / Reward Display
                      if (!provider.giftOpened)
                        GestureDetector(
                          onTap: provider.openGift,
                          child: AnimatedBuilder(
                            animation: _ctrl,
                            builder: (_, __) => Transform.translate(
                              offset: Offset(0, _bounceAnim.value),
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 30,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '🎁',
                                  style: TextStyle(fontSize: 85),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Cute popping scaling animation for revealed reward
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.elasticOut,
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      provider.earnedGift,
                                      style: const TextStyle(fontSize: 100),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '+${provider.earnedGemAmount} 💎',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 50),

                      // Bottom prompt/button
                      if (!provider.giftOpened)
                        const Text(
                          'TAP TO OPEN',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: DuoButton(
                              label: isBig ? 'COMPLETE UNIT! 🎉' : 'KEEP GOING! 🚀',
                              color: Colors.white,
                              shadowColor: const Color(0xFFE5E5E5),
                              textColor: isBig ? const Color(0xFF8B5CF6) : const Color(0xFF1CB0F6),
                              onTap: provider.finishGift,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Confetti Particle Effect ----
class ConfettiParticle {
  final Color color;
  final double speed;
  final double size;
  final double sway;
  double x;
  double y;

  ConfettiParticle({
    required this.color,
    required this.speed,
    required this.size,
    required this.sway,
    required this.x,
    required this.y,
  });
}

class ConfettiWidget extends StatefulWidget {
  const ConfettiWidget({super.key});

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<ConfettiParticle> _particles = [];
  final List<Color> _colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.pink,
    Colors.purple,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    final random = Random();
    for (int i = 0; i < 60; i++) {
      _particles.add(
        ConfettiParticle(
          color: _colors[random.nextInt(_colors.length)],
          speed: 1.5 + random.nextDouble() * 3.5,
          size: 8.0 + random.nextDouble() * 8.0,
          sway: 0.5 + random.nextDouble() * 1.5,
          x: random.nextDouble() * 400.0,
          y: -random.nextDouble() * 300.0,
        ),
      );
    }

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _ctrl.addListener(() {
      final random = Random();
      final width = MediaQuery.of(context).size.width;
      for (final p in _particles) {
        p.y += p.speed;
        p.x += sin(p.y / 25) * p.sway;
        if (p.y > MediaQuery.of(context).size.height) {
          p.y = -20;
          p.x = random.nextDouble() * width;
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ConfettiPainter(_particles),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      paint.color = p.color;
      canvas.save();
      canvas.translate(p.x.clamp(0, size.width), p.y);
      canvas.rotate(p.y * 0.05);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}