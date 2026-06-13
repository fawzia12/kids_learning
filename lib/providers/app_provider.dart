import "package:flutter_tts/flutter_tts.dart";
import "package:shared_preferences/shared_preferences.dart";
// lib/providers/app_provider.dart

import 'dart:math';
import 'package:flutter/material.dart';

import 'package:kiddylingo/data/data.dart';

import 'dart:convert';

import '../models/types.dart';
import '../firestore/providers/firestore_provider.dart';

class AppProvider extends ChangeNotifier {
  FirestoreProvider? _firestoreProvider;

  void updateFirestore(FirestoreProvider firestore) {
    _firestoreProvider = firestore;
    if (currentSessionCategory != null &&
        currentSessionStepIndex != null &&
        lessonQueue.isEmpty) {
      final items = firestore
          .getItemsByCategory(currentSessionCategory!, fallbackData: []);
      if (items.isNotEmpty) {
        startSession(currentSessionCategory!, currentSessionStepIndex!);
      }
    }
  }

  // --- TTS ---
  final FlutterTts _tts = FlutterTts();

  // --- Navigation ---
  AppView currentView = AppView.splash;
  int bottomNavIndex = 0;

  // --- Lesson State ---
  Category? currentSessionCategory;
  int? currentSessionStepIndex;
  List<LessonStep> lessonQueue = [];
  int currentStepIndex = 0;

  // Spelling state
  List<String?> spellingSlots = [];
  List<({String char, int id, bool used})> scrambledLetters = [];
  bool spellingComplete = false;
  bool spellingWordSpoken = false;

  // Match/Challenge state
  String? selectedAnswer;
  bool? quizCorrect;
  bool quizAnswered = false;

  // Gift state
  bool giftOpened = false;
  String earnedGift = '🧸';
  bool isBigUnitReward = false;
  int earnedGemAmount = 100;

  // --- Persistent State ---
  int gems = 150;
  int hearts = 5;
  int streak = 0;
  int totalRightAnswers = 0;
  UserProgress userProgress = const UserProgress();
  bool isProgressLoaded = false;

  // Character mood and buddy
  String characterMood = 'idle'; // idle, happy, celebrating, sad, talking
  String selectedBuddy = 'assets/character.json';

