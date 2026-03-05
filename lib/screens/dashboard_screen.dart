// // lib/screens/dashboard_screen.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:iot_flutter_app/screens/dashboard_screen.dart' as slideController;
// import '../services/firestore_service.dart';
// import '../models/device_model.dart';
// import 'device_detail_screen.dart';
// import 'analytics_screen.dart';
// import 'login_screen.dart';
// import 'dart:math' as math;

// class DashboardScreen extends StatefulWidget {
//   final String? role;

//   const DashboardScreen({super.key, this.role});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen>
//     with TickerProviderStateMixin {
//   final FirestoreService _firestoreService = FirestoreService();

//   late AnimationController _slideController;
//   late AnimationController _rotateController;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();

//     // ✅ _rotateController initialized first before anything uses it
//     _rotateController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 30),
//     );

//     _slideController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );

//     _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _slideController, curve: Curves.easeIn),
//     );

//     // Start animations only after both controllers are ready
//     _rotateController.repeat();
//     _slideController.forward();
//   }

//   @override
//   void dispose() {
//     _slideController.dispose();
//     _rotateController.dispose();
//     super.dispose();
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.info_outline, color: Color(0xFFFF6B35), size: 16),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontFamily: 'monospace',
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF1A1A2E),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(4),
//           side: const BorderSide(color: Color(0xFFFF6B35), width: 1),
//         ),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A0F),
//       body: Stack(
//         children: [
//           // ── Background grid ───────────────────────────────
//           Positioned.fill(child: CustomPaint(painter: _GridPainter())),

//           Positioned(
//             top: -60,
//             right: -60,
//             child: AnimatedBuilder(
//               animation: _rotateController,
//               builder: (_, _) => Transform.rotate(
//                 angle: _rotateController.value * 2 * math.pi,
//                 child: const _GearWidget(size: 180, color: Color(0xFF1C1C2E)),
//               ),
//             ),
//           ),

