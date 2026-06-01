// lib/screens/learn_screen.dart

import 'package:flutter/material.dart';
import 'package:kiddylingo/data/data.dart';
import 'package:kiddylingo/widgets/share_widget.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/types.dart';
import '../../widgets/buddy_widget.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final step = provider.currentStep;
    if (step?.item == null) return const SizedBox.shrink();

    final item = step!.item!;
    final type = step.type;
    final catMeta = categoryMetadata[item.category]!;
    final catColor = Color(catMeta.color);
    final catDark = Color(catMeta.darkColor);

    final total = provider.lessonQueue.length;
    final current = provider.currentStepIndex + 1;

    final isLetterStep =
        type == StepType.learnUpper || type == StepType.learnLower;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 24, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close,
                              size: 28, color: Color(0xFFAFAFAF)),
                          onPressed: () => provider.goHome(),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child:
                              KiddyProgressBar(current: current, total: total),
                        ),
                        const SizedBox(width: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite,
                                color: Color(0xFFFF4B4B), size: 26),
                            const SizedBox(width: 6),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: Text(
                                '${provider.hearts}',
                                key: ValueKey<int>(provider.hearts),
                                style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFF4B4B)),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 36),
                          Text(
                            _getInstruction(type).toUpperCase(),
                            style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4B4B4B),
                                letterSpacing: 0.2),
                          ),
                          const SizedBox(height: 32),
                          ScaleTransition(
                            scale: _pulseAnim,
                            child: _LearnCard(
                                item: item, type: type, catColor: catColor),
                          ),
                          const SizedBox(height: 48),
                          if (isLetterStep)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => provider.speak(_getPhrase(step),
                                      slow: true, high: true),
                                  child: Container(
                                    width: 86,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00C2FF),
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Color(0xFF00A2D6),
                                            offset: Offset(0, 5))
                                      ],
                                    ),
                                    child: const Icon(Icons.volume_up_rounded,
                                        color: Colors.white, size: 42),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Text(
                                  type == StepType.learnLower
                                      ? item.name.toLowerCase()
                                      : item.name.toUpperCase(),
                                  style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 54,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF4B4B4B)),
                                ),
                              ],
                            )
                          else if (type == StepType.learn ||
                              type == StepType.learnWord)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 188, 232, 254),
                                    borderRadius: BorderRadius.circular(14),
                                    border: const Border(
                                      bottom: BorderSide(
                                          color: Color(0xFFE5E5E5), width: 4),
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.volume_up_rounded,
                                        color: Color.fromARGB(255, 5, 167, 241),
                                        size: 28),
                                    onPressed: () {
                                      provider.speak(_getPhrase(step),
                                          fast: true);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: catColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: catColor.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    '/${item.phonetic}/',
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  // 3. Updated navigation action layout
                  Padding(
                    // Added horizontal padding to pull the button away from the screen edges
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            // Ensure the button width is controlled by the parent padding
                            height: 54,
                            child: DuoButton(
                              label: 'NEXT',
                              color: const Color(0xFF58CC02),
                              shadowColor: const Color(0xFF46A302),
                              onTap: provider.advanceStep,
                            ),
                          ),
                        ),
                      ],
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

  String _getInstruction(StepType type) {
    switch (type) {
      case StepType.learnUpper:
        return 'BIG LETTER';
      case StepType.learnLower:
        return 'SMALL LETTER';
      case StepType.learnWord:
        return 'Learn the Word';
      default:
        return 'Let\'s Learn!';
    }
  }

  String _getPhrase(LessonStep step) {
    final item = step.item!;
    switch (step.type) {
      case StepType.learnUpper:
      case StepType.learnLower:
        return item.name
            .replaceAll(RegExp(r'(Capital|Small)\s+', caseSensitive: false), '')
            .trim()
            .toLowerCase();
      case StepType.learnWord:
        if (item.category == Category.alphabet) {
          return '${item.name}... for... ${item.description}';
        }
        return 'This is a... ${item.name}';
      case StepType.learn:
        return '${item.name}. ${item.description}';
      default:
        return item.name;
    }
  }
}

class _LearnCard extends StatelessWidget {
  final LearningItem item;
  final StepType type;
  final Color catColor;

  const _LearnCard(
      {required this.item, required this.type, required this.catColor});

  @override
  Widget build(BuildContext context) {
    if (type == StepType.learnUpper || type == StepType.learnLower) {
      return Container(
        width: double.infinity,
        height: 280,
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          // FIX: Explicitly set width to avoid hairline assertion error
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2.5),
        ),
        alignment: Alignment.center,
        child: Text(
          type == StepType.learnLower
              ? item.name.toLowerCase()
              : item.name.toUpperCase(),
          style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 155,
              fontWeight: FontWeight.w900,
              color: Color(0xFF00C2FF),
              height: 1.0),
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: KiddyImage(
              url: item.image,
              width: double.infinity,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          if (type == StepType.learnWord && item.category == Category.alphabet)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: catColor,
                  ),
                ),
                const Text(
                  ' is for ',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          Text(
            (type == StepType.learnWord && item.category == Category.alphabet)
                ? item.description
                : item.name,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
