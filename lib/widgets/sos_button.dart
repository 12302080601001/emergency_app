import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../services/emergency_service.dart';

class SOSButton extends StatefulWidget {
  const SOSButton({super.key});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  bool _isActive = false;
  int _countdown = 3;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _triggerSOS() {
    if (_isActive) return;
    
    setState(() {
      _isActive = true;
      _countdown = 3;
    });

    Vibration.vibrate(duration: 500);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
        Vibration.vibrate(duration: 200);
      } else {
        timer.cancel();
        _activateEmergency();
      }
    });
  }

  Future<void> _activateEmergency() async {
    // Vibrate device
    try {
      Vibration.vibrate(pattern: [500, 1000, 500, 1000, 500, 1000]);
    } catch (_) {}

    final provider = Provider.of<AppProvider>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 SOS Activated! Fetching GPS location and sending alerts...'),
        backgroundColor: AppTheme.emergencyRed,
        duration: Duration(seconds: 4),
      ),
    );

    // Call real emergency service (GPS location + SMS dispatch + Incident Log)
    final log = await EmergencyService.instance.triggerEmergency(
      context: context,
      provider: provider,
      type: 'SOS',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            log.latitude != 0.0 || log.longitude != 0.0
                ? '📍 Location acquired: ${log.latitude.toStringAsFixed(4)}, ${log.longitude.toStringAsFixed(4)}. Alerts sent!'
                : 'Alert recorded. Please ensure GPS is enabled.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    // Reset button state
    if (mounted) {
      setState(() {
        _isActive = false;
      });
    }
  }

  void _cancelSOS() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      setState(() {
        _isActive = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS Cancelled'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isActive ? _cancelSOS : _triggerSOS,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isActive ? 1.0 : _pulseAnimation.value,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.emergencyRed.withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.emergencyRed.withValues(alpha: 0.6),
                    blurRadius: _isActive ? 50 : 30 * _pulseAnimation.value,
                    spreadRadius: _isActive ? 20 : 10 * _pulseAnimation.value,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(5, 5),
                  ),
                ],
                gradient: const RadialGradient(
                  colors: [
                    Colors.redAccent,
                    AppTheme.emergencyRed,
                  ],
                  center: Alignment.topLeft,
                  radius: 1.0,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isActive ? Icons.close : Icons.sos,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isActive
                          ? 'CANCEL\n($_countdown)'
                          : 'PRESS FOR\nHELP',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
