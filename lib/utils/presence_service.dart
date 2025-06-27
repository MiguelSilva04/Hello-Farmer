import 'package:firebase_database/firebase_database.dart';

class PresenceService {
  final String userId;
  final DatabaseReference _presenceRef;

  PresenceService(this.userId)
      : _presenceRef = FirebaseDatabase.instance.ref("userStatus/$userId");

  void initializePresence() {
    _presenceRef.onDisconnect().set({
      'isOnline': false,
      'lastSeen': ServerValue.timestamp,
    });

    _presenceRef.set({
      'isOnline': true,
      'lastSeen': ServerValue.timestamp,
    });
  }
}
