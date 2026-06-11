// lib/screens/learn_screen/story_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/share_widget.dart';

// ─── Story data model ────────────────────────────────────────────────────────
class StoryData {
  final String title;
  final String author;
  final String emoji;
  final Color bgTop;
  final Color bgBottom;
  final List<String> pages;

  const StoryData({
    required this.title,
    required this.author,
    required this.emoji,
    required this.bgTop,
    required this.bgBottom,
    required this.pages,
  });
}

// ─── Hard-coded story catalogue (one per category) ───────────────────────────
const _stories = [
  StoryData(
    title: 'Daisy the Dancing Dolphin',
    author: 'KiddyLingo',
    emoji: '🐬',
    bgTop: Color(0xFF6BCBF5),
    bgBottom: Color(0xFF1E7FC2),
    pages: [
      'Daisy was a playful dolphin who loved to dance in the ocean. Every morning she would leap and splash while the other fish watched in awe.',
      'Noticing Tilly, Daisy came over and smiled her big dolphin smile. She swam in circles to show Tilly how to move with the waves.',
      '"Just flow with the water," Daisy said softly. And together they danced until the stars came out and lit up the whole ocean.',
    ],
  ),
  StoryData(
    title: 'Leo the Brave Lion',
    author: 'KiddyLingo',
    emoji: '🦁',
    bgTop: Color(0xFFFFD580),
    bgBottom: Color(0xFFE07B39),
    pages: [
      'Leo the lion cub was afraid of the dark jungle at night. All the other animals seemed so brave, but Leo trembled at every sound.',
      'One evening a tiny firefly landed on Leo\'s nose. "Even the smallest light makes a difference!" the firefly said with a wink.',
      'Leo took a deep breath and stepped into the dark. His golden fur started to glow! Bravery, it turned out, was inside him all along.',
    ],
  ),
  StoryData(
    title: 'Coral the Clever Crab',
    author: 'KiddyLingo',
    emoji: '🦀',
    bgTop: Color(0xFF93D9FF),
    bgBottom: Color(0xFF2563EB),
    pages: [
      'Coral the crab lived beneath a big rock where the water was clear and cool. She loved solving puzzles left by the tide.',
      'One day she found a shiny pearl trapped under heavy stones. Her claws were too small to lift them — but her brain was not!',
      'She built a ramp from shells and rolled the stones away. The pearl was hers, and every creature cheered. Being clever is the best superpower!',
    ],
  ),
  StoryData(
    title: 'Mango and the Rainbow Tree',
    author: 'KiddyLingo',
    emoji: '🥭',
    bgTop: Color(0xFFFFCF80),
    bgBottom: Color(0xFF9333EA),
    pages: [
      'Deep in the fruit forest stood a tree that changed colour every season. Mango the little fruit loved climbing its rainbow-coloured bark.',
      'One autumn the tree turned grey and lost all its leaves. Mango gathered friends — Apple, Berry, and Plum — and they sang to the tree.',
      'Slowly the colours returned, brighter than before! Kindness and friendship, the tree whispered, are the best kind of sunshine.',
    ],
  ),
];

// ─── Main StoryScreen ─────────────────────────────────────────────────────────
class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with TickerProviderStateMixin {
  // Story selection
  late StoryData _story;
  int _page = 0;

  // Playback simulation progress
  double _progress = 0.0;

  // Animation controllers
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Pick story based on current category
    final provider = context.read<AppProvider>();
    final cat = provider.currentSessionCategory;
    final idx = cat == null ? 0 : _categoryIndex(cat.index);
    _story = _stories[idx.clamp(0, _stories.length - 1)];

