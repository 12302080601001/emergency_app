import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/incident_log.dart';
import '../models/ice_contact.dart';
import '../providers/app_provider.dart';

class EmergencyService {
  EmergencyService._();
  static final EmergencyService instance = EmergencyService._();

  /// Requests location permissions and fetches current GPS position.
  Future<Position?> getCurrentLocation({BuildContext? context}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable GPS / Location services on your device.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        await Geolocator.openLocationSettings();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied. Please enable them in app settings.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        await Geolocator.openAppSettings();
        return null;
      }

      // First try to fetch high-accuracy current position with a timeout
      try {
        const locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        );
        return await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );
      } catch (e) {
        debugPrint('Error or timeout fetching current position: $e');
        // Fallback to last known position
        return await Geolocator.getLastKnownPosition();
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Triggers full emergency workflow: obtains GPS location, dispatches SMS to ICE contacts, and logs incident.
  Future<IncidentLog> triggerEmergency({
    required BuildContext context,
    required AppProvider provider,
    required String type, // 'SOS', 'Medical', 'Fire', 'Security'
    String? severity,
    String? additionalInfo,
  }) async {
    // 1. Get GPS coordinates
    Position? position = await getCurrentLocation(context: context);
    double latitude = position?.latitude ?? 0.0;
    double longitude = position?.longitude ?? 0.0;

    // 2. Prepare incident summary
    String summary = '';
    if (type.toUpperCase() == 'SOS') {
      summary = 'Emergency SOS triggered from main beacon.';
    } else {
      summary = 'Type: $type | Severity: ${severity ?? "High"} | Info: ${additionalInfo ?? "None"}';
    }

    // 3. Prepare incident log & save to database
    final log = IncidentLog(
      timestamp: DateTime.now().toIso8601String(),
      type: type,
      status: 'Active',
      summary: summary,
      latitude: latitude,
      longitude: longitude,
    );
    await provider.addIncidentLog(log);

    // 4. Construct Emergency Message
    final medicalProfile = provider.medicalProfile;
    final contacts = provider.iceContacts;

    String mapsUrl = (latitude != 0.0 || longitude != 0.0)
        ? 'https://maps.google.com/?q=$latitude,$longitude'
        : 'Location unavailable';

    StringBuffer msgBuffer = StringBuffer();
    if (type.toUpperCase() == 'SOS') {
      msgBuffer.writeln('🚨 EMERGENCY SOS ALERT 🚨');
      msgBuffer.writeln('I need immediate help!');
    } else {
      msgBuffer.writeln('🚨 EMERGENCY ALERT - ${type.toUpperCase()} 🚨');
      if (severity != null && severity.isNotEmpty) {
        msgBuffer.writeln('Severity: $severity');
      }
      if (additionalInfo != null && additionalInfo.isNotEmpty && additionalInfo != 'None') {
        msgBuffer.writeln('Info: $additionalInfo');
      }
    }

    msgBuffer.writeln();
    if (latitude != 0.0 || longitude != 0.0) {
      msgBuffer.writeln('📍 My Current Location:');
      msgBuffer.writeln(mapsUrl);
      msgBuffer.writeln('Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}');
    } else {
      msgBuffer.writeln('📍 Location: GPS coordinates could not be acquired.');
    }

    if (medicalProfile != null) {
      msgBuffer.writeln();
      msgBuffer.writeln('👤 Medical Profile:');
      if (medicalProfile.name.isNotEmpty) msgBuffer.writeln('Name: ${medicalProfile.name}');
      if (medicalProfile.bloodType.isNotEmpty) msgBuffer.writeln('Blood Type: ${medicalProfile.bloodType}');
      if (medicalProfile.allergies.isNotEmpty) msgBuffer.writeln('Allergies: ${medicalProfile.allergies}');
      if (medicalProfile.medicalConditions.isNotEmpty) msgBuffer.writeln('Conditions: ${medicalProfile.medicalConditions}');
    }

    final message = msgBuffer.toString();

    // 5. Send alerts to ICE contacts
    if (contacts.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ No ICE contacts found! Please add contacts in Medical ID.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } else {
      if (context.mounted) {
        await sendSmsToContacts(contacts: contacts, message: message, context: context);
      }
    }

    return log;
  }

  /// Dispatches SMS to all ICE contacts using standard SMS intents
  Future<void> sendSmsToContacts({
    required List<IceContact> contacts,
    required String message,
    BuildContext? context,
  }) async {
    final phoneNumbers = contacts
        .map((c) => c.phoneNumber.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (phoneNumbers.isEmpty) return;

    // Format phone numbers for SMS URL
    // Join with comma or semicolon for multiple recipients
    final recipientString = phoneNumbers.join(';');

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: recipientString,
      queryParameters: {
        'body': message,
      },
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for single recipient
        final Uri fallbackUri = Uri.parse('sms:${phoneNumbers.first}?body=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        } else {
          if (context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open SMS application.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error launching SMS: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to launch SMS: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Launch phone dialer
  Future<void> makePhoneCall(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri callUri = Uri(scheme: 'tel', path: cleaned);
    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching call: $e');
    }
  }

  /// Open location in Google Maps / Apple Maps
  Future<void> openMapLocation(double latitude, double longitude) async {
    if (latitude == 0.0 && longitude == 0.0) return;
    final Uri mapUri = Uri.parse('https://maps.google.com/?q=$latitude,$longitude');
    try {
      if (await canLaunchUrl(mapUri)) {
        await launchUrl(mapUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening map: $e');
    }
  }
}
