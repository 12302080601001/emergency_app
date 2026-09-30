import 'package:flutter_test/flutter_test.dart';
import 'package:emergency_app/models/ice_contact.dart';
import 'package:emergency_app/models/medical_profile.dart';
import 'package:emergency_app/models/incident_log.dart';

void main() {
  test('Medical Profile Model Test', () {
    final profile = MedicalProfile(
      id: 1,
      name: 'John Doe',
      bloodType: 'O+',
      allergies: 'Penicillin',
      medicalConditions: 'Asthma',
    );

    expect(profile.name, 'John Doe');
    expect(profile.toMap()['blood_type'], 'O+');
  });

  test('ICE Contact Model Test', () {
    final contact = IceContact(
      id: 1,
      name: 'Jane Doe',
      relation: 'Spouse',
      phoneNumber: '+91 9099146980',
    );

    expect(contact.phoneNumber, '+91 9099146980');
    expect(contact.toMap()['relation'], 'Spouse');
  });

  test('Incident Log Model Test', () {
    final log = IncidentLog(
      id: 1,
      timestamp: '2026-09-30T10:00:00Z',
      type: 'SOS',
      status: 'Active',
      summary: 'Emergency SOS triggered',
      latitude: 28.6139,
      longitude: 77.2090,
    );

    expect(log.latitude, 28.6139);
    expect(log.longitude, 77.2090);
    expect(log.toMap()['type'], 'SOS');
  });
}