    // Bounce animation for emoji illustration
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    // Page-change fade
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    // Play-button pulse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  int _categoryIndex(int raw) {
    // categoryOrder indices: 0=alphabet,1=animals,2=seaAnimals,3=fruits
    // Map to story indices
    return raw.clamp(0, _stories.length - 1);
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Playback control ───────────────────────────────────────────────────────
  void _togglePlay() {
    final provider = context.read<AppProvider>();
    final words = _story.pages[_page].split(RegExp(r'\s+'));
    final isCurrentlyPlaying = provider.currentSpokenText.isNotEmpty &&
        provider.currentWordIndex != -1;

    if (isCurrentlyPlaying) {
      // Pause — save progress position
      final idx = provider.currentWordIndex;
      if (idx >= 0 && words.isNotEmpty) {
        _progress = ((idx + 1) / words.length).clamp(0.0, 1.0);
      }
      provider.stopSpeech();
    } else {
      // Play — start from current progress
      if (_progress >= 0.99) _progress = 0.0;
      final startIdx =
          ((_progress * words.length)).round().clamp(0, words.length - 1);
      final textToSpeak = words.sublist(startIdx).join(' ');
      provider.speakStory(textToSpeak, wordOffset: startIdx);
    }
  }

  void _seekTo(double value) {
    final provider = context.read<AppProvider>();
    provider.stopSpeech();
    final words = _story.pages[_page].split(RegExp(r'\s+'));
    final targetIdx =
        ((value * words.length)).round().clamp(0, words.length - 1);
    setState(() {
      _progress = value;
    });
    final textToSpeak = words.sublist(targetIdx).join(' ');
    provider.speakStory(textToSpeak, wordOffset: targetIdx);
  }

  // ── Page navigation ────────────────────────────────────────────────────────
  Future<void> _nextPage() async {
    context.read<AppProvider>().stopSpeech();

    await _fadeCtrl.reverse();
    setState(() {
      _page = (_page + 1).clamp(0, _story.pages.length - 1);
      _progress = 0.0;
    });
    _fadeCtrl.forward();
  }

  bool get _isLastPage => _page >= _story.pages.length - 1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final total = provider.lessonQueue.length;
    final current = provider.currentStepIndex + 1;
    final size = MediaQuery.of(context).size;

    final words = _story.pages[_page].split(RegExp(r'\s+'));
    final isPlaying =
        provider.currentSpokenText.isNotEmpty && provider.currentWordIndex >= 0;

