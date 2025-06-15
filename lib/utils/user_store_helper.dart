import 'package:cloud_firestore/cloud_firestore.dart';

class UserStoreHelper {
  static Future<String> getUserName(String userId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      return "${doc.data()?['firstName']} ${doc.data()?['lastName']}";
    } catch (e) {
      return 'Utilizador';
    }
  }

  static Future<String> getStoreName(String storeId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('stores')
              .doc(storeId)
              .get();
      return doc.data()?['name'] ?? 'Loja';
    } catch (e) {
      return 'Loja';
    }
  }
}