//           SafeArea(
//             child: FadeTransition(
//               opacity: _fadeAnim,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Top AppBar area ───────────────────────
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
//                     child: Row(
//                       children: [
//                         // Logo
//                         Container(
//                           width: 36,
//                           height: 36,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: const Color(0xFF12121F),
//                             border: Border.all(color: const Color(0xFFFF6B35), width: 1.5),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0xFFFF6B35).withOpacity(0.2),
//                                 blurRadius: 10,
//                               ),
//                             ],
//                           ),
//                           child: const Icon(Icons.whatshot_rounded, color: Color(0xFFFF6B35), size: 18),
//                         ),
//                         const SizedBox(width: 12),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               "STEAM PRO",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w900,
//                                 letterSpacing: 4,
//                                 fontFamily: 'monospace',
//                               ),
//                             ),
//                             Text(
//                               "CONTROL DASHBOARD",
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.3),
//                                 fontSize: 9,
//                                 letterSpacing: 3,
//                                 fontFamily: 'monospace',
//                               ),
//                             ),
//                           ],
//                         ),
//                         const Spacer(),
//                         // Right side: analytics + role stacked vertically to avoid overflow
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             // Analytics button
//                             GestureDetector(
//                               onTap: () => Navigator.push(
//                                 context,
//                                 PageRouteBuilder(
//                                   pageBuilder: (_, _, _) => const AnalyticsScreen(),
//                                   transitionsBuilder: (_, animation, _, child) =>
//                                       FadeTransition(opacity: animation, child: child),
//                                   transitionDuration: const Duration(milliseconds: 300),
//                                 ),
//                               ),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFF12121F),
//                                   borderRadius: BorderRadius.circular(4),
//                                   border: Border.all(color: const Color(0xFF2A2A3E)),
//                                 ),
//                                 child: const Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(Icons.analytics_outlined, color: Color(0xFF4A9EFF), size: 11),
//                                     SizedBox(width: 5),
//                                     Text(
//                                       "ANALYTICS",
//                                       style: TextStyle(
//                                         color: Color(0xFF4A9EFF),
//                                         fontSize: 8,
//                                         letterSpacing: 1.5,
//                                         fontFamily: 'monospace',
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             // Role badge
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: widget.role == 'admin'
//                                     ? const Color(0xFFFF6B35).withOpacity(0.15)
//                                     : const Color(0xFF1E1E30),
//                                 borderRadius: BorderRadius.circular(4),
//                                 border: Border.all(
//                                   color: widget.role == 'admin'
//                                       ? const Color(0xFFFF6B35)
//                                       : const Color(0xFF2A2A3E),
//                                 ),
//                               ),
//                               child: Text(
//                                 widget.role?.toUpperCase() ?? 'USER',
//                                 style: TextStyle(
//                                   color: widget.role == 'admin'
//                                       ? const Color(0xFFFF6B35)
//                                       : const Color(0xFF666680),
//                                   fontSize: 8,
//                                   letterSpacing: 1.5,
//                                   fontFamily: 'monospace',
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             // Logout button
//                             GestureDetector(
//                               onTap: () async {
//                                 await FirebaseAuth.instance.signOut();
//                                 if (context.mounted) {
//                                   Navigator.pushAndRemoveUntil(
//                                     context,
//                                     PageRouteBuilder(
//                                       pageBuilder: (_, _, _) => const LoginScreen(),
//                                       transitionsBuilder: (_, animation, _, child) =>
//                                           FadeTransition(opacity: animation, child: child),
//                                       transitionDuration: const Duration(milliseconds: 400),
//                                     ),
//                                     (route) => false,
//                                   );
//                                 }
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFFF3B30).withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(4),
//                                   border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.4)),
//                                 ),
//                                 child: const Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(Icons.logout, color: Color(0xFFFF3B30), size: 11),
//                                     SizedBox(width: 5),
//                                     Text(
//                                       "LOGOUT",
//                                       style: TextStyle(
//                                         color: Color(0xFFFF3B30),
//                                         fontSize: 8,
//                                         letterSpacing: 1.5,
//                                         fontFamily: 'monospace',
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   // ── Divider ───────────────────────────────
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                     child: Row(
//                       children: [
//                         Container(width: 16, height: 1, color: const Color(0xFF2A2A3E)),
//                         const SizedBox(width: 8),
//                         const Text(
//                           "ACTIVE UNITS",
//                           style: TextStyle(
//                             fontSize: 9,
//                             color: Color(0xFFFF6B35),
//                             letterSpacing: 3,
//                             fontFamily: 'monospace',
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(child: Container(height: 1, color: const Color(0xFF2A2A3E))),
//                       ],
//                     ),
//                   ),

//                   // ── Device List ───────────────────────────
//                   Expanded(
//                     child: StreamBuilder<List<DeviceModel>>(
//                       stream: _firestoreService.getDevices(),
//                       builder: (context, snapshot) {
//                         if (snapshot.hasError) {
//                           return Center(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Icon(Icons.error_outline, color: Color(0xFFFF3B30), size: 32),
//                                 const SizedBox(height: 12),
//                                 const Text(
//                                   "ERROR LOADING DEVICES",
//                                   style: TextStyle(
//                                     color: Color(0xFFFF3B30),
//                                     fontFamily: 'monospace',
//                                     letterSpacing: 2,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }

//                         if (!snapshot.hasData) {
//                           return Center(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const SizedBox(
//                                   width: 24,
//                                   height: 24,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor: AlwaysStoppedAnimation(Color(0xFFFF6B35)),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   "SCANNING NETWORK...",
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.3),
//                                     fontFamily: 'monospace',
//                                     letterSpacing: 2,
//                                     fontSize: 11,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }

//                         final devices = snapshot.data!;

//                         if (devices.isEmpty) {
//                           return Center(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.device_unknown_outlined,
//                                     color: Colors.white.withOpacity(0.15), size: 48),
//                                 const SizedBox(height: 12),
//                                 Text(
//                                   "NO DEVICES FOUND",
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.2),
//                                     fontFamily: 'monospace',
//                                     letterSpacing: 3,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }

//                         return ListView.builder(
//                           padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
//                           itemCount: devices.length,
//                           itemBuilder: (context, index) {
//                             final device = devices[index];
//                             return _DeviceCard(
//                               device: device,
//                               isOn: device.isOnline,
//                               role: widget.role,
//                                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   PageRouteBuilder(
//                                     pageBuilder: (_, _, _) => DeviceDetailScreen(
//                                       deviceId: device.id,
//                                       role: widget.role,
//                                     ),
//                                     transitionsBuilder: (_, animation, _, child) =>
//                                         FadeTransition(opacity: animation, child: child),
//                                     transitionDuration: const Duration(milliseconds: 300),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),