    double currentProgress = _progress;
    if (isPlaying && provider.currentWordIndex >= 0 && words.isNotEmpty) {
      currentProgress =
          ((provider.currentWordIndex + 1) / words.length).clamp(0.0, 1.0);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_story.bgTop, _story.bgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────────────
              _TopBar(
                current: current,
                total: total,
                onClose: provider.goHome,
              ),

              // ── Scrollable content ───────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Story title card
                      _TitleCard(story: _story),

                      const SizedBox(height: 20),

                      // Bouncing illustration
                      AnimatedBuilder(
                        animation: _bounceCtrl,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _bounceAnim.value),
                          child: _IllustrationBubble(
                            emoji: _story.emoji,
                            size: size.width * 0.48,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Story text card with page indicator
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: _StoryTextCard(
                          text: _story.pages[_page],
                          page: _page,
                          total: _story.pages.length,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Audio player bar
                      _AudioPlayerBar(
                        isPlaying: isPlaying,
                        progress: currentProgress,
                        pulseAnim: _pulseAnim,
                        onToggle: _togglePlay,
                        onSeek: _seekTo,
                      ),

                      const SizedBox(height: 24),

                      // Page nav row + NEXT / FINISH button
                      _BottomActions(
                        page: _page,
                        totalPages: _story.pages.length,
                        isLastPage: _isLastPage,
                        onPrev: _page > 0
                            ? () async {
                                context.read<AppProvider>().stopSpeech();
                                await _fadeCtrl.reverse();
                                setState(() {
                                  _page--;
                                  _progress = 0;
                                });
                                _fadeCtrl.forward();
                              }
                            : null,
                        onNext: _isLastPage ? provider.advanceStep : _nextPage,
                      ),

                      const SizedBox(height: 28),
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

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback onClose;

  const _TopBar({
    required this.current,
    required this.total,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 26),
            onPressed: onClose,
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total > 0 ? current / total : 0,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Story label pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_stories_rounded, color: Colors.white, size: 15),
                SizedBox(width: 5),
                Text(
                  'Story',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleCard extends StatelessWidget {
  final StoryData story;

  const _TitleCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            story.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'by ${story.author}',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 14,
              color: Colors.white.withOpacity(0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationBubble extends StatelessWidget {
  final String emoji;
  final double size;

  const _IllustrationBubble({required this.emoji, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.22),
        border: Border.all(color: Colors.white38, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: TextStyle(fontSize: size * 0.52),
      ),
    );
  }
}

class _StoryTextCard extends StatelessWidget {
  final String text;
  final int page;
  final int total;

  const _StoryTextCard({
    required this.text,
    required this.page,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final words = text.split(RegExp(r'\s+'));

    // Determine which word is highlighted — only if TTS is reading this page
    int highlightedIndex = -1;
    if (provider.currentSpokenText.isNotEmpty &&
        provider.currentWordIndex >= 0) {
      highlightedIndex = provider.currentWordIndex;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page indicator dots
          Row(
            children: List.generate(
              total,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: i == page ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: i == page
                      ? const Color(0xFF1CB0F6)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Karaoke word-by-word highlighting ──
          // Each word is an AnimatedContainer so the highlight
          // glides smoothly (250 ms transition) instead of jumping.
          Wrap(
            spacing: 0,
            runSpacing: 6,
            children: words.asMap().entries.map((entry) {
              final i = entry.key;
              final word = entry.value;
              final isCurrent = i == highlightedIndex;
              final isDone = highlightedIndex >= 0 && i < highlightedIndex;

              return Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: isCurrent
                      ? const EdgeInsets.symmetric(horizontal: 6, vertical: 3)
                      : const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFFFFF176) // bright yellow highlight
                        : isDone
                            ? const Color(
                                0xFFE8F5FF) // faint blue = already read
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: isCurrent
                        ? Border.all(color: const Color(0xFFFFC107), width: 1.5)
                        : Border.all(color: Colors.transparent, width: 1.5),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFC107)
                                  .withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isCurrent ? 18.5 : 17.0,
                      height: 1.6,
                      fontWeight: isCurrent
                          ? FontWeight.w900
                          : isDone
                              ? FontWeight.w600
                              : FontWeight.w500,
                      color: isCurrent
                          ? const Color(0xFF7B4F00) // dark amber on yellow
                          : isDone
                              ? const Color(0xFF5BA8D4) // soft blue = read
                              : const Color(0xFF334155), // default
                    ),
                    child: Text(word),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AudioPlayerBar extends StatelessWidget {
  final bool isPlaying;
  final double progress;
  final Animation<double> pulseAnim;
  final VoidCallback onToggle;
  final ValueChanged<double> onSeek;

  const _AudioPlayerBar({
    required this.isPlaying,
    required this.progress,
    required this.pulseAnim,
    required this.onToggle,
    required this.onSeek,
  });

  String _fmt(double v) {
    final total = 120; // simulate 2-min story
    final sec = (v * total).round();
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Play/Pause button
          ScaleTransition(
            scale: isPlaying ? pulseAnim : const AlwaysStoppedAnimation(1.0),
            child: GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1CB0F6), Color(0xFF0E8EC4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1CB0F6).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Progress + times
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: const Color(0xFF1CB0F6),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    thumbColor: Colors.white,
                    overlayColor: const Color(0x221CB0F6),
                  ),
                  child: Slider(
                    value: progress,
                    onChanged: onSeek,
                    min: 0,
                    max: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fmt(progress),
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _fmt(1.0),
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final int page;
  final int totalPages;
  final bool isLastPage;
  final VoidCallback? onPrev;
  final VoidCallback onNext;

  const _BottomActions({
    required this.page,
    required this.totalPages,
    required this.isLastPage,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Prev page button
        if (page > 0)
          GestureDetector(
            onTap: onPrev,
            child: Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white38, width: 2),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 24),
            ),
          ),

        // Next page / Finish button
        Expanded(
          child: SizedBox(
            height: 54,
            child: DuoButton(
              label: isLastPage ? 'FINISH STORY 🎉' : 'NEXT PAGE →',
              color: isLastPage ? const Color(0xFF58CC02) : Colors.white,
              shadowColor: isLastPage
                  ? const Color(0xFF46A302)
                  : const Color(0xFFCBD5E1),
              textColor: isLastPage ? Colors.white : const Color(0xFF334155),
              onTap: onNext,
            ),
          ),
        ),
      ],
    );
  }
}
