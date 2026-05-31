// lib/screens/letters_screen.dart

import 'package:flutter/material.dart';
import 'package:kiddylingo/data/data.dart';
import 'package:kiddylingo/widgets/share_widget.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

import '../models/types.dart';

class LettersScreen extends StatelessWidget {
  const LettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final alphabetItems =
        learningData.where((i) => i.category == Category.alphabet).toList();
    final colors = [
      const Color(0xFFF9A8D4),
      const Color(0xFF86EFAC),
      const Color(0xFF93C5FD),
      const Color(0xFFD8B4FE),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const KiddyTopBar(showStats: false),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFE2E8F0), width: 2),
                      ),
                      child: Row(
                        children: [
                          const Text('🦊', style: TextStyle(fontSize: 40)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Tap any card to hear the sound!',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Alphabet grid
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: alphabetItems.length,
                      itemBuilder: (_, idx) {
                        final item = alphabetItems[idx];
                        final color = colors[idx % colors.length];
                        return GestureDetector(
                          onTap: () => provider.speak(
                            '${item.name}... is for... ${item.description}',
                            fast: true,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0), width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x08000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: KiddyImage(
                                      url: item.image, width: 36, height: 36),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 10,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const KiddyBottomNav(),
          ],
        ),
      ),
    );
  }
}

// ---- Quests Screen ----
class QuestsScreen extends StatelessWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const KiddyTopBar(showStats: false),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1CB0F6), Color(0xFF1899D6)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x441CB0F6),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daily Quests',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'Earn gems for prizes!',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text('🏆', style: TextStyle(fontSize: 52)),
                        ],
                      ),
                    ),

                    // Quest cards
                    _QuestCard(
                      title: 'Getting Started',
                      desc: 'Get 10 correct answers in total',
                      progress: provider.totalRightAnswers.clamp(0, 10),
                      total: 10,
                      reward: '💎 50',
                    ),
                    const SizedBox(height: 12),
                    _QuestCard(
                      title: 'Learning Pro',
                      desc: 'Get 50 correct answers in total',
                      progress: provider.totalRightAnswers.clamp(0, 50),
                      total: 50,
                      reward: '🌟 Badge',
                    ),
                    const SizedBox(height: 12),
                    _QuestCard(
                      title: 'Master Scholar',
                      desc: 'Get 100 correct answers in total',
                      progress: provider.totalRightAnswers.clamp(0, 100),
                      total: 100,
                      reward: '👑 Crown',
                    ),
                  ],
                ),
              ),
            ),
            const KiddyBottomNav(),
          ],
        ),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final String title;
  final String desc;
  final int progress;
  final int total;
  final String reward;

  const _QuestCard({
    required this.title,
    required this.desc,
    required this.progress,
    required this.total,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF334155),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                reward,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF58CC02),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          KiddyProgressBar(current: progress, total: total),
          const SizedBox(height: 4),
          Text(
            '$progress / $total',
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Buddies / Friends Screen ----
