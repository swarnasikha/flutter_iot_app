import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String deviceId;
  final DateTime startTime;
  final DateTime? endTime;
  final int targetTemp;
  final int timer;
  final String status;

  SessionModel({
    required this.deviceId,
    required this.startTime,
    this.endTime,
    required this.targetTemp,
    required this.timer,
    required this.status,
  });

 // In your SessionModel
Map<String, dynamic> toMap() {
  return {
    'deviceId': deviceId,
    'startTime': startTime,
    'targetTemp': targetTemp,
    'timer': timer,
    'status': status,
    'endTime': null, // ✅ Must be explicitly present so Firestore queries can match it
  };
}

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      deviceId: data['deviceId'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null,
      targetTemp: data['targetTemp'],
      timer: data['timer'],
      status: data['status'],
    );
  }
}