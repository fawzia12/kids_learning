import 'package:flutter/material.dart';
import '../../models/types.dart';
import '../repositories/firestore_repository.dart';

class FirestoreProvider extends ChangeNotifier {
  final FirestoreRepository _repository;

  List<LearningItem> _cachedItems = [];
  bool _isLoading = false;
  String? _error;

  FirestoreProvider({FirestoreRepository? repository})
      : _repository = repository ?? FirestoreRepository();

  List<LearningItem> get items => _cachedItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ১. আগে ডাটা ফেচ করে ক্যাশে অ্যাসাইন করো
      _cachedItems = await _repository.getLearningItems();

      // ২. ডাটা আসার পর এখন প্রিন্ট করো
      print("🌐 [Firestore Success]: ফায়ারস্টোর থেকে ডাটা সফলভাবে এসেছে!");
      print("📊 মোট আইটেম সংখ্যা: ${_cachedItems.length} টি");
    } catch (e) {
      _error = e.toString();
      print("❌ [Firestore Error]: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<LearningItem> getItemsByCategory(Category category,
      {required List<LearningItem> fallbackData}) {
    if (_error != null || _cachedItems.isEmpty) {
      return fallbackData.where((item) => item.category == category).toList();
    }
    final filtered =
        _cachedItems.where((item) => item.category == category).toList();
    if (filtered.isEmpty) {
      return fallbackData.where((item) => item.category == category).toList();
    }
    return filtered;
  }
}
