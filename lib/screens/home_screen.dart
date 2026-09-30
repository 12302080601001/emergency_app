import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/sos_button.dart';
import '../services/emergency_service.dart';
import 'triage_screen.dart';
import 'medical_id_screen.dart';
import 'incident_logs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isSirenFlashing = false;
  late AnimationController _strobeController;

  @override
  void initState() {
    super.initState();
    _strobeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _strobeController.reverse();
        } else if (status == AnimationStatus.dismissed && _isSirenFlashing) {
          _strobeController.forward();
        }
      });
  }

  @override
  void dispose() {
    _strobeController.dispose();
    super.dispose();
  }

  void _toggleStrobeSiren() {
    setState(() {
      _isSirenFlashing = !_isSirenFlashing;
    });

    if (_isSirenFlashing) {
      _strobeController.forward();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency Strobe Alarm ACTIVE! Tap again to turn off.'),
          backgroundColor: AppTheme.emergencyRed,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      _strobeController.stop();
      _strobeController.reset();
    }
  }

  Future<void> _quickShareLiveLocation(BuildContext context, AppProvider provider) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Acquiring live GPS location...'),
        backgroundColor: AppTheme.midBlue,
        duration: Duration(seconds: 2),
      ),
    );

    final position = await EmergencyService.instance.getCurrentLocation(context: context);
    if (position != null) {
      final mapUrl = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      final shareText = 'EMERGENCY LOCATION:\n$mapUrl\n(Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)})';
      
      await Clipboard.setData(ClipboardData(text: shareText));
      
      if (context.mounted) {
        if (provider.iceContacts.isNotEmpty) {
          await EmergencyService.instance.sendSmsToContacts(
            contacts: provider.iceContacts,
            message: shareText,
            context: context,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location copied to clipboard! (Add ICE contacts in Medical ID to send automatically)'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final profile = provider.medicalProfile;
    final contactsCount = provider.iceContacts.length;

    return AnimatedBuilder(
      animation: _strobeController,
      builder: (context, child) {
        final backgroundColor = _isSirenFlashing
            ? Color.lerp(AppTheme.slateDark, AppTheme.emergencyRed, _strobeController.value)
            : AppTheme.slateDark;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text('RescuSphere', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_location, color: AppTheme.lightBlue),
                tooltip: 'Quick Share Location',
                onPressed: () => _quickShareLiveLocation(context, provider),
              ),
              IconButton(
                icon: const Icon(Icons.medical_information),
                tooltip: 'Medical Profile & ICE',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalIdScreen()));
                },
              ),
            ],
          ),
          drawer: Drawer(
            backgroundColor: AppTheme.darkSurface,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: AppTheme.slateDark),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.shield, size: 48, color: AppTheme.emergencyRed),
                      const SizedBox(height: 8),
                      const Text('RescuSphere', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(
                        profile != null ? 'User: ${profile.name}' : 'Emergency System Active',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: AppTheme.lightBlue),
                  title: const Text('Incident Logs'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.midBlue.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.incidentLogs.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const IncidentLogsScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contact_emergency, color: AppTheme.emergencyRed),
                  title: const Text('Medical ID & ICE Contacts'),
                  trailing: Text(
                    '$contactsCount Saved',
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalIdScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_hospital, color: Colors.blueAccent),
                  title: const Text('Smart Triage'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TriageScreen()));
                  },
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: Icon(
                    _isSirenFlashing ? Icons.flash_off : Icons.flash_on,
                    color: _isSirenFlashing ? Colors.redAccent : Colors.amberAccent,
                  ),
                  title: Text(_isSirenFlashing ? 'Stop Strobe Alarm' : 'Strobe Visual Alarm'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleStrobeSiren();
                  },
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalIdScreen())),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.darkSurface.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: profile != null ? AppTheme.midBlue : Colors.orangeAccent.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.badge,
                                  size: 16,
                                  color: profile != null ? AppTheme.lightBlue : Colors.orangeAccent,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    profile != null ? 'ID: ${profile.name} (${profile.bloodType})' : 'Set Medical ID',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalIdScreen())),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.darkSurface.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: contactsCount > 0 ? Colors.greenAccent.withValues(alpha: 0.6) : Colors.redAccent.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.contacts,
                                  size: 16,
                                  color: contactsCount > 0 ? Colors.greenAccent : Colors.redAccent,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    contactsCount > 0 ? 'ICE: $contactsCount Armed' : 'No ICE Contacts',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: SOSButton(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAction(
                        icon: _isSirenFlashing ? Icons.flash_off : Icons.flash_on,
                        label: _isSirenFlashing ? 'Mute' : 'Strobe',
                        color: _isSirenFlashing ? Colors.redAccent : Colors.amber,
                        onTap: _toggleStrobeSiren,
                      ),
                      _buildQuickAction(
                        icon: Icons.sos,
                        label: '112 SOS',
                        color: Colors.redAccent,
                        onTap: () => EmergencyService.instance.makePhoneCall('112'),
                      ),
                      _buildQuickAction(
                        icon: Icons.local_hospital,
                        label: '108 Amb',
                        color: Colors.blueAccent,
                        onTap: () => EmergencyService.instance.makePhoneCall('108'),
                      ),
                      _buildQuickAction(
                        icon: Icons.local_police,
                        label: '100 Police',
                        color: Colors.tealAccent,
                        onTap: () => EmergencyService.instance.makePhoneCall('100'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.midBlue,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TriageScreen()));
                      },
                      icon: const Icon(Icons.medical_services_outlined, size: 24),
                      label: const Text('Smart Triage & Reporting', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
