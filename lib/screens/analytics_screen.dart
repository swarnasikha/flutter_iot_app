// TODO: Charts for usage statistics

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/device_model.dart';
import '../models/session_model.dart';
import 'dart:math' as math;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController _rotateController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;

  // Analytics data
  int _totalDevices = 0;
  int _onlineDevices = 0;
  int _totalSessions = 0;
  int _runningSessions = 0;
  double _avgTemp = 0;
  double _avgPressure = 0;
  double _avgTargetTemp = 0;
  double _avgSessionDuration = 0;
  List<SessionModel> _recentSessions = [];
  List<DeviceModel> _devices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeIn),
    );

    _rotateController.repeat();
    _slideController.forward();
    _loadAnalytics();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    try {
      // Fetch devices
      final devicesSnap = await _firestore.collection('devices').get();
      final devices = devicesSnap.docs.map((d) => DeviceModel.fromFirestore(d)).toList();

      // Fetch all sessions
      final sessionsSnap = await _firestore.collection('sessions').get();
      final sessions = sessionsSnap.docs.map((d) => SessionModel.fromFirestore(d)).toList();

      // Compute stats
      final online = devices.where((d) => d.isOnline).length;
      final running = sessions.where((s) => s.status == 'Running').length;
      final avgTemp = devices.isEmpty ? 0.0 : devices.map((d) => d.currentTemp).reduce((a, b) => a + b) / devices.length;
      final avgPressure = devices.isEmpty ? 0.0 : devices.map((d) => d.pressure).reduce((a, b) => a + b) / devices.length;
      final avgTarget = devices.isEmpty ? 0.0 : devices.map((d) => d.targetTemp.toDouble()).reduce((a, b) => a + b) / devices.length;

      // Avg session duration (only completed sessions)
      final completed = sessions.where((s) => s.endTime != null).toList();
      final avgDuration = completed.isEmpty
          ? 0.0
          : completed
                  .map((s) => s.endTime!.difference(s.startTime).inMinutes.toDouble())
                  .reduce((a, b) => a + b) /
              completed.length;

      // Sort recent sessions
      final recent = List<SessionModel>.from(sessions)
        ..sort((a, b) => b.startTime.compareTo(a.startTime));

      setState(() {
        _totalDevices = devices.length;
        _onlineDevices = online;
        _totalSessions = sessions.length;
        _runningSessions = running;
        _avgTemp = avgTemp.toDouble();
        _avgPressure = avgPressure.toDouble();
        _avgTargetTemp = avgTarget;
        _avgSessionDuration = avgDuration;
        _recentSessions = recent.take(10).toList();
        _devices = devices;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print("Analytics load error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          // Rotating gear
          Positioned(
            top: -50,
            right: -50,
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (_, _) => Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: const _GearWidget(size: 160, color: Color(0xFF1C1C2E)),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF12121F),
                            border: Border.all(color: const Color(0xFFFF6B35), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B35).withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.analytics_outlined, color: Color(0xFFFF6B35), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ANALYTICS",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              "SYSTEM INTELLIGENCE",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 9,
                                letterSpacing: 3,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Refresh button
                        GestureDetector(
                          onTap: () {
                            setState(() => _loading = true);
                            _loadAnalytics();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF12121F),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF2A2A3E)),
                            ),
                            child: const Icon(Icons.refresh, color: Color(0xFF666680), size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Content ───────────────────────────────
                  Expanded(
                    child: _loading
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Color(0xFFFF6B35)),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  "COMPILING DATA...",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            children: [
                              // ── Section: Devices ──────────
                              _buildSectionDivider("DEVICE OVERVIEW"),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  _StatCard(
                                    label: "TOTAL\nDEVICES",
                                    value: "$_totalDevices",
                                    icon: Icons.devices_outlined,
                                    accent: const Color(0xFF4A9EFF),
                                  ),
                                  const SizedBox(width: 10),
                                  _StatCard(
                                    label: "ONLINE\nNOW",
                                    value: "$_onlineDevices",
                                    icon: Icons.sensors,
                                    accent: const Color(0xFF00FF88),
                                    glowing: _onlineDevices > 0,
                                  ),
                                  const SizedBox(width: 10),
                                  _StatCard(
                                    label: "OFFLINE\nUNITS",
                                    value: "${_totalDevices - _onlineDevices}",
                                    icon: Icons.sensors_off_outlined,
                                    accent: const Color(0xFF666680),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Online ratio bar
                              if (_totalDevices > 0) ...[
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0E0E1A),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF1E1E30)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "FLEET UPTIME",
                                            style: TextStyle(
                                              color: Color(0xFF666680),
                                              fontSize: 9,
                                              letterSpacing: 2,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          Text(
                                            "${(_onlineDevices / _totalDevices * 100).toStringAsFixed(0)}%",
                                            style: const TextStyle(
                                              color: Color(0xFF00FF88),
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: LinearProgressIndicator(
                                          value: _totalDevices == 0 ? 0 : _onlineDevices / _totalDevices,
                                          backgroundColor: const Color(0xFF1E1E30),
                                          valueColor: const AlwaysStoppedAnimation(Color(0xFF00FF88)),
                                          minHeight: 4,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Per-device bars
                                      ..._devices.map((d) => Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: d.isOnline ? const Color(0xFF00FF88) : const Color(0xFF333350),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    d.name.toUpperCase(),
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.5),
                                                      fontSize: 9,
                                                      fontFamily: 'monospace',
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  d.isOnline ? 'ONLINE' : 'OFFLINE',
                                                  style: TextStyle(
                                                    color: d.isOnline ? const Color(0xFF00FF88) : const Color(0xFF444460),
                                                    fontSize: 9,
                                                    fontFamily: 'monospace',
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),

                              // ── Section: Live Readings ────
                              _buildSectionDivider("LIVE READINGS"),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  _StatCard(
                                    label: "AVG\nTEMP",
                                    value: "${_avgTemp.toStringAsFixed(1)}°",
                                    icon: Icons.thermostat_outlined,
                                    accent: const Color(0xFFFF6B35),
                                  ),
                                  const SizedBox(width: 10),
                                  _StatCard(
                                    label: "AVG\nPRESSURE",
                                    value: _avgPressure.toStringAsFixed(0),
                                    unit: "Pa",
                                    icon: Icons.compress_outlined,
                                    accent: const Color(0xFF4A9EFF),
                                  ),
                                  const SizedBox(width: 10),
                                  _StatCard(
                                    label: "AVG\nTARGET",
                                    value: "${_avgTargetTemp.toStringAsFixed(1)}°",
                                    icon: Icons.flag_outlined,
                                    accent: const Color(0xFFFFCC00),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Temp bars per device
                              if (_devices.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0E0E1A),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF1E1E30)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "TEMPERATURE PER UNIT",
                                        style: TextStyle(
                                          color: Color(0xFF666680),
                                          fontSize: 9,
                                          letterSpacing: 2,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      ..._devices.map((d) {
                                        final ratio = d.currentTemp / 150.0;
                                        final targetRatio = d.targetTemp / 150.0;
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    d.name.toUpperCase(),
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.6),
                                                      fontSize: 9,
                                                      fontFamily: 'monospace',
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${d.currentTemp.toStringAsFixed(1)}°C",
                                                        style: const TextStyle(
                                                          color: Color(0xFFFF6B35),
                                                          fontSize: 10,
                                                          fontFamily: 'monospace',
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        " / ${d.targetTemp}°C",
                                                        style: TextStyle(
                                                          color: Colors.white.withOpacity(0.25),
                                                          fontSize: 9,
                                                          fontFamily: 'monospace',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Stack(
                                                children: [
                                                  // Background track
                                                  Container(
                                                    height: 4,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF1E1E30),
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                  // Target marker
                                                  FractionallySizedBox(
                                                    widthFactor: targetRatio.clamp(0.0, 1.0),
                                                    child: Container(
                                                      height: 4,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFFFCC00).withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(2),
                                                      ),
                                                    ),
                                                  ),
                                                  // Current temp fill
                                                  FractionallySizedBox(
                                                    widthFactor: ratio.clamp(0.0, 1.0),
                                                    child: Container(
                                                      height: 4,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFFF6B35),
                                                        borderRadius: BorderRadius.circular(2),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      // Legend
                                      Row(
                                        children: [
                                          Container(width: 12, height: 3, color: const Color(0xFFFF6B35)),
                                          const SizedBox(width: 6),
                                          Text("Current", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8, fontFamily: 'monospace')),
                                          const SizedBox(width: 14),
                                          Container(width: 12, height: 3, color: const Color(0xFFFFCC00).withOpacity(0.4)),
                                          const SizedBox(width: 6),
                                          Text("Target", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8, fontFamily: 'monospace')),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),

                              // ── Section: Sessions ─────────
                              _buildSectionDivider("SESSION STATS"),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  _StatCard(
                                    label: "TOTAL\nSESSIONS",
                                    value: "$_totalSessions",
                                    icon: Icons.history_outlined,
                                    accent: const Color(0xFF4A9EFF),
                                  ),
                                  const SizedBox(width: 10),
                                  _StatCard(
                                    label: "ACTIVE\nNOW",
                                    value: "$_runningSessions",
                                    icon: Icons.play_circle_outline,
                                    accent: const Color(0xFF00FF88),
                                    glowing: _runningSessions > 0,
                                  ),
                                  const SizedBox(width: 10),
                                  _StatCard(
                                    label: "AVG\nDURATION",
                                    value: _avgSessionDuration.toStringAsFixed(0),
                                    unit: "min",
                                    icon: Icons.timer_outlined,
                                    accent: const Color(0xFFFFCC00),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Session status breakdown
                              if (_totalSessions > 0) ...[
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0E0E1A),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF1E1E30)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "SESSION BREAKDOWN",
                                        style: TextStyle(
                                          color: Color(0xFF666680),
                                          fontSize: 9,
                                          letterSpacing: 2,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      _SessionBreakdownBar(
                                        running: _runningSessions,
                                        stopped: _totalSessions - _runningSessions,
                                        total: _totalSessions,
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),

                              // ── Section: Recent Sessions ──
                              _buildSectionDivider("RECENT SESSIONS"),
                              const SizedBox(height: 12),

                              if (_recentSessions.isEmpty)
                                Center(
                                  child: Text(
                                    "NO SESSION DATA",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.2),
                                      fontFamily: 'monospace',
                                      letterSpacing: 2,
                                      fontSize: 11,
                                    ),
                                  ),
                                )
                              else
                                ..._recentSessions.map((s) => _RecentSessionRow(session: s)),
                            ],
                          ),
                  ),

                  // ── Status bar ────────────────────────────
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D1A),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF1E1E30)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00FF88)),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "SYS STATUS: ONLINE",
                          style: TextStyle(color: Color(0xFF444460), fontSize: 10, letterSpacing: 2, fontFamily: 'monospace'),
                        ),
                        const Spacer(),
                        const Text("v2.4.1", style: TextStyle(color: Color(0xFF333350), fontSize: 10, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        Container(width: 16, height: 1, color: const Color(0xFF2A2A3E)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFFFF6B35),
            letterSpacing: 3,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: const Color(0xFF2A2A3E))),
      ],
    );
  }
}

