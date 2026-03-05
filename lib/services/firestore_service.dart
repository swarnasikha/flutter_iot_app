import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/device_model.dart';
import '../models/session_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all devices
  Stream<List<DeviceModel>> getDevices() {
    return _firestore.collection('devices').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => DeviceModel.fromFirestore(doc)).toList(),
        );
  }

  // Get device by ID
  Stream<DeviceModel> getDeviceById(String deviceId) {
    return _firestore.collection('devices').doc(deviceId).snapshots().map(
          (doc) => DeviceModel.fromFirestore(doc),
        );
  }

  // Create session
  Future<void> createSession(SessionModel session) async {
    await _firestore.collection('sessions').add(session.toMap());
  }

  // Get sessions for a device
  // Get sessions for a device
Stream<List<SessionModel>> getDeviceSessions(String deviceId) {
  return _firestore
      .collection('sessions')
      .where('deviceId', isEqualTo: deviceId)
      // ❌ Removed: .orderBy('startTime', descending: true)
      // This required a composite index; without it the stream silently dies
      .snapshots()
      .map((snapshot) {
        final sessions = snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList();
        // ✅ Sort in Dart instead — no index needed
        sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
        return sessions;
      });
}

  // Update device online status
  Future<void> updateDeviceStatus(String deviceId, bool isOnline) async {
    await _firestore.collection('devices').doc(deviceId).update({
      'status': isOnline ? 'running' : 'idle',
    });
  }

  // Update target temperature
  Future<void> updateTargetTemperature(String deviceId, int targetTemp) async {
    await _firestore.collection('devices').doc(deviceId).update({
      'targetTemp': targetTemp,
    });
  }

  // Update timer
  Future<void> updateDeviceTimer(String deviceId, int timer) async {
    await _firestore.collection('devices').doc(deviceId).update({
      'timer': timer,
    });
  }

  // Get user role
  Future<String> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data()!.containsKey('role')) {
      return doc.data()!['role'];
    }
    return 'user';
  }

  // Stop ongoing session (update endTime)
  Future<void> stopOngoingSession(String deviceId) async {
  try {
    // ✅ Only filter by deviceId + status
    // Avoid filtering on endTime — field may not exist on the doc at all,
    // which causes the isNull filter to silently miss it
    final query = await _firestore
        .collection('sessions')
        .where('deviceId', isEqualTo: deviceId)
        .where('status', isEqualTo: 'Running')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;
      await _firestore.collection('sessions').doc(docId).update({
        'endTime': FieldValue.serverTimestamp(),
        'status': 'Stopped',
      });
      print("Session stopped: $docId");
    } else {
      print("No running session found for device $deviceId");
    }
  } catch (e) {
    print("Error stopping session: $e");
    rethrow;
  }
}
  
}