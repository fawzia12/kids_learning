// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/share_widget.dart'; // Ensure this matches your file name

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _bounceAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -16)
        .animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF58CC02), Color(0xFF46A302)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Column(
              // This is the key change:
              // It pushes children to the top and bottom edges.
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Content: Mascot and Title
                Column(
                  children: [
                    const SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _bounceCtrl,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _bounceAnim.value),
                        child:
                            const Text('🦊', style: TextStyle(fontSize: 100)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, __) => Transform.scale(
                        scale: _pulseAnim.value,
                        child: Column(
                          children: [
                            const Text(
                              'KiddyLingo',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Adventure',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 22,
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Content: The Green Button
                DuoButton(
                  label: "GET STARTED",
                  color:
                      const Color(0xFFFFFFFF), // White button stands out more
                  textColor: const Color(0xFF58CC02), // Green text
                  shadowColor: const Color(0xFFE5E5E5), // Gray shadow
                  onTap: () => context.read<AppProvider>().startApp(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
