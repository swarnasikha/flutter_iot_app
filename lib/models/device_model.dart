import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String id; // Firestore document ID
  final String name;
  final double currentTemp;
  final double pressure;
  final int targetTemp;
  final int timer;
  final bool isOnline;

  DeviceModel({
    required this.id,
    required this.name,
    required this.currentTemp,
    required this.pressure,
    required this.targetTemp,
    required this.timer,
    required this.isOnline,
  });

  factory DeviceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeviceModel(
      id: doc.id,
      name: data['name'] ?? '',
      currentTemp: (data['currentTemp'] ?? 0).toDouble(),
      pressure: (data['pressure'] ?? 0).toDouble(),
      targetTemp: data['targetTemp'] ?? 0,
      timer: data['timer'] ?? 0,
      isOnline: (data['status'] ?? 'idle') == 'running',
    );
  }
}