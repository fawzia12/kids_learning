import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:kiddylingo/providers/app_provider.dart';
import 'package:kiddylingo/widgets/share_widget.dart';
import 'package:provider/provider.dart';

class BuddiesScreen extends StatelessWidget {
  const BuddiesScreen({super.key});

  final List<Map<String, String>> heroes = const [
    {
      'id': 'Fox',
      'asset': 'assets/character.json',
      'name': 'Fox',
      'message': "Let's go on an adventure!"
    },
    {
      'id': 'Super Fox',
      'asset': 'assets/a.json',
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
                        final asset = hero['asset'] ?? '';
                        final isSelected =
                            provider.selectedBuddy == asset;
                        return GestureDetector(
                          onTap: () {
                            if (asset.isNotEmpty) {
                              provider.selectBuddy(asset);
                            }
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
                                  child: _BuddyThumbnail(asset: asset),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  (hero['name'] ?? '').toUpperCase(),
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

/// Stateful thumbnail so each card manages its own error state independently.
class _BuddyThumbnail extends StatefulWidget {
  final String asset;
  const _BuddyThumbnail({required this.asset});

  @override
  State<_BuddyThumbnail> createState() => _BuddyThumbnailState();
}

class _BuddyThumbnailState extends State<_BuddyThumbnail> {
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    if (_error || widget.asset.isEmpty) {
      return const Center(
        child: Text('🦊', style: TextStyle(fontSize: 40)),
      );
    }
    Widget lottieWidget;
    if (widget.asset.startsWith('http')) {
      lottieWidget = Lottie.network(
        widget.asset,
        key: ValueKey(widget.asset),
        decoder: LottieComposition.decodeZip,
        animate: true,
        repeat: true,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _error = true);
          });
          return const Center(
            child: Text('🦊', style: TextStyle(fontSize: 40)),
          );
        },
        frameBuilder: (ctx, child, composition) {
          if (composition == null) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF58CC02),
                ),
              ),
            );
          }
          return child;
        },
      );
    } else {
      lottieWidget = Lottie.asset(
        widget.asset,
        key: ValueKey(widget.asset),
        animate: true,
        repeat: true,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _error = true);
          });
          return const Center(
            child: Text('🦊', style: TextStyle(fontSize: 40)),
          );
        },
        frameBuilder: (ctx, child, composition) {
          if (composition == null) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF58CC02),
                ),
              ),
            );
          }
          return child;
        },
      );
    }
    return lottieWidget;
  }
}
