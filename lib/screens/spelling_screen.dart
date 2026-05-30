import 'package:flutter/material.dart';
import 'package:kiddylingo/widgets/share_widget.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/buddy_widget.dart';

class SpellingScreen extends StatelessWidget {
  const SpellingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final step = provider.currentStep;
    if (step?.item == null) return const SizedBox.shrink();

    final item = step!.item!;
    final slots = provider.spellingSlots;
    final letters = provider.scrambledLetters;
    final complete = provider.spellingComplete;
    final total = provider.lessonQueue.length;
    final current = provider.currentStepIndex + 1;
    final isReady = !slots.contains(null);
    final isCorrect = provider.quizCorrect;

    return Scaffold(
      backgroundColor: Colors.white, // Match the screenshot's white background
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFFAFAFAF)),
                        onPressed: () => provider.goHome(),
                      ),
                      Expanded(
                        child: KiddyProgressBar(current: current, total: total),
                      ),
                      const SizedBox(width: 16),
                      _StatPill(
                          emoji: '❤️',
                          value: '${provider.hearts}',
                          color: const Color(0xFFFF4B4B)),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        const Text(
                          'SPELL THE WORD!',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFAFAFAF),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Image Box
                        Container(
                          height: 140,
                          width: 140,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: KiddyImage(url: item.image),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Spelling slots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: slots.map((char) {
                            return GestureDetector(
                              onTap: char != null
                                  ? provider.removeLastSpellingSlot
                                  : null,
                              child: _SpellingSlot(char: char),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 48),

                        // Scrambled letters (Floating with blue bottom line)
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: letters.map((l) {
                            return GestureDetector(
                              onTap: l.used || complete
                                  ? null
                                  : () => provider.onSpellingLetterTap(l.id),
                              child: Opacity(
                                opacity: l.used ? 0.0 : 1.0,
                                child: _FloatingLetter(char: l.char),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom action bar
                if (complete)
                  Container(
                    color: const Color(0xFFD7FFB8),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Row(
                          children: [
                            Text(
                              '✓',
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Color(0xFF58A700),
                                  fontWeight: FontWeight.w900),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Well spelled!',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF58A700),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DuoButton(
                          label: 'CONTINUE',
                          color: const Color(0xFF58CC02),
                          shadowColor: const Color(0xFF46A302),
                          onTap: provider.advanceStep,
                        ),
                      ],
                    ),
                  )
                else if (isCorrect == false)
                  Container(
                    color: const Color(0xFFFFE5E5),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              '✕',
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Color(0xFFFF4B4B),
                                  fontWeight: FontWeight.w900),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Try again!',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFF4B4B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                    child: DuoButton(
                      label: 'CHECK',
                      color: isReady
                          ? const Color(0xFF58CC02)
                          : const Color(0xFFE5E7EB),
                      shadowColor: isReady
                          ? const Color(0xFF46A302)
                          : const Color(0xFFD1D5DB),
                      textColor:
                          isReady ? Colors.white : const Color(0xFFAFAFAF),
                      onTap: isReady ? provider.checkSpelling : () {},
                    ),
                  ),
              ],
              ),
            ),
            const Positioned(
              bottom: 120, // A bit higher to avoid overlapping with bottom bar
              left: -20,
              child: BuddyWidget(size: 80),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpellingSlot extends StatelessWidget {
  final String? char;

  const _SpellingSlot({required this.char});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Empty light grey slot
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: char != null
          ? Text(
              char!,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1CB0F6),
              ),
            )
          : null,
    );
  }
}

class _FloatingLetter extends StatelessWidget {
  final String char;

  const _FloatingLetter({required this.char});

  @override
  Widget build(BuildContext context) {
    // This creates the illusion of a floating letter with a blue curved underline
    // by using a blue background and a white foreground that covers the top part.
    return Container(
      width: 48,
      height: 48, // Reduced height for the floating style
      decoration: BoxDecoration(
        color: const Color(0xFF1CB0F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                char,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1CB0F6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 3), // Blue bottom curve peeks out
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
