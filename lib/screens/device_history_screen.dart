// lib/screens/device_history_screen.dart
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/session_model.dart';

class DeviceHistoryScreen extends StatelessWidget {
  final String deviceId;
  final FirestoreService _firestoreService = FirestoreService();

  DeviceHistoryScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Device History")),
      body: StreamBuilder<List<SessionModel>>(
        stream: _firestoreService.getDeviceSessions(deviceId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error loading sessions"));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final sessions = snapshot.data!;
          if (sessions.isEmpty) return Center(child: Text("No sessions found"));

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final s = sessions[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text(
                      "${s.status} - Temp: ${s.targetTemp}°C, Timer: ${s.timer} min"),
                  subtitle: Text(
                      "Started: ${s.startTime}\nEnded: ${s.endTime ?? 'Running'}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}