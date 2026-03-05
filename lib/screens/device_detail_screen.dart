import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/device_model.dart';
import '../models/session_model.dart';


class DeviceDetailScreen extends StatefulWidget {
  final String deviceId;
  final String? role;

  const DeviceDetailScreen({super.key, required this.deviceId, this.role});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isOnline = false;
  double _targetTemp = 0;
  int _timer = 0;
  bool _initialized = false;

  late AnimationController _rotateController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeIn));

    _rotateController.repeat();
    _slideController.forward();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFFF6B35), size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFFFF6B35), width: 1),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _initLocalState(DeviceModel device) {
    if (!_initialized) {
      _isOnline = device.isOnline;
      _targetTemp = device.targetTemp.toDouble();
      _timer = device.timer;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // ── Background grid ───────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Custom AppBar ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF12121F),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF2A2A3E),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios,
                                  color: Color(0xFF666680),
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "BACK",
                                  style: TextStyle(
                                    color: Color(0xFF666680),
                                    fontSize: 10,
                                    letterSpacing: 2,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "DEVICE DETAILS",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              "UNIT MONITOR",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 9,
                                letterSpacing: 3,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ── Device info & admin controls ──────────
                  Expanded(
                    flex: 4,
                    child: StreamBuilder<DeviceModel>(
                      stream: _firestoreService.getDeviceById(widget.deviceId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Color(0xFFFF6B35),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "LOADING DEVICE...",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "ERROR LOADING DEVICE",
                              style: TextStyle(
                                color: Colors.red.withOpacity(0.7),
                                fontFamily: 'monospace',
                                letterSpacing: 2,
                              ),
                            ),
                          );
                        }

                        final device = snapshot.data!;
                        _initLocalState(device);

                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Device name + status ──────
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0E0E1A),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _isOnline
                                        ? const Color(
                                            0xFFFF6B35,
                                          ).withOpacity(0.5)
                                        : const Color(0xFF1E1E30),
                                    width: _isOnline ? 1.5 : 1,
                                  ),
                                  boxShadow: _isOnline
                                      ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFFF6B35,
                                            ).withOpacity(0.06),
                                            blurRadius: 16,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 9,
                                      height: 9,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isOnline
                                            ? const Color(0xFF00FF88)
                                            : const Color(0xFF333350),
                                        boxShadow: _isOnline
                                            ? [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF00FF88,
                                                  ).withOpacity(0.5),
                                                  blurRadius: 8,
                                                ),
                                              ]
                                            : [],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            device.name.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 3,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "ID: ${device.id}",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              fontSize: 9,
                                              fontFamily: 'monospace',
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isOnline
                                            ? const Color(
                                                0xFF00FF88,
                                              ).withOpacity(0.1)
                                            : const Color(0xFF1A1A2E),
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: _isOnline
                                              ? const Color(
                                                  0xFF00FF88,
                                                ).withOpacity(0.4)
                                              : const Color(0xFF2A2A3E),
                                        ),
                                      ),
                                      child: Text(
                                        _isOnline ? 'RUNNING' : 'IDLE',
                                        style: TextStyle(
                                          color: _isOnline
                                              ? const Color(0xFF00FF88)
                                              : const Color(0xFF444460),
                                          fontSize: 9,
                                          letterSpacing: 2,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ── Live readings ─────────────
                              Row(
                                children: [
                                  _ReadingCard(
                                    icon: Icons.thermostat_outlined,
                                    label: "CURRENT TEMP",
                                    value:
                                        "${device.currentTemp.toStringAsFixed(1)}°C",
                                    accent: const Color(0xFFFF6B35),
                                  ),
                                  const SizedBox(width: 10),
                                  _ReadingCard(
                                    icon: Icons.compress_outlined,
                                    label: "PRESSURE",
                                    value:
                                        "${device.pressure.toStringAsFixed(1)} Pa",
                                    accent: const Color(0xFF4A9EFF),
                                  ),
                                ],
                              ),

                              // ── Admin controls ────────────
                              if (widget.role == "admin") ...[
                                const SizedBox(height: 12),
                                _buildSectionDivider("ADMIN CONTROLS"),
                                const SizedBox(height: 12),

                                // Power toggle
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0E0E1A),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFF1E1E30),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.power_settings_new,
                                            color: _isOnline
                                                ? const Color(0xFFFF6B35)
                                                : const Color(0xFF444460),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            "DEVICE POWER",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              letterSpacing: 2,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Switch(
                                        value: _isOnline,
                                        onChanged: (val) async {
                                          setState(() => _isOnline = val);
                                          try {
                                            await _firestoreService
                                                .updateDeviceStatus(
                                                  device.id,
                                                  val,
                                                );
                                            if (val) {
                                              // Device turned ON → create a new session
                                              await _firestoreService
                                                  .createSession(
                                                    SessionModel(
                                                      deviceId: device.id,
                                                      startTime: DateTime.now(),
                                                      targetTemp:
                                                          device.targetTemp,
                                                      timer: device.timer,
                                                      status: 'Running',
                                                    ),
                                                  );
                                              _showSnackBar("Device turned ON");
                                             
                                            } else {
                                              // Device turned OFF → stop ongoing session
                                              try {
                                                await _firestoreService
                                                    .stopOngoingSession(
                                                      device.id,
                                                    );
                                                _showSnackBar(
                                                  "Device turned OFF and session stopped",
                                                );
                                               
                                              } catch (e) {
                                                _showSnackBar(
                                                  "Device turned OFF but session update failed",
                                                );
                                                print(
                                                  "Error stopping session: $e",
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            setState(
                                              () => _isOnline = !val,
                                            ); // revert toggle on failure
                                            _showSnackBar(
                                              "Failed to update device status",
                                            );
                                            print("Error toggling device: $e");
                                          }
                                        },
                                        activeThumbColor: const Color(
                                          0xFFFF6B35,
                                        ),
                                        activeTrackColor: const Color(
                                          0xFFFF6B35,
                                        ).withOpacity(0.3),
                                        inactiveThumbColor: const Color(
                                          0xFF444460,
                                        ),
                                        inactiveTrackColor: const Color(
                                          0xFF1E1E30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // Target temp slider
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    4,
                                    6,
                                    4,
                                    2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0E0E1A),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFF1E1E30),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.thermostat_outlined,
                                            color: Color(0xFFFF6B35),
                                            size: 14,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "TARGET TEMPERATURE",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              letterSpacing: 2,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "${_targetTemp.toStringAsFixed(1)}°C",
                                            style: const TextStyle(
                                              color: Color(0xFFFF6B35),
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                      SliderTheme(
                                        data: SliderThemeData(
                                          activeTrackColor: const Color(
                                            0xFFFF6B35,
                                          ),
                                          inactiveTrackColor: const Color(
                                            0xFF2A2A3E,
                                          ),
                                          thumbColor: const Color(0xFFFF6B35),
                                          overlayColor: const Color(
                                            0xFFFF6B35,
                                          ).withOpacity(0.1),
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                                enabledThumbRadius: 6,
                                              ),
                                          trackHeight: 2,
                                        ),
                                        child: Slider(
                                          value: _targetTemp,
                                          min: 0,
                                          max: 150,
                                          divisions: 150,
                                          label: _targetTemp.toStringAsFixed(1),
                                          onChanged: (val) =>
                                              setState(() => _targetTemp = val),
                                          onChangeEnd: (val) async {
                                            try {
                                              await _firestoreService
                                                  .updateTargetTemperature(
                                                    device.id,
                                                    val.toInt(),
                                                  );
                                              _showSnackBar(
                                                "Target temp set to ${val.toStringAsFixed(1)} °C",
                                              );
                                            } catch (e) {
                                              _showSnackBar(
                                                "Failed to update temperature",
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "0°C",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              fontSize: 9,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          Text(
                                            "150°C",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              fontSize: 9,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // Timer control
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0E0E1A),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFF1E1E30),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.timer_outlined,
                                        color: Color(0xFF00FF88),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "TIMER",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          letterSpacing: 2,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const Spacer(),
                                      // Decrement
                                      GestureDetector(
                                        onTap: () async {
                                          if (_timer > 0) {
                                            setState(() => _timer -= 1);
                                            try {
                                              await _firestoreService
                                                  .updateDeviceTimer(
                                                    device.id,
                                                    _timer,
                                                  );
                                              _showSnackBar(
                                                "Timer updated to $_timer min",
                                              );
                                            } catch (e) {
                                              setState(() => _timer += 1);
                                              _showSnackBar(
                                                "Failed to update timer",
                                              );
                                            }
                                          }
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF12121F),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF2A2A3E),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            color: Color(0xFF666680),
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Text(
                                        "$_timer",
                                        style: const TextStyle(
                                          color: Color(0xFF00FF88),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      Text(
                                        " min",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.3),
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      // Increment
                                      GestureDetector(
                                        onTap: () async {
                                          if (_timer < 120) {
                                            setState(() => _timer += 1);
                                            try {
                                              await _firestoreService
                                                  .updateDeviceTimer(
                                                    device.id,
                                                    _timer,
                                                  );
                                              _showSnackBar(
                                                "Timer updated to $_timer min",
                                              );
                                            } catch (e) {
                                              setState(() => _timer -= 1);
                                              _showSnackBar(
                                                "Failed to update timer",
                                              );
                                            }
                                          }
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF12121F),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF2A2A3E),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Color(0xFFFF6B35),
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Section divider ───────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    child: _buildSectionDivider("SESSION HISTORY"),
                  ),

                  // ── Session history ───────────────────────
                  Expanded(
                    flex: 2,
                    child: SessionHistoryList(deviceId: widget.deviceId),
                  ),

                  const SizedBox(height: 8),
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

// ── Reading card ──────────────────────────────────────────
class _ReadingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _ReadingCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E1A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF1E1E30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 16),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 8,
                letterSpacing: 2,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Session History List ──────────────────────────────────
class SessionHistoryList extends StatelessWidget {
  final String deviceId;
  final FirestoreService _firestoreService = FirestoreService();

  SessionHistoryList({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SessionModel>>(
      stream: _firestoreService.getDeviceSessions(deviceId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Color(0xFFFF6B35)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "LOADING SESSIONS...",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontFamily: 'monospace',
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "ERROR LOADING SESSIONS",
              style: TextStyle(
                color: Colors.red.withOpacity(0.6),
                fontFamily: 'monospace',
                letterSpacing: 2,
                fontSize: 11,
              ),
            ),
          );
        }

        final sessions = snapshot.data!
          ..sort((a, b) => b.startTime.compareTo(a.startTime));

        if (sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history_toggle_off_outlined,
                  color: Colors.white.withOpacity(0.1),
                  size: 36,
                ),
                const SizedBox(height: 10),
                Text(
                  "NO SESSION HISTORY",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.2),
                    fontFamily: 'monospace',
                    letterSpacing: 3,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final s = sessions[index];
            final isRunning = s.status == 'Running';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0E0E1A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isRunning
                      ? const Color(0xFF00FF88).withOpacity(0.3)
                      : const Color(0xFF1E1E30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isRunning
                                ? const Color(0xFF00FF88)
                                : const Color(0xFF444460),
                            boxShadow: isRunning
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00FF88,
                                      ).withOpacity(0.5),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          s.status.toUpperCase(),
                          style: TextStyle(
                            color: isRunning
                                ? const Color(0xFF00FF88)
                                : const Color(0xFF666680),
                            fontSize: 9,
                            letterSpacing: 2,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        _SessionChip(
                          icon: Icons.thermostat_outlined,
                          value: "${s.targetTemp}°C",
                          color: const Color(0xFFFF6B35),
                        ),
                        const SizedBox(width: 6),
                        _SessionChip(
                          icon: Icons.timer_outlined,
                          value: "${s.timer}m",
                          color: const Color(0xFF4A9EFF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeField(
                            label: "START",
                            value: _formatTime(s.startTime),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TimeField(
                            label: "END",
                            value: s.endTime != null
                                ? _formatTime(s.endTime!)
                                : "ONGOING",
                            isOngoing: s.endTime == null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}

class _SessionChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _SessionChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final bool isOngoing;

  const _TimeField({
    required this.label,
    required this.value,
    this.isOngoing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF12121F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF1E1E30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 8,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: isOngoing
                  ? const Color(0xFF00FF88)
                  : Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: isOngoing ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
