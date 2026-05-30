import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kiddylingo/providers/app_provider.dart';
import 'package:kiddylingo/widgets/share_widget.dart';
import 'package:provider/provider.dart';

class BuddiesScreen extends StatelessWidget {
  const BuddiesScreen({super.key});

  final List<Map<String, String>> heroes = const [
    {
      'id': 'Fox',
      'asset':
          'https://lottie.host/10f1c6d6-ea41-46c5-86b0-d692a8163d66/6CcjZm6N8G.lottie',
      'name': 'Fox',
      'message': "Let's go on an adventure!"
    },
    {
      'id': 'Super Fox',
      'asset':
          'https://lottie.host/b3ea8052-84b6-414f-a0d9-786e0b1cbed9/WrfD8xixH1.lottie',
      'name': 'Super Fox',
      'message': "I'm ready to learn!"
    },
  ];

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
                  children: [
                    const Text(
                      'CHOOSE YOUR BUDDY',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF334155),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: heroes.length,
                      itemBuilder: (_, idx) {
                        final hero = heroes[idx];
                        final isSelected =
                            provider.selectedBuddy == hero['asset'];
                        return GestureDetector(
                          onTap: () {
                            provider.selectBuddy(hero['asset']!);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF0FCE8)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF58CC02)
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 3 : 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 70,
                                  width: 70,
                                  child: DotLottieView(
                                    key: ValueKey(hero['asset']),
                                    sourceType: 'url',
                                    source: hero['asset']!,
                                    autoplay: true,
                                    loop: true,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hero['name']!.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? const Color(0xFF58CC02)
                                        : const Color(0xFF94A3B8),
                                    letterSpacing: 0.5,
                                  ),
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
