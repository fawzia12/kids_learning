// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiddylingo/common/buddy_screen.dart';
import 'package:kiddylingo/screens/home_screen/home_screen.dart';
import 'package:kiddylingo/screens/letter_screen.dart';
import 'package:kiddylingo/screens/spelling_screen.dart';
import 'package:kiddylingo/screens/speaking_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiddylingo/screens/learn_screen/learn_screen.dart';

import 'providers/app_provider.dart';
import 'models/types.dart';
import 'screens/match_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firestore/providers/firestore_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const KiddyLingoApp());
}

class KiddyLingoApp extends StatelessWidget {
  const KiddyLingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirestoreProvider()..loadItems()),
        ChangeNotifierProxyProvider<FirestoreProvider, AppProvider>(
          create: (_) => AppProvider(),
          update: (_, firestore, app) => app!..updateFirestore(firestore),
        ),
      ],
      child: MaterialApp(
        title: 'KiddyLingo Adventure',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF58CC02),
          ),
          textTheme: GoogleFonts.fredokaTextTheme(),
          fontFamily: GoogleFonts.fredoka().fontFamily,
        ),
        home: const _AppRouter(),
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    final view = context.select<AppProvider, AppView>((p) => p.currentView);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: AbsorbPointer(
        absorbing: false,
        child: _buildView(view),
      ),
    );
  }

  Widget _buildView(AppView view) {
    switch (view) {
      // case AppView.splash:
      //   return const SplashScreen(key: ValueKey('splash'));
      case AppView.home:
        return const HomeScreen(key: ValueKey('home'));
      case AppView.letters:
        return const LettersScreen(key: ValueKey('letters'));
      case AppView.quests:
        return const QuestsScreen(key: ValueKey('quests'));
      case AppView.friends:
        return const BuddiesScreen(key: ValueKey('buddies'));
      case AppView.learn:
        return const LearnScreen(key: ValueKey('learn'));
      case AppView.match:
        return const MatchScreen(key: ValueKey('match'));
      case AppView.challenge:
        return const MatchScreen(key: ValueKey('challenge'), isChallenge: true);
      case AppView.speaking:
        return const SpeakingScreen(key: ValueKey('speak'));
      case AppView.spelling:
        return const SpellingScreen(key: ValueKey('spell'));
      case AppView.miniReward:
        return const MiniRewardScreen(key: ValueKey('reward'));
      case AppView.gift:
        return const GiftScreen(key: ValueKey('gift'));
      default:
        return const HomeScreen(key: ValueKey('home_fallback'));
    }
  }
}
