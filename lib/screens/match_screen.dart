// lib/screens/match_screen.dart

import 'package:flutter/material.dart';
import 'package:kiddylingo/widgets/share_widget.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/types.dart';
import '../widgets/buddy_widget.dart';

class MatchScreen extends StatelessWidget {
  final bool isChallenge;
  const MatchScreen({super.key, this.isChallenge = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final step = provider.currentStep;
    if (step?.item == null || step?.options == null) return const SizedBox.shrink();

    final item = step!.item!;
    final options = step.options!;
    final total = provider.lessonQueue.length;
    final current = provider.currentStepIndex + 1;

    final answered = provider.quizAnswered;
    final correct = provider.quizCorrect;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                // Progress row
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                        onPressed: () => provider.goHome(),
                      ),
                      Expanded(child: KiddyProgressBar(current: current, total: total)),
                      const SizedBox(width: 16),
                      _StatPill(emoji: '❤️', value: '${provider.hearts}', color: const Color(0xFFFF4B4B)),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          isChallenge ? '🏆 Final Challenge!' : '🍓 Drag & Match',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Drag fruit to basket 👇',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 16,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Draggable main item
                        Draggable<String>(
                          data: item.id,
                          feedback: Material(
                            color: Colors.transparent,
                            child: _DragItem(url: item.image, isDragging: true),
                          ),
                          childWhenDragging: _DragItem(url: item.image, isEmpty: true),
                          child: _DragItem(url: item.image, isEmpty: answered),
                        ),

                        const SizedBox(height: 48),

                        // Options / Baskets
                        Expanded(
                          child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.2,
                            children: options.map((opt) {
                              final isSelected = provider.selectedAnswer == opt.id;
                              final isCorrectAnswer = opt.id == item.id;
                              
                              return DragTarget<String>(
                                builder: (context, candidateData, rejectedData) {
                                  return _BasketTarget(
                                    label: opt.category == Category.alphabet ? opt.description : opt.name,
                                    isHovering: candidateData.isNotEmpty && !answered,
                                    isAnswered: answered,
                                    isSelected: isSelected,
                                    isCorrectAnswer: isCorrectAnswer,
                                  );
                                },
                                onWillAcceptWithDetails: (details) => !answered,
                                onAcceptWithDetails: (details) {
                                  if (!answered) {
                                    provider.selectAnswer(opt.id);
                                    provider.checkAnswer();
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            '✨ +5 XP Match',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF9600),
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

            const Positioned(
              bottom: 80,
              left: -20,
              child: BuddyWidget(size: 80),
            ),

            // Overlays for correct/wrong
            if (answered && correct == true)
              Positioned.fill(
                child: _SuccessOverlay(provider: provider, itemName: item.category == Category.alphabet ? item.description : item.name),
              ),
            if (answered && correct == false)
              Positioned.fill(
                child: _WrongOverlay(provider: provider, correctName: item.category == Category.alphabet ? item.description : item.name),
              ),
          ],
        ),
      ),
    );
  }
}

class _DragItem extends StatelessWidget {
  final String url;
  final bool isDragging;
  final bool isEmpty;

  const _DragItem({
    required this.url,
    this.isDragging = false,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Container(
        height: 140,
        width: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2, style: BorderStyle.none), // Wait, BorderStyle.none makes it invisible. Let's use dashed if we could, but solid is fine.
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.check, color: Color(0xFFCBD5E1), size: 48),
      );
    }

    return Container(
      height: isDragging ? 150 : 140,
      width: isDragging ? 150 : 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0x20000000),
            blurRadius: isDragging ? 24 : 12,
            offset: isDragging ? const Offset(0, 12) : const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: KiddyImage(url: url),
      ),
    );
  }
}

class _BasketTarget extends StatelessWidget {
  final String label;
  final bool isHovering;
  final bool isAnswered;
  final bool isSelected;
  final bool isCorrectAnswer;

  const _BasketTarget({
    required this.label,
    required this.isHovering,
    required this.isAnswered,
    required this.isSelected,
    required this.isCorrectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFFE2E8F0);
    Color bgColor = Colors.white;

    if (isAnswered) {
      if (isCorrectAnswer) {
        borderColor = const Color(0xFF58CC02);
        bgColor = const Color(0xFFDCFCE7);
      } else if (isSelected && !isCorrectAnswer) {
        borderColor = const Color(0xFFFF4B4B);
        bgColor = const Color(0xFFFFF0F0);
      }
    } else if (isHovering) {
      borderColor = const Color(0xFF1CB0F6);
      bgColor = const Color(0xFFE0F7FF);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.3),
            blurRadius: isHovering ? 12 : 0,
            offset: isHovering ? const Offset(0, 6) : Offset.zero,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧺', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isAnswered
                  ? (isCorrectAnswer
                      ? const Color(0xFF16A34A)
                      : isSelected
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF94A3B8))
                  : const Color(0xFF334155),
            ),
          ),
        ],
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
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
            ],
          ),
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
              
              Text(
                '🖼️ ➜ 🧺',
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 24),
              
              _RewardRow(icon: '⭐', text: '+10 XP', color: const Color(0xFFFF9600)),
              const SizedBox(height: 12),
              _RewardRow(icon: '🪙', text: '+5 Coins', color: const Color(0xFFFFC800)),
              const SizedBox(height: 12),
              _RewardRow(icon: '🔥', text: 'Combo x2', color: const Color(0xFFFF4B4B)),
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
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
            ],
          ),
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

  const _RewardRow({required this.icon, required this.text, required this.color});

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
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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