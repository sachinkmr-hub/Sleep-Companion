import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neend_companion/models/alarm_data.dart';
import 'package:neend_companion/data/repositories/alarm_repository.dart';

class AlarmScreen extends ConsumerStatefulWidget {
  const AlarmScreen({super.key});

  @override
  ConsumerState<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends ConsumerState<AlarmScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final AlarmRepository _alarmRepository = AlarmRepository();
  AlarmData? _alarmData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _loadAlarmData();
  }

  Future<void> _loadAlarmData() async {
    final alarms = await _alarmRepository.getAlarms();
    if (mounted) {
      setState(() {
        _alarmData = alarms.isNotEmpty ? alarms.first : AlarmData(
          id: '1', 
          time: DateTime.now(), 
          isEnabled: true,
          tomorrowGoal: 'Have a great day!',
        );
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _dismissAlarm() {
    context.go('/morning');
  }

  void _snoozeAlarm() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8E7),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF8C42))),
      );
    }
    
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7), // Morning bg
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text('Good Morning', style: TextStyle(fontSize: 24, color: Color(0xFF2D3142))),
                  const SizedBox(height: 16),
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Text(
                      timeStr,
                      style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w300, color: Color(0xFF2D3142)),
                    ),
                  ),
                ],
              ),
              if (_alarmData?.tomorrowGoal != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFF8C42)),
                      const SizedBox(width: 8),
                      Text(_alarmData!.tomorrowGoal!, style: const TextStyle(fontSize: 18, color: Color(0xFF2D3142))),
                    ],
                  ),
                ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _dismissAlarm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C42), // Morning accent
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Dismiss', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _snoozeAlarm,
                    child: const Text('Snooze 5 min', style: TextStyle(fontSize: 18, color: Color(0xFF2D3142))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
