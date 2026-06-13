// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/share_widget.dart';
import '../widgets/buddy_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: const Color(0xFF1CB0F6), // Bright blue background like Duolingo
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),

                // Center Content: Mascot, Logo, and Subtitle
                Column(
                  children: [
                    // The Buddy Mascot
                    const BuddyWidget(size: 200),
                    const SizedBox(height: 40),

                    // Logo + Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'kiddylingo',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ABC',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1CB0F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      'Learn English for free.\nForever.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),

                // Bottom Content: Indicators and Buttons
                Column(
                  children: [
                    // Carousel Indicators (Static for now, just for visuals)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        bool isActive = index == 3;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 10 : 8,
                          height: isActive ? 10 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Primary Button
                    DuoButton(
                      label: "GET STARTED",
                      color: Colors.white,
                      textColor: const Color(0xFF1CB0F6),
                      shadowColor: const Color(0xFFE5E5E5),
                      onTap: () => context.read<AppProvider>().startApp(),
                    ),
                    const SizedBox(height: 16),
                  
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
