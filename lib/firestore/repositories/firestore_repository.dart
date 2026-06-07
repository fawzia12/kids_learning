import '../../models/types.dart';
import '../models/firestore_item.dart';
import '../services/firestore_service.dart';

class FirestoreRepository {
  final FirestoreService _service;

  FirestoreRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  Future<List<LearningItem>> getLearningItems() async {
    final firestoreItems = await _service.fetchLearningItems();

    // ম্যাপ করার পর আইডি অনুযায়ী সর্ট করা হয়েছে
    final items = firestoreItems.map((item) => item.toLearningItem()).toList();

    // a1, a2 সিরিয়াল ঠিক রাখার জন্য সর্টিং
    items.sort((a, b) => a.id.compareTo(b.id));

    return items;
  }
}
