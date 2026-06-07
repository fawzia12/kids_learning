import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore_item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FirestoreLearningItem>> fetchLearningItems() async {
    final querySnapshot = await _firestore.collection('learning_items').get();
    return querySnapshot.docs.map((doc) {
      return FirestoreLearningItem.fromMap(doc.data());
    }).toList();
  }
}