  void selectBuddy(String buddyPath) {
    selectedBuddy = buddyPath;
    characterMood = 'happy';
    _saveState();
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      if (characterMood == 'happy') {
        characterMood = 'idle';
        notifyListeners();
      }
    });
  }

  final List<String> _correctFeedbacks = [
    "Excellent!",
    "Yeah!",
    "Awesome!",
    "Great job!"
  ];

  final List<String> _wrongFeedbacks = ["oh no!", "oh no !", " oh no ! "];

  AppProvider() {
    _initTts();
    _loadPersistedState();
  }

  void _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.40); // Slow, clear rate for kids
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.4); // Soft kid-friendly tone globally
  }

  void speak(String text,
      {bool fast = false, bool high = false, bool slow = false}) async {
    await _tts.stop();
    // Base kid-friendly settings are already set, but we can subtly adjust based on flags
    double pitch = 1.4;
    double rate = 0.40;

    if (high) pitch = 1.5;
    if (fast) rate = 0.45;
    if (slow) rate = 0.35;

    await _tts.setPitch(pitch);
    await _tts.setSpeechRate(rate);
    await _tts.speak(text);
  }

  void speakCorrect() {
    characterMood = 'celebrating';
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      if (characterMood == 'celebrating') {
        characterMood = 'idle';
        notifyListeners();
      }
    });
    final phrase =
        _correctFeedbacks[Random().nextInt(_correctFeedbacks.length)];
    speak(phrase, high: true);
  }

  void speakWrong() {
    characterMood = 'sad';
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      if (characterMood == 'sad') {
        characterMood = 'idle';
        notifyListeners();
      }
    });
    final phrase = _wrongFeedbacks[Random().nextInt(_wrongFeedbacks.length)];
    speak(phrase, slow: true);
  }

  void stopSpeech() async {
    await _tts.stop();
    // Reset story karaoke tracking
    if (_storyWordIndex != -1 || _storySpokenText.isNotEmpty) {
      _storyWordIndex = -1;
      _storySpokenText = '';
      notifyListeners();
    }
  }

  // --- Story karaoke TTS state ---
  int _storyWordIndex = -1;
  String _storySpokenText = '';

  /// The 0-based index of the word currently being spoken (or -1).
  int get currentWordIndex => _storyWordIndex;

  /// The full text currently being spoken for karaoke tracking.
  String get currentSpokenText => _storySpokenText;

  /// Speaks [text] slowly with real-time word-level progress callbacks.
  /// [wordOffset] is added to the internal word index so highlight maps
  /// correctly when starting from a mid-page position.
  void speakStory(String text, {int wordOffset = 0}) async {
    await _tts.stop();
    await _tts.setPitch(1.2);
    await _tts.setSpeechRate(0.25);

    _storySpokenText = text;
    _storyWordIndex = wordOffset;
    notifyListeners();

    // Build character→word-index lookup from the spoken text
    final words = text.split(RegExp(r'\s+'));
    final starts = <int>[];
    int pos = 0;
    for (final w in words) {
      starts.add(pos);
      pos += w.length + 1; // +1 for the space
    }

    // TTS engine fires this for every word as it speaks
    _tts.setProgressHandler(
        (String t, int startOffset, int endOffset, String word) {
      int idx = 0;
      for (int i = 0; i < starts.length; i++) {
        if (starts[i] <= startOffset) idx = i;
      }
      _storyWordIndex = wordOffset + idx;
      notifyListeners();
    });

    _tts.setCompletionHandler(() {
      // Keep the last word highlighted briefly, then clear
      Future.delayed(const Duration(milliseconds: 600), () {
        _storyWordIndex = -1;
        _storySpokenText = '';
        notifyListeners();
      });
    });

    await _tts.speak(text);
  }

  // --- Persistence ---
  void _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    gems = prefs.getInt('k_gems') ?? 150;
    hearts = prefs.getInt('k_hearts') ?? 5;
    streak = prefs.getInt('k_streak') ?? 0;
    totalRightAnswers = prefs.getInt('k_right_answers') ?? 0;
    selectedBuddy = prefs.getString('k_buddy') ?? 'assets/character.json';
    final progressJson = prefs.getString('k_progress');
    if (progressJson != null) {
      userProgress = UserProgress.fromJson(jsonDecode(progressJson));
    }
    isProgressLoaded = true;
    notifyListeners();
    speak("Welcome back! Let's learn together!", high: true);
  }

  void _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('k_gems', gems);
    prefs.setInt('k_hearts', hearts);
    prefs.setInt('k_streak', streak);
    prefs.setInt('k_right_answers', totalRightAnswers);
    prefs.setString('k_buddy', selectedBuddy);
    prefs.setString('k_progress', jsonEncode(userProgress.toJson()));
  }

  // --- Navigation ---
  void navigateTo(AppView view) {
    stopSpeech();
    currentView = view;
    characterMood = 'idle';
    notifyListeners();
  }

  void setBottomNav(int index) {
    final views = [
      AppView.home,
      AppView.letters,
      AppView.quests,
      AppView.friends
    ];
    bottomNavIndex = index;
    navigateTo(views[index]);
  }

  void goHome() {
    stopSpeech();
    bottomNavIndex = 0;
    currentView = AppView.home;
    characterMood = 'idle';
    notifyListeners();
  }

  // --- Session Logic ---
  void startSession(Category category, int stepIndex) {
    stopSpeech();
    currentSessionCategory = category;
    currentSessionStepIndex = stepIndex;

    final unitSteps = getUnitSteps(category);
    final stepType = unitSteps[stepIndex].type;

    // learnUpper (Big Letters) and learnLower (Small Letters) always use
    // local data.dart — Firestore is only used for learn, learnWord, match,
    // and challenge steps.
    final bool useFirestore = stepType == StepType.learn ||
        stepType == StepType.learnWord ||
        stepType == StepType.match ||
        stepType == StepType.challenge;

    final allItems = useFirestore
        ? (_firestoreProvider?.getItemsByCategory(category, fallbackData: []) ??
            getItemsByCategory(category))
        : getItemsByCategory(category);
    final queue = <LessonStep>[];
    final rng = Random();

    switch (stepType) {
      case StepType.learn:
        for (final item in allItems) {
          queue.add(LessonStep(type: StepType.learn, item: item));
        }
        break;
      case StepType.learnUpper:
        for (final item in allItems) {
          queue.add(LessonStep(type: StepType.learnUpper, item: item));
        }
        break;
      case StepType.learnLower:
        for (final item in allItems) {
          queue.add(LessonStep(type: StepType.learnLower, item: item));
        }
        break;
      case StepType.learnWord:
        for (final item in allItems) {
          queue.add(LessonStep(type: StepType.learnWord, item: item));
        }
        break;
      case StepType.match:
        final matchItems = [...allItems]..shuffle(rng);
        final limited = matchItems.take(10).toList();
        for (final item in limited) {
          final distractors = allItems.where((i) => i.id != item.id).toList()
            ..shuffle(rng);
          final options = [item, ...distractors.take(3)]..shuffle(rng);
          queue.add(
              LessonStep(type: StepType.match, item: item, options: options));
        }
        break;

      case StepType.miniReward:
        queue.add(const LessonStep(type: StepType.miniReward));
        break;
      case StepType.spell:
        for (final item in allItems) {
          if (item.name.length <= 8 &&
              RegExp(r'^[a-zA-Z\s]+$').hasMatch(item.name)) {
            queue.add(LessonStep(type: StepType.spell, item: item));
          }
        }
        if (queue.isEmpty)
          queue.add(const LessonStep(type: StepType.miniReward));
        break;
      case StepType.challenge:
        final challengeItems = [...allItems]..shuffle(rng);
        final limited = challengeItems.take(10).toList();
        for (final item in limited) {
          final distractors = allItems.where((i) => i.id != item.id).toList()
            ..shuffle(rng);
          final options = [item, ...distractors.take(3)]..shuffle(rng);
          queue.add(LessonStep(
              type: StepType.challenge, item: item, options: options));
        }
        break;
      case StepType.story:
        queue.add(const LessonStep(type: StepType.story));
        break;
      default:
        break;
    }

    lessonQueue = queue;
    currentStepIndex = 0;
    quizAnswered = false;
    quizCorrect = null;
    selectedAnswer = null;
    spellingComplete = false;

    _updateViewFromStep(queue[0]);
  }

  void _updateViewFromStep(LessonStep step) {
    switch (step.type) {
      case StepType.learn:
      case StepType.learnUpper:
      case StepType.learnLower:
      case StepType.learnWord:
        currentView = AppView.learn;
        _speakCurrentStep(step);
        break;
      case StepType.match:
        currentView = AppView.match;
        quizAnswered = false;
        quizCorrect = null;
        selectedAnswer = null;
        break;
      case StepType.challenge:
        currentView = AppView.challenge;
        quizAnswered = false;
        quizCorrect = null;
        selectedAnswer = null;
        break;

      case StepType.spell:
        if (step.item != null) _initSpelling(step.item!);
        currentView = AppView.spelling;
        break;
      case StepType.story:
        currentView = AppView.story;
        speak('Story time! Let\'s read together!', high: true);
        break;
      case StepType.miniReward:
        currentView = AppView.miniReward;
        final words = ['Awesome!', 'You did it!', 'Super star!', 'Way to go!'];
        speak(words[Random().nextInt(words.length)], fast: true);
        Future.delayed(const Duration(seconds: 3), () {
          advanceStep();
        });
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void _speakCurrentStep(LessonStep step) {
    final item = step.item;
    if (item == null) return;

    Future.delayed(const Duration(milliseconds: 600), () {
      switch (step.type) {
        case StepType.learnUpper:
        case StepType.learnLower:
          final cleanLetter = item.name
              .replaceAll(
                  RegExp(r'(Capital|Small)\s+', caseSensitive: false), '')
              .trim()
              .toLowerCase();
          speak(cleanLetter, slow: true, high: true);
          break;
        case StepType.learnWord:
          if (item.category == Category.alphabet) {
            speak('${item.name}... for... ${item.description}', fast: true);
          } else {
            speak('This is a... ${item.name}', fast: true);
          }
          break;
        case StepType.learn:
          speak('${item.name}. ${item.description}', fast: true);
          break;

        default:
          speak(item.name, fast: true);
      }
    });
  }

  void advanceStep() {
    final nextIndex = currentStepIndex + 1;
    if (nextIndex < lessonQueue.length) {
      currentStepIndex = nextIndex;
      quizAnswered = false;
      quizCorrect = null;
      selectedAnswer = null;
      spellingComplete = false;
      _updateViewFromStep(lessonQueue[nextIndex]);
    } else {
      _finishSession();
    }
  }

  void _finishSession() {
    if (currentSessionCategory == null || currentSessionStepIndex == null) {
      goHome();
      return;
    }

    final unitSteps = getUnitSteps(currentSessionCategory!);
    final isSessionFinalStep = currentSessionStepIndex == unitSteps.length - 1;

    final cats = categoryOrder;
    final isReplay = (cats.indexOf(currentSessionCategory!) <
            userProgress.completedUnitIndex) ||
        (cats.indexOf(currentSessionCategory!) ==
                userProgress.completedUnitIndex &&
            currentSessionStepIndex! < userProgress.completedStepIndex);

    isBigUnitReward = isSessionFinalStep;
    giftOpened = false;
    earnedGift = gifts[Random().nextInt(gifts.length)];

    if (isBigUnitReward) {
      earnedGemAmount = isReplay ? 50 : 250;
      speak('Unit Complete! Amazing work!', high: true);
    } else {
      earnedGemAmount = isReplay ? 20 : 100;
      speak('Lesson Complete! Great job!', high: true);
    }

    currentView = AppView.gift;
    notifyListeners();
  }

  void _updateProgress() {
    if (currentSessionCategory == null || currentSessionStepIndex == null)
      return;

    final cats = categoryOrder;
    if (userProgress.completedUnitIndex >= cats.length) return;

    final progressCat = cats[userProgress.completedUnitIndex];

    // Only update progress if they are playing their actual current uncompleted step
    if (currentSessionCategory == progressCat &&
        currentSessionStepIndex == userProgress.completedStepIndex) {
      final unitSteps = getUnitSteps(progressCat);
      final nextStep = userProgress.completedStepIndex + 1;

      if (nextStep >= unitSteps.length) {
        final nextUnit = userProgress.completedUnitIndex + 1;
        if (nextUnit <= cats.length) {
          userProgress =
              UserProgress(completedUnitIndex: nextUnit, completedStepIndex: 0);
        }
      } else {
        userProgress = UserProgress(
          completedUnitIndex: userProgress.completedUnitIndex,
          completedStepIndex: nextStep,
        );
      }
      _saveState();
    }
  }

  void openGift() {
    giftOpened = true;
    addGems(earnedGemAmount);
    speak('Wow! You got a $earnedGift and $earnedGemAmount gems!', high: true);
    characterMood = 'celebrating';
    _saveState();
    notifyListeners();
  }

  void finishGift() {
    _updateProgress();
    goHome();
  }

  // --- Match / Challenge ---
  void selectAnswer(String itemId) {
    if (quizAnswered) return;
    selectedAnswer = itemId;
    notifyListeners();
  }

  void checkAnswer() {
    if (selectedAnswer == null) return;
    final currentStep = lessonQueue[currentStepIndex];
    final isCorrect = selectedAnswer == currentStep.item?.id;
    quizCorrect = isCorrect;
    quizAnswered = true;

    if (isCorrect) {
      addGems(5);
      streak++;
      totalRightAnswers++;
      hearts += 1;
      speakCorrect();
      characterMood = 'celebrating';
    } else {
      if (hearts > 0) hearts -= 1;
      streak = 0;
      speakWrong();
      characterMood = 'sad';
    }
    _saveState();
    notifyListeners();
  }

  // --- Spelling ---
  void _initSpelling(LearningItem item) {
    final clean = item.name.replaceAll(' ', '').toUpperCase();
    spellingSlots = List.filled(clean.length, null);
    spellingComplete = false;
    spellingWordSpoken = false;

    final letters = clean
        .split('')
        .asMap()
        .entries
        .map((e) => (char: e.value, id: e.key, used: false))
        .toList();
    letters.shuffle(Random());
    scrambledLetters = letters;
  }

  void onSpellingLetterTap(int letterId) {
    if (spellingComplete) return;
    final letterIdx =
        scrambledLetters.indexWhere((l) => l.id == letterId && !l.used);
    if (letterIdx == -1) return;

    final firstEmpty = spellingSlots.indexWhere((s) => s == null);
    if (firstEmpty == -1) return;

    final letter = scrambledLetters[letterIdx];
    // Convert to lowercase so TTS doesn't say "Capital"
    speak(letter.char.toLowerCase(), fast: true, high: true);

    spellingSlots[firstEmpty] = letter.char;
    scrambledLetters[letterIdx] =
        (char: letter.char, id: letter.id, used: true);

    // Check if the correct word is formed and play the full word sound automatically
    if (!spellingSlots.contains(null)) {
      final word = spellingSlots.join('');
      final item = lessonQueue[currentStepIndex].item!;
      final expected = item.name.replaceAll(' ', '').toUpperCase();
      if (word == expected) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!spellingWordSpoken &&
              lessonQueue.isNotEmpty &&
              currentStepIndex < lessonQueue.length &&
              lessonQueue[currentStepIndex].item == item &&
              spellingSlots.join('') == expected) {
            spellingWordSpoken = true;
            final spokenName =
                item.name.length == 1 ? item.name.toLowerCase() : item.name;
            speak(spokenName, high: true);
          }
        });
      }
    }

    _saveState();
    notifyListeners();
  }

  void checkSpelling() {
    if (spellingComplete) return;
    if (spellingSlots.contains(null)) return;

    final word = spellingSlots.join('');
    final item = lessonQueue[currentStepIndex].item!;
    final expected = item.name.replaceAll(' ', '').toUpperCase();

    quizAnswered = true;

    if (word == expected) {
      spellingComplete = true;
      quizCorrect = true;

      characterMood = 'celebrating';
      addGems(10);
      totalRightAnswers++;
      hearts += 1;
      speakCorrect();
    } else {
      quizCorrect = false;
      speakWrong();
      characterMood = 'sad';
      if (hearts > 0) hearts -= 1;
      Future.delayed(const Duration(milliseconds: 1000), () {
        spellingSlots = List.filled(expected.length, null);
        scrambledLetters = scrambledLetters
            .map((l) => (char: l.char, id: l.id, used: false))
            .toList();
        characterMood = 'idle';
        quizCorrect = null;
        quizAnswered = false;
        notifyListeners();
      });
    }
    _saveState();
    notifyListeners();
  }

  void removeLastSpellingSlot() {
    if (spellingComplete) return;
    final lastFilled = spellingSlots.lastIndexWhere((s) => s != null);
    if (lastFilled == -1) return;

    // Un-mark the corresponding scrambled letter
    final char = spellingSlots[lastFilled]!;
    final usedIdx =
        scrambledLetters.lastIndexWhere((l) => l.char == char && l.used);
    if (usedIdx != -1) {
      final l = scrambledLetters[usedIdx];
      scrambledLetters[usedIdx] = (char: l.char, id: l.id, used: false);
    }
    spellingSlots[lastFilled] = null;
    notifyListeners();
  }

  // --- Stats ---
  void addGems(int amount) {
    gems += amount;
    _saveState();
    notifyListeners();
  }

  // --- Splash ---
  void startApp() {
    speak('Welcome to Kiddie Lingo!', fast: true);
    Future.delayed(const Duration(milliseconds: 800), () {
      currentView = AppView.home;
      notifyListeners();
    });
  }

  // --- Character ---
  void onCharacterTap() {
    characterMood = 'talking';
    speak("Let's learn!", high: true);
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      characterMood = 'idle';
      notifyListeners();
    });
  }

  LessonStep? get currentStep =>
      lessonQueue.isNotEmpty ? lessonQueue[currentStepIndex] : null;
}