//                   // ── Bottom status bar ─────────────────────
//                   Container(
//                     margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF0D0D1A),
//                       borderRadius: BorderRadius.circular(4),
//                       border: Border.all(color: const Color(0xFF1E1E30)),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 6, height: 6,
//                           decoration: const BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Color(0xFF00FF88),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         const Text(
//                           "SYS STATUS: ONLINE",
//                           style: TextStyle(
//                             color: Color(0xFF444460),
//                             fontSize: 10,
//                             letterSpacing: 2,
//                             fontFamily: 'monospace',
//                           ),
//                         ),
//                         const Spacer(),
//                         const Text(
//                           "v2.4.1",
//                           style: TextStyle(
//                             color: Color(0xFF333350),
//                             fontSize: 10,
//                             fontFamily: 'monospace',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Device Card Widget ────────────────────────────────────
// class _DeviceCard extends StatelessWidget {
//   final DeviceModel device;
//   final bool isOn;
//   final String? role;
//   final VoidCallback onTap;

//   const _DeviceCard({
//     required this.device,
//     required this.isOn,
//     required this.role,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: const Color(0xFF0E0E1A),
//           borderRadius: BorderRadius.circular(6),
//           border: Border.all(
//             color: isOn ? const Color(0xFFFF6B35).withOpacity(0.5) : const Color(0xFF1E1E30),
//             width: isOn ? 1.5 : 1,
//           ),
//           boxShadow: isOn
//               ? [BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.08), blurRadius: 16)]
//               : [],
//         ),
//         child: Column(
//           children: [
//             // ── Card header ───────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
//               child: Row(
//                 children: [
//                   // Status dot
//                   Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: isOn ? const Color(0xFF00FF88) : const Color(0xFF333350),
//                       boxShadow: isOn
//                           ? [BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.5), blurRadius: 6)]
//                           : [],
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       device.name.toUpperCase(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 2,
//                         fontFamily: 'monospace',
//                       ),
//                     ),
//                   ),
//                   // Status label
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: isOn
//                           ? const Color(0xFF00FF88).withOpacity(0.1)
//                           : const Color(0xFF1A1A2E),
//                       borderRadius: BorderRadius.circular(3),
//                       border: Border.all(
//                         color: isOn ? const Color(0xFF00FF88).withOpacity(0.4) : const Color(0xFF2A2A3E),
//                       ),
//                     ),
//                     child: Text(
//                       isOn ? 'RUNNING' : 'IDLE',
//                       style: TextStyle(
//                         color: isOn ? const Color(0xFF00FF88) : const Color(0xFF444460),
//                         fontSize: 9,
//                         letterSpacing: 2,
//                         fontFamily: 'monospace',
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ── Divider ───────────────────────────────────
//             Container(height: 1, color: const Color(0xFF1A1A2A)),

//             // ── Stats row ─────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
//               child: Row(
//                 children: [
//                   _StatChip(
//                     icon: Icons.thermostat_outlined,
//                     label: "TEMP",
//                     value: "${device.currentTemp.toStringAsFixed(1)}°C",
//                     accent: const Color(0xFFFF6B35),
//                   ),
//                   const SizedBox(width: 8),
//                   _StatChip(
//                     icon: Icons.compress_outlined,
//                     label: "PRESSURE",
//                     value: "${device.pressure.toStringAsFixed(1)} Pa",
//                     accent: const Color(0xFF4A9EFF),
//                   ),
//                   const SizedBox(width: 8),
//                   _StatChip(
//                     icon: Icons.flag_outlined,
//                     label: "TARGET",
//                     value: "${device.targetTemp.toStringAsFixed(1)}°C",
//                     accent: const Color(0xFFFFCC00),
//                   ),
//                   const SizedBox(width: 8),
//                   _StatChip(
//                     icon: Icons.timer_outlined,
//                     label: "TIMER",
//                     value: "${device.timer}m",
//                     accent: const Color(0xFF00FF88),
//                   ),
//                 ],
//               ),
//             ),

//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Stat chip widget ──────────────────────────────────────
// class _StatChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color accent;

//   const _StatChip({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.accent,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
//         decoration: BoxDecoration(
//           color: const Color(0xFF12121F),
//           borderRadius: BorderRadius.circular(4),
//           border: Border.all(color: const Color(0xFF1E1E30)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, color: accent, size: 12),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.25),
//                 fontSize: 7,
//                 letterSpacing: 1,
//                 fontFamily: 'monospace',
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               value,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 11,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'monospace',
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Gear decoration widget ────────────────────────────────
// class _GearWidget extends StatelessWidget {
//   final double size;
//   final Color color;
//   const _GearWidget({required this.size, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       size: Size(size, size),
//       painter: _GearPainter(color: color),
//     );
//   }
// }

// class _GearPainter extends CustomPainter {
//   final Color color;
//   _GearPainter({required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;

//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2 - 10;
//     final innerRadius = radius * 0.6;
//     const teethCount = 12;
//     final teethHeight = radius * 0.18;

//     final path = Path();
//     for (int i = 0; i < teethCount; i++) {
//       final angle = (i / teethCount) * 2 * math.pi;
//       final nextAngle = ((i + 0.5) / teethCount) * 2 * math.pi;
//       final afterAngle = ((i + 1) / teethCount) * 2 * math.pi;

//       final x1 = center.dx + innerRadius * math.cos(angle);
//       final y1 = center.dy + innerRadius * math.sin(angle);
//       final x2 = center.dx + (radius + teethHeight) * math.cos(nextAngle);
//       final y2 = center.dy + (radius + teethHeight) * math.sin(nextAngle);
//       final x3 = center.dx + innerRadius * math.cos(afterAngle);
//       final y3 = center.dy + innerRadius * math.sin(afterAngle);

//       if (i == 0) path.moveTo(x1, y1);
//       path.lineTo(x2, y2);
//       path.lineTo(x3, y3);
//     }
//     path.close();

//     canvas.drawPath(path, paint);
//     canvas.drawCircle(center, innerRadius * 0.4, paint);
//   }

//   @override
//   bool shouldRepaint(_GearPainter old) => old.color != color;
// }

// // ── Background grid painter ───────────────────────────────
// class _GridPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFF1A1A2E).withOpacity(0.6)
//       ..strokeWidth = 0.5;

//     const spacing = 32.0;
//     for (double x = 0; x < size.width; x += spacing) {
//       canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
//     }
//     for (double y = 0; y < size.height; y += spacing) {
//       canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
//     }

//     final dotPaint = Paint()
//       ..color = const Color(0xFF1E1E35)
//       ..style = PaintingStyle.fill;

//     for (double x = 0; x < size.width; x += spacing) {
//       for (double y = 0; y < size.height; y += spacing) {
//         canvas.drawCircle(Offset(x, y), 1, dotPaint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(_GridPainter old) => false;
// }

// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/device_model.dart';
import 'device_detail_screen.dart';
import 'analytics_screen.dart';
import 'login_screen.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  final String? role;

  const DashboardScreen({super.key, this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();

  late AnimationController _slideController;
  late AnimationController _rotateController;
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

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeIn),
    );

    _rotateController.repeat();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
         

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top AppBar ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        // Logo
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
                          child: const Icon(Icons.whatshot_rounded, color: Color(0xFFFF6B35), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "STEAM PRO",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              "CONTROL DASHBOARD",
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

                        // ── Three-dot menu ────────────────
                        PopupMenuButton<String>(
                          color: const Color(0xFF12121F),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: const BorderSide(color: Color(0xFF2A2A3E)),
                          ),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF12121F),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF2A2A3E)),
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Color(0xFF666680),
                              size: 16,
                            ),
                          ),
                          onSelected: (value) async {
                            if (value == 'analytics') {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => const AnalyticsScreen(),
                                  transitionsBuilder: (_, animation, __, child) =>
                                      FadeTransition(opacity: animation, child: child),
                                  transitionDuration: const Duration(milliseconds: 300),
                                ),
                              );
                            } else if (value == 'logout') {
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => const LoginScreen(),
                                    transitionsBuilder: (_, animation, __, child) =>
                                        FadeTransition(opacity: animation, child: child),
                                    transitionDuration: const Duration(milliseconds: 400),
                                  ),
                                  (route) => false,
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            // Role display (non-tappable info row)
                            PopupMenuItem<String>(
                              enabled: false,
                              height: 38,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    color: widget.role == 'admin'
                                        ? const Color(0xFFFF6B35)
                                        : const Color(0xFF444460),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    widget.role?.toUpperCase() ?? 'USER',
                                    style: TextStyle(
                                      color: widget.role == 'admin'
                                          ? const Color(0xFFFF6B35)
                                          : const Color(0xFF666680),
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(height: 1),
                            // Analytics
                            const PopupMenuItem<String>(
                              value: 'analytics',
                              height: 42,
                              child: Row(
                                children: [
                                  Icon(Icons.analytics_outlined,
                                      color: Color(0xFF4A9EFF), size: 15),
                                  SizedBox(width: 10),
                                  Text(
                                    "ANALYTICS",
                                    style: TextStyle(
                                      color: Color(0xFF4A9EFF),
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(height: 1),
                            // Logout
                            const PopupMenuItem<String>(
                              value: 'logout',
                              height: 42,
                              child: Row(
                                children: [
                                  Icon(Icons.logout,
                                      color: Color(0xFFFF3B30), size: 15),
                                  SizedBox(width: 10),
                                  Text(
                                    "LOGOUT",
                                    style: TextStyle(
                                      color: Color(0xFFFF3B30),
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Divider ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        Container(width: 16, height: 1, color: const Color(0xFF2A2A3E)),
                        const SizedBox(width: 8),
                        const Text(
                          "ACTIVE UNITS",
                          style: TextStyle(
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
                    ),
                  ),

                  // ── Device List ───────────────────────────
                  Expanded(
                    child: StreamBuilder<List<DeviceModel>>(
                      stream: _firestoreService.getDevices(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, color: Color(0xFFFF3B30), size: 32),
                                const SizedBox(height: 12),
                                const Text(
                                  "ERROR LOADING DEVICES",
                                  style: TextStyle(
                                    color: Color(0xFFFF3B30),
                                    fontFamily: 'monospace',
                                    letterSpacing: 2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Color(0xFFFF6B35)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "SCANNING NETWORK...",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontFamily: 'monospace',
                                    letterSpacing: 2,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final devices = snapshot.data!;

                        if (devices.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.device_unknown_outlined,
                                    color: Colors.white.withOpacity(0.15), size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  "NO DEVICES FOUND",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.2),
                                    fontFamily: 'monospace',
                                    letterSpacing: 3,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            return _DeviceCard(
                              device: device,
                              isOn: device.isOnline,
                              role: widget.role,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => DeviceDetailScreen(
                                      deviceId: device.id,
                                      role: widget.role,
                                    ),
                                    transitionsBuilder: (_, animation, __, child) =>
                                        FadeTransition(opacity: animation, child: child),
                                    transitionDuration: const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // ── Bottom status bar ─────────────────────
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
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00FF88),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "SYS STATUS: ONLINE",
                          style: TextStyle(
                            color: Color(0xFF444460),
                            fontSize: 10,
                            letterSpacing: 2,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          "v2.4.1",
                          style: TextStyle(
                            color: Color(0xFF333350),
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
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
}

// ── Device Card Widget ────────────────────────────────────
class _DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final bool isOn;
  final String? role;
  final VoidCallback onTap;

  const _DeviceCard({
    required this.device,
    required this.isOn,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E1A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isOn ? const Color(0xFFFF6B35).withOpacity(0.5) : const Color(0xFF1E1E30),
            width: isOn ? 1.5 : 1,
          ),
          boxShadow: isOn
              ? [BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.08), blurRadius: 16)]
              : [],
        ),
        child: Column(
          children: [
            // ── Card header ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOn ? const Color(0xFF00FF88) : const Color(0xFF333350),
                      boxShadow: isOn
                          ? [BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.5), blurRadius: 6)]
                          : [],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      device.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isOn
                          ? const Color(0xFF00FF88).withOpacity(0.1)
                          : const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: isOn ? const Color(0xFF00FF88).withOpacity(0.4) : const Color(0xFF2A2A3E),
                      ),
                    ),
                    child: Text(
                      isOn ? 'RUNNING' : 'IDLE',
                      style: TextStyle(
                        color: isOn ? const Color(0xFF00FF88) : const Color(0xFF444460),
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

            // ── Divider ───────────────────────────────────
            Container(height: 1, color: const Color(0xFF1A1A2A)),

            // ── Stats row ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  _StatChip(
                    icon: Icons.thermostat_outlined,
                    label: "TEMP",
                    value: "${device.currentTemp.toStringAsFixed(1)}°C",
                    accent: const Color(0xFFFF6B35),
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.compress_outlined,
                    label: "PRESSURE",
                    value: "${device.pressure.toStringAsFixed(1)} Pa",
                    accent: const Color(0xFF4A9EFF),
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.flag_outlined,
                    label: "TARGET",
                    value: "${device.targetTemp.toStringAsFixed(1)}°C",
                    accent: const Color(0xFFFFCC00),
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.timer_outlined,
                    label: "TIMER",
                    value: "${device.timer}m",
                    accent: const Color(0xFF00FF88),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat chip widget ──────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF12121F),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF1E1E30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 12),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 7,
                letterSpacing: 1,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gear decoration widget ────────────────────────────────