// ── Stat card ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color accent;
  final bool glowing;

  const _StatCard({
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
    required this.accent,
    this.glowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E1A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: glowing ? accent.withOpacity(0.4) : const Color(0xFF1E1E30),
          ),
          boxShadow: glowing
              ? [BoxShadow(color: accent.withOpacity(0.08), blurRadius: 12)]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 14),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    height: 1,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit!,
                      style: TextStyle(
                        color: accent.withOpacity(0.5),
                        fontSize: 9,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 8,
                letterSpacing: 1.5,
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Session breakdown bar ─────────────────────────────────
class _SessionBreakdownBar extends StatelessWidget {
  final int running;
  final int stopped;
  final int total;

  const _SessionBreakdownBar({
    required this.running,
    required this.stopped,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final runningRatio = total == 0 ? 0.0 : running / total;
    final stoppedRatio = total == 0 ? 0.0 : stopped / total;

    return Column(
      children: [
        // Stacked bar
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                if (runningRatio > 0)
                  Flexible(
                    flex: running,
                    child: Container(color: const Color(0xFF00FF88)),
                  ),
                if (stoppedRatio > 0)
                  Flexible(
                    flex: stopped,
                    child: Container(color: const Color(0xFF2A2A3E)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Labels
        Row(
          children: [
            _BreakdownLabel(color: const Color(0xFF00FF88), label: "RUNNING", count: running),
            const SizedBox(width: 20),
            _BreakdownLabel(color: const Color(0xFF444460), label: "STOPPED", count: stopped),
          ],
        ),
      ],
    );
  }
}

class _BreakdownLabel extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _BreakdownLabel({required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(
          "$label  $count",
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontFamily: 'monospace', letterSpacing: 1),
        ),
      ],
    );
  }
}

// ── Recent session row ────────────────────────────────────
class _RecentSessionRow extends StatelessWidget {
  final SessionModel session;

  const _RecentSessionRow({required this.session});

  String _fmt(DateTime dt) =>
      "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} "
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final isRunning = session.status == 'Running';
    final duration = session.endTime != null
        ? "${session.endTime!.difference(session.startTime).inMinutes}m"
        : "LIVE";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E1A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isRunning ? const Color(0xFF00FF88).withOpacity(0.25) : const Color(0xFF1A1A2A),
        ),
      ),
      child: Row(
        children: [
          // Status dot
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRunning ? const Color(0xFF00FF88) : const Color(0xFF333350),
              boxShadow: isRunning
                  ? [BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.5), blurRadius: 6)]
                  : [],
            ),
          ),
          const SizedBox(width: 10),
          // Device ID (truncated)
          Expanded(
            flex: 2,
            child: Text(
              session.deviceId.substring(0, math.min(8, session.deviceId.length)).toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 9,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
          ),
          // Temp
          Text(
            "${session.targetTemp}°C",
            style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 10, fontFamily: 'monospace'),
          ),
          const SizedBox(width: 10),
          // Duration
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isRunning
                  ? const Color(0xFF00FF88).withOpacity(0.08)
                  : const Color(0xFF1A1A2A),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: isRunning ? const Color(0xFF00FF88).withOpacity(0.3) : const Color(0xFF2A2A3E),
              ),
            ),
            child: Text(
              duration,
              style: TextStyle(
                color: isRunning ? const Color(0xFF00FF88) : const Color(0xFF666680),
                fontSize: 9,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Start time
          Text(
            _fmt(session.startTime),
            style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 9, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

// ── Shared decorators ─────────────────────────────────────
class _GearWidget extends StatelessWidget {
  final double size;
  final Color color;
  const _GearWidget({required this.size, required this.color});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _GearPainter(color: color));
}

class _GearPainter extends CustomPainter {
  final Color color;
  _GearPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final innerRadius = radius * 0.6;
    const teethCount = 12;
    final teethHeight = radius * 0.18;
    final path = Path();

    for (int i = 0; i < teethCount; i++) {
      final a = (i / teethCount) * 2 * math.pi;
      final b = ((i + 0.5) / teethCount) * 2 * math.pi;
      final c = ((i + 1) / teethCount) * 2 * math.pi;
      final x1 = center.dx + innerRadius * math.cos(a);
      final y1 = center.dy + innerRadius * math.sin(a);
      final x2 = center.dx + (radius + teethHeight) * math.cos(b);
      final y2 = center.dy + (radius + teethHeight) * math.sin(b);
      final x3 = center.dx + innerRadius * math.cos(c);
      final y3 = center.dy + innerRadius * math.sin(c);
      if (i == 0) path.moveTo(x1, y1);
      path.lineTo(x2, y2);
      path.lineTo(x3, y3);
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(center, innerRadius * 0.4, paint);
  }

  @override
  bool shouldRepaint(_GearPainter old) => old.color != color;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A2E).withOpacity(0.6)
      ..strokeWidth = 0.5;
    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final dot = Paint()..color = const Color(0xFF1E1E35)..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}