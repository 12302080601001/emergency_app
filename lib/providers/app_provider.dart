import 'package:flutter/material.dart';
import '../models/medical_profile.dart';
import '../models/ice_contact.dart';
import '../models/incident_log.dart';
import '../database/database_helper.dart';

class AppProvider with ChangeNotifier {
  MedicalProfile? _medicalProfile;
  List<IceContact> _iceContacts = [];
  List<IncidentLog> _incidentLogs = [];

  MedicalProfile? get medicalProfile => _medicalProfile;
  List<IceContact> get iceContacts => _iceContacts;
  List<IncidentLog> get incidentLogs => _incidentLogs;

  AppProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _medicalProfile = await DatabaseHelper.instance.getMedicalProfile();
    _iceContacts = await DatabaseHelper.instance.getIceContacts();
    _incidentLogs = await DatabaseHelper.instance.getIncidentLogs();
    notifyListeners();
  }

  Future<void> updateMedicalProfile(MedicalProfile profile) async {
    await DatabaseHelper.instance.updateMedicalProfile(profile);
    _medicalProfile = await DatabaseHelper.instance.getMedicalProfile();
    notifyListeners();
  }

  Future<void> resetMedicalProfile() async {
    await DatabaseHelper.instance.resetMedicalProfile();
    _medicalProfile = null;
    notifyListeners();
  }

  Future<void> addIceContact(IceContact contact) async {
    await DatabaseHelper.instance.addIceContact(contact);
    _iceContacts = await DatabaseHelper.instance.getIceContacts();
    notifyListeners();
  }

  Future<void> removeIceContact(int id) async {
    await DatabaseHelper.instance.deleteIceContact(id);
    _iceContacts = await DatabaseHelper.instance.getIceContacts();
    notifyListeners();
  }

  Future<void> addIncidentLog(IncidentLog log) async {
    await DatabaseHelper.instance.addIncidentLog(log);
    _incidentLogs = await DatabaseHelper.instance.getIncidentLogs();
    notifyListeners();
  }

  Future<void> updateIncidentStatus(int id, String newStatus) async {
    await DatabaseHelper.instance.updateIncidentStatus(id, newStatus);
    _incidentLogs = await DatabaseHelper.instance.getIncidentLogs();
    notifyListeners();
  }

  Future<void> deleteIncidentLog(int id) async {
    await DatabaseHelper.instance.deleteIncidentLog(id);
    _incidentLogs = await DatabaseHelper.instance.getIncidentLogs();
    notifyListeners();
  }

  Future<void> clearAllIncidentLogs() async {
    await DatabaseHelper.instance.clearAllIncidentLogs();
    _incidentLogs = [];
    notifyListeners();
  }
}
