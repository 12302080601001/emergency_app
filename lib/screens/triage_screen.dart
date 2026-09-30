import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import '../services/emergency_service.dart';

class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  int _step = 0;
  String _emergencyType = '';
  String _severity = '';
  String _additionalInfo = '';

  final List<Map<String, dynamic>> _types = [
    {'title': 'Medical', 'icon': Icons.medical_services, 'color': Colors.blueAccent},
    {'title': 'Fire', 'icon': Icons.local_fire_department, 'color': Colors.orange},
    {'title': 'Security', 'icon': Icons.local_police, 'color': Colors.blueGrey},
  ];

  final List<String> _severities = ['Low (Non-Life Threatening)', 'Medium (Urgent)', 'High (Critical)'];
  final List<String> _quickInfo = ['Need Ambulance', 'Need Police', 'Need Firetruck', 'Trapped', 'Bleeding', 'Unconscious'];

  Future<void> _submitTriage() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transmitting triage report and live location...'),
        backgroundColor: AppTheme.midBlue,
        duration: Duration(seconds: 3),
      ),
    );

    final log = await EmergencyService.instance.triggerEmergency(
      context: context,
      provider: provider,
      type: _emergencyType,
      severity: _severity,
      additionalInfo: _additionalInfo,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            log.latitude != 0.0 || log.longitude != 0.0
                ? 'Triage alert sent with GPS (${log.latitude.toStringAsFixed(4)}, ${log.longitude.toStringAsFixed(4)})'
                : 'Triage report recorded and sent to ICE contacts.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('What is the emergency?', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _types.map((type) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _emergencyType = type['title'] as String;
                  _step++;
                });
              },
              child: GlassCard(
                width: 100,
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(type['icon'] as IconData, size: 40, color: type['color'] as Color),
                    const SizedBox(height: 10),
                    Text(type['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Severity Level?', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 30),
        ..._severities.map((sev) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.midBlue,
                ),
                onPressed: () {
                  setState(() {
                    _severity = sev;
                    _step++;
                  });
                },
                child: Text(sev),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Quick Info?', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 30),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: _quickInfo.map((info) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _additionalInfo = info;
                });
                _submitTriage();
              },
              child: Chip(
                label: Text(info),
                backgroundColor: AppTheme.slateDark,
                labelStyle: const TextStyle(color: AppTheme.softPastelRed),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
        TextButton(
          onPressed: () {
            _additionalInfo = 'None';
            _submitTriage();
          },
          child: const Text('Skip / Send Now', style: TextStyle(color: Colors.white54)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Triage'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _step == 0
              ? _buildStep1()
              : _step == 1
                  ? _buildStep2()
                  : _buildStep3(),
        ),
      ),
    );
  }
}
