// lib/screens/match_screen.dart

import 'package:flutter/material.dart';
import 'package:kiddylingo/widgets/share_widget.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/types.dart';
import '../widgets/buddy_widget.dart';

class MatchScreen extends StatefulWidget {
  final bool isChallenge;
  const MatchScreen({super.key, this.isChallenge = false});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  String? _lastSpokenItemId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final step = provider.currentStep;
    if (step?.item == null || step?.options == null)
      return const SizedBox.shrink();

    final item = step!.item!;
    final options = step.options!;
    final total = provider.lessonQueue.length;
    final current = provider.currentStepIndex + 1;

    final answered = provider.quizAnswered;
    final correct = provider.quizCorrect;

    if (item.id != _lastSpokenItemId) {
      _lastSpokenItemId = item.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<AppProvider>().speak(item.category == Category.alphabet
              ? item.description
              : item.name);
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Progress row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                        onPressed: () => provider.goHome(),
                      ),
                      Expanded(
                          child:
                              KiddyProgressBar(current: current, total: total)),
                      const SizedBox(width: 16),
                      _StatPill(
                          emoji: '❤️',
                          value: '${provider.hearts}',
                          color: const Color(0xFFFF4B4B)),
                    ],
                  ),
                ),

                // Question Area
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.category == Category.alphabet
                              ? item.description
                              : item.name,
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => provider.speak(
                            item.category == Category.alphabet
                                ? item.description
                                : item.name),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1CB0F6),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0xFF1899D6),
                                  offset: Offset(0, 4)),
                            ],
                          ),
                          child: const Icon(Icons.volume_up_rounded,
                              color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                ),

                // Options Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                        children: options.map((opt) {
                          final isSelected = provider.selectedAnswer == opt.id;
                          final isCorrectAnswer = opt.id == item.id;

                          return _TapOption(
                            url: opt.image,
                            label: opt.category == Category.alphabet
                                ? opt.description
                                : opt.name,
                            isSelected: isSelected,
                            isAnswered: answered,
                            isCorrectAnswer: isCorrectAnswer,
                            onTap: () {
                              if (!answered) {
                                provider.selectAnswer(opt.id);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // Fixed Bottom Area
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        top: BorderSide(color: Color(0xFFE2E8F0), width: 2)),
                  ),
                  child: DuoButton(
                    label: 'CHECK',
                    color: provider.selectedAnswer != null
                        ? const Color(0xFF58CC02)
                        : const Color(0xFFE5E5E5),
                    shadowColor: provider.selectedAnswer != null
                        ? const Color(0xFF46A302)
                        : const Color(0xFFAFAFAF),
                    textColor: provider.selectedAnswer != null
                        ? Colors.white
                        : const Color(0xFFAFAFAF),
                    onTap: (provider.selectedAnswer != null && !answered)
                        ? () {
                            provider.checkAnswer();
                          }
                        : null,
                  ),
                ),
              ],
            ),

            // Overlays for correct/wrong
            if (answered && correct == true)
              Positioned.fill(
                child: _SuccessOverlay(
                    provider: provider,
                    itemName: item.category == Category.alphabet
                        ? item.description
                        : item.name),
              ),
            if (answered && correct == false)
              Positioned.fill(
                child: _WrongOverlay(
                    provider: provider,
                    correctName: item.category == Category.alphabet
                        ? item.description
                        : item.name),
              ),
          ],
        ),
      ),
    );
  }
}

class _TapOption extends StatelessWidget {
  final String url;
  final String label;
  final bool isSelected;
  final bool isAnswered;
  final bool isCorrectAnswer;
  final VoidCallback onTap;

  const _TapOption({
    required this.url,
    required this.label,
    required this.isSelected,
    required this.isAnswered,
    required this.isCorrectAnswer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFFE2E8F0);
    Color bgColor = Colors.white;
    Color textColor = const Color(0xFF334155);

    if (isAnswered) {
      if (isCorrectAnswer) {
        borderColor = const Color(0xFF58CC02);
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
      } else if (isSelected && !isCorrectAnswer) {
        borderColor = const Color(0xFFFF4B4B);
        bgColor = const Color(0xFFFFF0F0);
        textColor = const Color(0xFFDC2626);
      } else {
        borderColor = const Color(0xFFE2E8F0);
        bgColor = Colors.white;
        textColor = const Color(0xFF94A3B8);
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF1CB0F6);
      bgColor = const Color(0xFFE0F7FF);
      textColor = const Color(0xFF1CB0F6);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            if (!isAnswered || isSelected || isCorrectAnswer)
              BoxShadow(
                color: borderColor,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: KiddyImage(url: url),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessOverlay extends StatelessWidget {
  final AppProvider provider;
  final String itemName;

  const _SuccessOverlay({required this.provider, required this.itemName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.9),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '✨ AWESOME ✨',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF58CC02),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '🖼️ ➜ 🧺',
                style: TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 24),
              const _RewardRow(
                  icon: '⭐', text: '+10 XP', color: Color(0xFFFF9600)),
              const SizedBox(height: 12),
              const _RewardRow(
                  icon: '🪙', text: '+5 Coins', color: Color(0xFFFFC800)),
              const SizedBox(height: 12),
              const _RewardRow(
                  icon: '🔥', text: 'Combo x2', color: Color(0xFFFF4B4B)),
              const SizedBox(height: 24),
              const Text(
                '🎉 Confetti Pop',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1CB0F6),
                ),
              ),
              const SizedBox(height: 32),
              DuoButton(
                label: 'CONTINUE',
                color: const Color(0xFF58CC02),
                shadowColor: const Color(0xFF46A302),
                onTap: provider.advanceStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WrongOverlay extends StatelessWidget {
  final AppProvider provider;
  final String correctName;

  const _WrongOverlay({required this.provider, required this.correctName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.9),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Oops! 💔',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF4B4B),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'The correct answer was:',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                correctName,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 32),
              DuoButton(
                label: 'GOT IT',
                color: const Color(0xFFFF4B4B),
                shadowColor: const Color(0xFFCC3B3B),
                onTap: provider.advanceStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final String icon;
  final String text;
  final Color color;

  const _RewardRow(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
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
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
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
